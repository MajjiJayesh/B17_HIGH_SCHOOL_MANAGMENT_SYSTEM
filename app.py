from flask import Flask, request, jsonify, g, send_file
from flask_cors import CORS
import psycopg2
from werkzeug.security import generate_password_hash, check_password_hash
from itsdangerous import URLSafeTimedSerializer, BadSignature, SignatureExpired
import os

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "local-demo-change-before-cloud")

_cors = os.getenv("CORS_ORIGINS", "*")
CORS(app, origins=[x.strip() for x in _cors.split(",")] if _cors != "*" else "*")

serializer = URLSafeTimedSerializer(app.config["SECRET_KEY"])
TOKEN_MAX_AGE = 8 * 60 * 60

def get_db_connection():
    config = {
        "host": os.getenv("DB_HOST", "localhost"),
        "port": os.getenv("DB_PORT", "5432"),
        "database": os.getenv("DB_NAME", "High_School_Management"),
        "user": os.getenv("DB_USER", "postgres"),
        "password": os.getenv("DB_PASSWORD", "Jayesh@29"),
    }
    if os.getenv("DB_SSLMODE"):
        config["sslmode"] = os.getenv("DB_SSLMODE")
    return psycopg2.connect(**config)


def error_response(message, status=400):
    return jsonify({"error": str(message)}), status


def write_audit(cursor, user_id, action, table_name, record_id, description):
    try:
        cursor.execute("SAVEPOINT audit_log_savepoint")
        cursor.execute(
            """
            INSERT INTO audit_log
            (user_id, action, table_name, record_id,
             action_timestamp, ip_address, description)
            VALUES (%s, %s, %s, %s, CURRENT_TIMESTAMP, %s, %s)
            """,
            (
                user_id, action, table_name, record_id,
                request.remote_addr, description
            ),
        )
        cursor.execute("RELEASE SAVEPOINT audit_log_savepoint")
    except psycopg2.Error:
        cursor.execute("ROLLBACK TO SAVEPOINT audit_log_savepoint")
        cursor.execute("RELEASE SAVEPOINT audit_log_savepoint")


def get_role_id(cursor, role_name):
    cursor.execute(
        "SELECT role_id FROM roles WHERE LOWER(role_name)=LOWER(%s) LIMIT 1",
        (role_name,),
    )
    row = cursor.fetchone()
    return row[0] if row else None


def get_current_teacher_id(cursor):
    cursor.execute(
        "SELECT teacher_id FROM teachers WHERE user_id=%s LIMIT 1",
        (g.user_id,),
    )
    row = cursor.fetchone()
    return row[0] if row else None


def get_current_student_id(cursor):
    cursor.execute(
        "SELECT student_id FROM students WHERE user_id=%s LIMIT 1",
        (g.user_id,),
    )
    row = cursor.fetchone()
    return row[0] if row else None


def get_current_parent_id(cursor):
    cursor.execute(
        "SELECT parent_id FROM parents WHERE user_id=%s LIMIT 1",
        (g.user_id,),
    )
    row = cursor.fetchone()
    return row[0] if row else None


def is_admin():
    return getattr(g, "role_name", "") in {
        "administrator",
        "super administrator",
        "admin",
        "super admin",
        "system administrator",
    }


def is_teacher():
    return "teacher" in getattr(g, "role_name", "")


def is_student():
    return "student" in getattr(g, "role_name", "")


def is_parent():
    return "parent" in getattr(g, "role_name", "")


def get_linked_student_ids(cursor):
    """Return only students linked to the logged-in parent."""
    parent_id = get_current_parent_id(cursor)
    if parent_id is None:
        return []

    cursor.execute(
        """
        SELECT student_id
        FROM student_parents
        WHERE parent_id=%s
        """,
        (parent_id,),
    )
    return [row[0] for row in cursor.fetchall()]


# ============================================================
# AUTHENTICATION
# ============================================================

@app.before_request
def authenticate_request():
    public_paths = {"/", "/login", "/test-db"}

    if request.method == "OPTIONS" or request.path in public_paths:
        return None

    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return jsonify({"error": "Authentication required"}), 401

    token = header.split(" ", 1)[1].strip()

    try:
        token_data = serializer.loads(token, max_age=TOKEN_MAX_AGE)
        user_id = int(token_data["user_id"])
    except (BadSignature, SignatureExpired, KeyError, TypeError, ValueError):
        return jsonify({"error": "Invalid or expired session"}), 401

    connection = None
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT u.username, u.role_id, u.account_status, r.role_name
                FROM users u
                JOIN roles r ON r.role_id = u.role_id
                WHERE u.user_id = %s
                """,
                (user_id,),
            )
            user = cursor.fetchone()

        if not user:
            return jsonify({"error": "Account or role not found"}), 401

        username, role_id, account_status, role_name = user

        if str(account_status).upper() != "ACTIVE":
            return jsonify({"error": "Account is not active"}), 403

        g.user_id = user_id
        g.username = username
        g.role_id = role_id
        g.role_name = str(role_name).strip().lower()

    except psycopg2.Error:
        app.logger.exception("Authentication database lookup failed")
        return jsonify({"error": "Unable to verify account permissions"}), 503
    finally:
        if connection is not None:
            connection.close()

    return None


# ============================================================
# ROLE-BASED ACCESS CONTROL
# ============================================================

@app.before_request
def enforce_rbac():
    public_paths = {"/", "/login", "/test-db"}

    if request.method == "OPTIONS" or request.path in public_paths:
        return None

    role = getattr(g, "role_name", "")
    method = request.method.upper()
    path = request.path.rstrip("/") or "/"

    # Both administrator roles have full route-level access.
    if role in {
        "administrator",
        "super administrator",
        "admin",
        "super admin",
        "system administrator",
    }:
        return None

    # All authenticated users may view their own identity.
    if method == "GET" and path == "/me":
        return None

    parts = path.split("/")
    if len(parts) == 3 and parts[2].isdigit():
        resource = f"/{parts[1]}/<id>"
    else:
        resource = path

    permissions = {
        "teacher": {
            ("GET", "/students"),
            ("GET", "/teachers"),
            ("GET", "/courses"),
            ("GET", "/enrollment"),
            ("GET", "/assignments"),
            ("POST", "/assignments"),
            ("PUT", "/assignments/<id>"),
            ("GET", "/attendance"),
            ("POST", "/attendance"),
            ("PUT", "/attendance/<id>"),
            ("GET", "/marks"),
            ("POST", "/marks"),
            ("PUT", "/marks/<id>"),
        },
        "student": {
            ("GET", "/students"),
            ("GET", "/courses"),
            ("GET", "/enrollment"),
            ("GET", "/assignments"),
            ("GET", "/attendance"),
            ("GET", "/marks"),
        },
        "parent": {
            ("GET", "/parents"),
            ("GET", "/students"),
            ("GET", "/courses"),
            ("GET", "/enrollment"),
            ("GET", "/assignments"),
            ("GET", "/attendance"),
            ("GET", "/marks"),
        },
    }

    role_key = next((key for key in permissions if key in role), None)

    if role_key and (method, resource) in permissions[role_key]:
        return None

    app.logger.warning(
        "RBAC denied role=%s method=%s path=%s user_id=%s",
        role, method, path, getattr(g, "user_id", None),
    )

    return jsonify({
        "error": "Forbidden: your role does not have permission for this action"
    }), 403


# ============================================================
# HOME AND DATABASE TEST
# ============================================================

@app.route("/")
def home():
    if os.path.exists("high_school_management_final.html"):
        return send_file("high_school_management_final.html")
    return "Zero Trust High School Management Backend is running!"


@app.route("/api/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "Zero Trust High School Management Backend",
    }), 200


@app.route("/test-db")
def test_db():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT current_database(), current_user")
            database, db_user = cursor.fetchone()

        return jsonify({
            "database": database,
            "user": db_user,
            "status": "Database connection successful",
        })
    finally:
        connection.close()


# ============================================================
# LOGIN
# ============================================================

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""

    if not username or not password:
        return error_response("Username and password are required", 400)

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT user_id, username, password_hash, role_id, account_status
                FROM users
                WHERE username=%s
                LIMIT 1
                """,
                (username,),
            )
            user = cursor.fetchone()

            if not user:
                return error_response("Invalid username or password", 401)

            user_id, db_username, password_hash, role_id, account_status = user

            if str(account_status).upper() != "ACTIVE":
                return error_response("Account is not active", 403)

            try:
                valid_password = check_password_hash(password_hash, password)
            except (ValueError, TypeError):
                valid_password = False

            # Demo accounts password upgrade
            if not valid_password:
                is_demo = False
                if username == "admin01" and password == os.getenv("DEMO_ADMIN_PASSWORD", "Admin@123"):
                    is_demo = True
                elif username.startswith("teacher") and password == os.getenv("DEMO_TEACHER_PASSWORD", "Teacher@123"):
                    is_demo = True
                elif username.startswith("student") and password == os.getenv("DEMO_STUDENT_PASSWORD", "Student@123"):
                    is_demo = True
                elif username.startswith("parent") and password == os.getenv("DEMO_PARENT_PASSWORD", "Parent@123"):
                    is_demo = True

                if is_demo:
                    cursor.execute(
                        "UPDATE users SET password_hash=%s WHERE user_id=%s",
                        (generate_password_hash(password), user_id),
                    )
                    valid_password = True

            if not valid_password:
                connection.rollback()
                return error_response("Invalid username or password", 401)

            cursor.execute(
                "UPDATE users SET last_login=CURRENT_TIMESTAMP WHERE user_id=%s",
                (user_id,),
            )
            write_audit(
                cursor, user_id, "LOGIN", "users", user_id, "User logged in"
            )

        connection.commit()

        token = serializer.dumps({
            "user_id": user_id,
            "username": db_username,
            "role_id": role_id,
        })

        return jsonify({
            "message": "Login successful",
            "token": token,
            "user": {
                "user_id": user_id,
                "username": db_username,
                "role_id": role_id,
            },
        })

    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Login database error")
        return error_response("Login failed because of a database error", 500)
    finally:
        connection.close()


# ============================================================
# CURRENT USER
# ============================================================

@app.route("/me", methods=["GET"])
def me():
    return jsonify({
        "user_id": g.user_id,
        "username": g.username,
        "role_id": g.role_id,
        "role_name": g.role_name,
    })


# ============================================================
# USERS — ADMIN ONLY
# ============================================================

@app.route("/users", methods=["GET"])
def get_users():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT user_id, user_code, username, email, phone_num,
                       role_id, account_status, last_login, password_last_changed
                FROM users
                ORDER BY user_id
                """
            )
            rows = cursor.fetchall()

        return jsonify([
            {
                "user_id": r[0],
                "user_code": r[1],
                "username": r[2],
                "email": r[3],
                "phone_num": r[4],
                "role_id": r[5],
                "account_status": r[6],
                "last_login": r[7],
                "password_last_changed": r[8],
            }
            for r in rows
        ])
    finally:
        connection.close()


@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json(silent=True) or {}
    required = ["user_code", "username", "password", "role_id"]

    if any(not data.get(key) for key in required):
        return error_response(
            "user_code, username, password and role_id are required", 400
        )

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO users
                (user_code, username, password_hash, email, phone_num, role_id)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING user_id
                """,
                (
                    data["user_code"], data["username"],
                    generate_password_hash(data["password"]),
                    data.get("email"), data.get("phone_num"), data["role_id"],
                ),
            )
            user_id = cursor.fetchone()[0]
            write_audit(
                cursor, g.user_id, "CREATE", "users", user_id, "User created"
            )

        connection.commit()
        return jsonify({
            "message": "User created successfully",
            "user_id": user_id,
        }), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("User creation failed")
        return error_response("User creation failed", 400)
    finally:
        connection.close()

        # ============================================================
# STUDENTS
# ============================================================

@app.route("/students", methods=["GET"])
def get_students():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT student_id,user_id,student_code,first_name,last_name,
                           date_of_birth,gender,grade,section,admission_date,status
                    FROM students WHERE user_id=%s
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT DISTINCT s.student_id,s.user_id,s.student_code,
                           s.first_name,s.last_name,s.date_of_birth,s.gender,
                           s.grade,s.section,s.admission_date,s.status
                    FROM students s
                    JOIN student_parents sp ON sp.student_id=s.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s
                    ORDER BY s.student_id
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT DISTINCT s.student_id,s.user_id,s.student_code,
                           s.first_name,s.last_name,s.date_of_birth,s.gender,
                           s.grade,s.section,s.admission_date,s.status
                    FROM students s
                    JOIN enrollment e ON e.student_id=s.student_id
                    JOIN courses c ON c.course_id=e.course_id
                    JOIN teachers t ON t.teacher_id=c.teacher_id
                    WHERE t.user_id=%s
                    ORDER BY s.student_id
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT student_id,user_id,student_code,first_name,last_name,
                           date_of_birth,gender,grade,section,admission_date,status
                    FROM students ORDER BY student_id
                """)
            rows = cursor.fetchall()

        keys = [
            "student_id", "user_id", "student_code", "first_name",
            "last_name", "date_of_birth", "gender", "grade", "section",
            "admission_date", "status"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/students", methods=["POST"])
def create_student():
    data = request.get_json(silent=True) or {}
    required = [
        "student_code", "first_name", "last_name", "date_of_birth",
        "gender", "grade", "section", "admission_date"
    ]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("All student fields are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT 1 FROM students WHERE student_code=%s",
                (data["student_code"],)
            )
            if cursor.fetchone():
                return error_response("Student code already exists", 409)

            role_id = get_role_id(cursor, "Student")
            if role_id is None:
                return error_response("Student role is missing from roles table", 500)

            cursor.execute("""
                SELECT COALESCE(MAX(CAST(SUBSTRING(user_code FROM 4) AS INTEGER)),0)+1
                FROM users WHERE user_code ~ '^USR[0-9]+$'
            """)
            user_code = f"USR{cursor.fetchone()[0]:03d}"
            username = data["student_code"].lower()

            cursor.execute("""
                INSERT INTO users
                (user_code,username,password_hash,role_id,account_status)
                VALUES (%s,%s,%s,%s,'ACTIVE')
                RETURNING user_id
            """, (
                user_code, username,
                generate_password_hash(data.get("password") or os.getenv("NEW_STUDENT_PASSWORD", "Student@123")),
                role_id
            ))
            user_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO students
                (user_id,student_code,first_name,last_name,date_of_birth,
                 gender,grade,section,admission_date,status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'ACTIVE')
                RETURNING student_id
            """, (
                user_id, data["student_code"], data["first_name"],
                data["last_name"], data["date_of_birth"], data["gender"],
                data["grade"], data["section"], data["admission_date"]
            ))
            student_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "students", student_id, "Student created")

        connection.commit()
        return jsonify({
            "message": "Student created",
            "student_id": student_id,
            "username": username
        }), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create student failed")
        return error_response("Student creation failed", 400)
    finally:
        connection.close()


@app.route("/students/<int:student_id>", methods=["PUT"])
def update_student(student_id):
    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if not is_admin():
                return error_response("Only administrators can update student profiles", 403)

            cursor.execute("""
                UPDATE students
                SET first_name=COALESCE(%s,first_name),
                    last_name=COALESCE(%s,last_name),
                    date_of_birth=COALESCE(%s,date_of_birth),
                    gender=COALESCE(%s,gender),
                    grade=COALESCE(%s,grade),
                    section=COALESCE(%s,section),
                    admission_date=COALESCE(%s,admission_date),
                    status=COALESCE(%s,status)
                WHERE student_id=%s
                RETURNING student_id
            """, (
                data.get("first_name"), data.get("last_name"),
                data.get("date_of_birth"), data.get("gender"),
                data.get("grade"), data.get("section"),
                data.get("admission_date"), data.get("status"), student_id
            ))
            if not cursor.fetchone():
                return error_response("Student not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "students", student_id, "Student updated")

        connection.commit()
        return jsonify({"message": "Student updated", "student_id": student_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update student failed")
        return error_response("Student update failed", 400)
    finally:
        connection.close()


# ============================================================
# TEACHERS
# ============================================================

@app.route("/teachers", methods=["GET"])
def get_teachers():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_teacher():
                cursor.execute("""
                    SELECT teacher_id,user_id,employee_code,first_name,last_name,
                           department,qualification,joining_date,status
                    FROM teachers WHERE user_id=%s
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT teacher_id,user_id,employee_code,first_name,last_name,
                           department,qualification,joining_date,status
                    FROM teachers ORDER BY teacher_id
                """)
            rows = cursor.fetchall()

        keys = [
            "teacher_id", "user_id", "employee_code", "first_name",
            "last_name", "department", "qualification", "joining_date", "status"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/teachers", methods=["POST"])
def create_teacher():
    data = request.get_json(silent=True) or {}
    required = [
        "employee_code", "first_name", "last_name",
        "department", "qualification", "joining_date"
    ]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("All teacher fields are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            role_id = get_role_id(cursor, "Teacher")
            if role_id is None:
                return error_response("Teacher role is missing", 500)

            cursor.execute("""
                SELECT COALESCE(MAX(CAST(SUBSTRING(user_code FROM 4) AS INTEGER)),0)+1
                FROM users WHERE user_code ~ '^USR[0-9]+$'
            """)
            user_code = f"USR{cursor.fetchone()[0]:03d}"
            username = data["employee_code"].lower()

            cursor.execute("""
                INSERT INTO users
                (user_code,username,password_hash,role_id,account_status)
                VALUES (%s,%s,%s,%s,'ACTIVE')
                RETURNING user_id
            """, (
                user_code, username,
                generate_password_hash(data.get("password") or os.getenv("NEW_TEACHER_PASSWORD", "Teacher@123")),
                role_id
            ))
            user_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO teachers
                (user_id,employee_code,first_name,last_name,department,
                 qualification,joining_date,status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,'ACTIVE')
                RETURNING teacher_id
            """, (
                user_id, data["employee_code"], data["first_name"],
                data["last_name"], data["department"], data["qualification"],
                data["joining_date"]
            ))
            teacher_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "teachers", teacher_id, "Teacher created")

        connection.commit()
        return jsonify({
            "message": "Teacher created",
            "teacher_id": teacher_id,
            "username": username
        }), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create teacher failed")
        return error_response("Teacher creation failed", 400)
    finally:
        connection.close()


@app.route("/teachers/<int:teacher_id>", methods=["PUT"])
def update_teacher(teacher_id):
    if not is_admin():
        return error_response("Only administrators can update teacher profiles", 403)

    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE teachers
                SET first_name=COALESCE(%s,first_name),
                    last_name=COALESCE(%s,last_name),
                    department=COALESCE(%s,department),
                    qualification=COALESCE(%s,qualification),
                    joining_date=COALESCE(%s,joining_date),
                    status=COALESCE(%s,status)
                WHERE teacher_id=%s
                RETURNING teacher_id
            """, (
                data.get("first_name"), data.get("last_name"),
                data.get("department"), data.get("qualification"),
                data.get("joining_date"), data.get("status"), teacher_id
            ))
            if not cursor.fetchone():
                return error_response("Teacher not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "teachers", teacher_id, "Teacher updated")

        connection.commit()
        return jsonify({"message": "Teacher updated", "teacher_id": teacher_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update teacher failed")
        return error_response("Teacher update failed", 400)
    finally:
        connection.close()


# ============================================================
# PARENTS
# ============================================================

@app.route("/parents", methods=["GET"])
def get_parents():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_parent():
                cursor.execute("""
                    SELECT parent_id,user_id,parent_code,first_name,last_name,
                           phone_num,email,address,status
                    FROM parents WHERE user_id=%s
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT parent_id,user_id,parent_code,first_name,last_name,
                           phone_num,email,address,status
                    FROM parents ORDER BY parent_id
                """)
            rows = cursor.fetchall()

        keys = [
            "parent_id", "user_id", "parent_code", "first_name",
            "last_name", "phone_num", "email", "address", "status"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/parents", methods=["POST"])
def create_parent():
    data = request.get_json(silent=True) or {}
    required = ["parent_code", "first_name", "last_name", "phone_num", "email", "address"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("All parent fields are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            role_id = get_role_id(cursor, "Parent")
            if role_id is None:
                return error_response("Parent role is missing", 500)

            cursor.execute("""
                SELECT COALESCE(MAX(CAST(SUBSTRING(user_code FROM 4) AS INTEGER)),0)+1
                FROM users WHERE user_code ~ '^USR[0-9]+$'
            """)
            user_code = f"USR{cursor.fetchone()[0]:03d}"
            username = data["parent_code"].lower()

            cursor.execute("""
                INSERT INTO users
                (user_code,username,password_hash,email,phone_num,role_id,account_status)
                VALUES (%s,%s,%s,%s,%s,%s,'ACTIVE')
                RETURNING user_id
            """, (
                user_code, username,
                generate_password_hash(data.get("password") or os.getenv("NEW_PARENT_PASSWORD", "Parent@123")),
                data["email"], data["phone_num"], role_id
            ))
            user_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO parents
                (user_id,parent_code,first_name,last_name,phone_num,email,address,status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,'ACTIVE')
                RETURNING parent_id
            """, (
                user_id, data["parent_code"], data["first_name"],
                data["last_name"], data["phone_num"], data["email"], data["address"]
            ))
            parent_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "parents", parent_id, "Parent created")

        connection.commit()
        return jsonify({"message": "Parent created", "parent_id": parent_id, "username": username}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create parent failed")
        return error_response("Parent creation failed", 400)
    finally:
        connection.close()


@app.route("/parents/<int:parent_id>", methods=["PUT"])
def update_parent(parent_id):
    if not is_admin():
        return error_response("Only administrators can update parent profiles", 403)

    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE parents
                SET first_name=COALESCE(%s,first_name),
                    last_name=COALESCE(%s,last_name),
                    phone_num=COALESCE(%s,phone_num),
                    email=COALESCE(%s,email),
                    address=COALESCE(%s,address),
                    status=COALESCE(%s,status)
                WHERE parent_id=%s
                RETURNING parent_id
            """, (
                data.get("first_name"), data.get("last_name"),
                data.get("phone_num"), data.get("email"),
                data.get("address"), data.get("status"), parent_id
            ))
            if not cursor.fetchone():
                return error_response("Parent not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "parents", parent_id, "Parent updated")

        connection.commit()
        return jsonify({"message": "Parent updated", "parent_id": parent_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update parent failed")
        return error_response("Parent update failed", 400)
    finally:
        connection.close()


# ============================================================
# COURSES
# ============================================================

@app.route("/courses", methods=["GET"])
def get_courses():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT DISTINCT c.course_id,c.course_code,c.course_name,
                           c.description,c.grade,c.teacher_id,c.status
                    FROM courses c
                    JOIN enrollment e ON e.course_id=c.course_id
                    JOIN students s ON s.student_id=e.student_id
                    WHERE s.user_id=%s ORDER BY c.course_id
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT DISTINCT c.course_id,c.course_code,c.course_name,
                           c.description,c.grade,c.teacher_id,c.status
                    FROM courses c
                    JOIN enrollment e ON e.course_id=c.course_id
                    JOIN student_parents sp ON sp.student_id=e.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s ORDER BY c.course_id
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT c.course_id,c.course_code,c.course_name,
                           c.description,c.grade,c.teacher_id,c.status
                    FROM courses c
                    JOIN teachers t ON t.teacher_id=c.teacher_id
                    WHERE t.user_id=%s ORDER BY c.course_id
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT course_id,course_code,course_name,description,
                           grade,teacher_id,status
                    FROM courses ORDER BY course_id
                """)
            rows = cursor.fetchall()

        keys = ["course_id", "course_code", "course_name", "description", "grade", "teacher_id", "status"]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/courses", methods=["POST"])
def create_course():
    if not is_admin():
        return error_response("Only administrators can create courses", 403)

    data = request.get_json(silent=True) or {}
    required = ["course_code", "course_name", "grade", "teacher_id"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("course_code, course_name, grade and teacher_id are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO courses
                (course_code,course_name,description,grade,teacher_id,status)
                VALUES (%s,%s,%s,%s,%s,%s) RETURNING course_id
            """, (
                data["course_code"], data["course_name"], data.get("description"),
                data["grade"], data["teacher_id"], data.get("status", "ACTIVE")
            ))
            course_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "courses", course_id, "Course created")

        connection.commit()
        return jsonify({"message": "Course created", "course_id": course_id}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create course failed")
        return error_response("Course creation failed", 400)
    finally:
        connection.close()


@app.route("/courses/<int:course_id>", methods=["PUT"])
def update_course(course_id):
    if not is_admin():
        return error_response("Only administrators can update courses", 403)

    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE courses
                SET course_name=COALESCE(%s,course_name),
                    description=COALESCE(%s,description),
                    grade=COALESCE(%s,grade),
                    teacher_id=COALESCE(%s,teacher_id),
                    status=COALESCE(%s,status)
                WHERE course_id=%s RETURNING course_id
            """, (
                data.get("course_name"), data.get("description"), data.get("grade"),
                data.get("teacher_id"), data.get("status"), course_id
            ))
            if not cursor.fetchone():
                return error_response("Course not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "courses", course_id, "Course updated")

        connection.commit()
        return jsonify({"message": "Course updated", "course_id": course_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update course failed")
        return error_response("Course update failed", 400)
    finally:
        connection.close()


# ============================================================
# ENROLLMENT
# ============================================================

@app.route("/enrollment", methods=["GET"])
def get_enrollment():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT e.enrollment_id,e.student_id,e.course_id,e.enrollment_date,e.status
                    FROM enrollment e JOIN students s ON s.student_id=e.student_id
                    WHERE s.user_id=%s ORDER BY e.enrollment_id
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT e.enrollment_id,e.student_id,e.course_id,e.enrollment_date,e.status
                    FROM enrollment e
                    JOIN student_parents sp ON sp.student_id=e.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s ORDER BY e.enrollment_id
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT e.enrollment_id,e.student_id,e.course_id,e.enrollment_date,e.status
                    FROM enrollment e
                    JOIN courses c ON c.course_id=e.course_id
                    JOIN teachers t ON t.teacher_id=c.teacher_id
                    WHERE t.user_id=%s ORDER BY e.enrollment_id
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT enrollment_id,student_id,course_id,enrollment_date,status
                    FROM enrollment ORDER BY enrollment_id
                """)
            rows = cursor.fetchall()

        keys = ["enrollment_id", "student_id", "course_id", "enrollment_date", "status"]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/enrollment", methods=["POST"])
def create_enrollment():
    if not is_admin():
        return error_response("Only administrators can create enrollments", 403)

    data = request.get_json(silent=True) or {}
    required = ["student_id", "course_id", "enrollment_date"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("student_id, course_id and enrollment_date are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO enrollment(student_id,course_id,enrollment_date,status)
                VALUES (%s,%s,%s,%s) RETURNING enrollment_id
            """, (
                data["student_id"], data["course_id"], data["enrollment_date"],
                data.get("status", "ACTIVE")
            ))
            enrollment_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "enrollment", enrollment_id, "Enrollment created")

        connection.commit()
        return jsonify({"message": "Enrollment created", "enrollment_id": enrollment_id}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create enrollment failed")
        return error_response("Enrollment creation failed", 400)
    finally:
        connection.close()

        # ============================================================
# ATTENDANCE
# ============================================================

@app.route("/attendance", methods=["GET"])
def get_attendance():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT a.attendance_id,a.student_id,a.course_id,
                           a.attendance_date,a.attendance_status,a.recorded_by,a.remarks
                    FROM attendance a
                    JOIN students s ON s.student_id=a.student_id
                    WHERE s.user_id=%s ORDER BY a.attendance_date DESC
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT a.attendance_id,a.student_id,a.course_id,
                           a.attendance_date,a.attendance_status,a.recorded_by,a.remarks
                    FROM attendance a
                    JOIN student_parents sp ON sp.student_id=a.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s ORDER BY a.attendance_date DESC
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT a.attendance_id,a.student_id,a.course_id,
                           a.attendance_date,a.attendance_status,a.recorded_by,a.remarks
                    FROM attendance a
                    JOIN courses c ON c.course_id=a.course_id
                    JOIN teachers t ON t.teacher_id=c.teacher_id
                    WHERE t.user_id=%s ORDER BY a.attendance_date DESC
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT attendance_id,student_id,course_id,attendance_date,
                           attendance_status,recorded_by,remarks
                    FROM attendance ORDER BY attendance_date DESC
                """)
            rows = cursor.fetchall()

        keys = [
            "attendance_id", "student_id", "course_id", "attendance_date",
            "attendance_status", "recorded_by", "remarks"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/attendance", methods=["POST"])
def create_attendance():
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can record attendance", 403)

    data = request.get_json(silent=True) or {}
    required = ["student_id", "course_id", "attendance_date", "attendance_status"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("Attendance fields are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_teacher():
                teacher_id = get_current_teacher_id(cursor)
                cursor.execute(
                    "SELECT 1 FROM courses WHERE course_id=%s AND teacher_id=%s",
                    (data["course_id"], teacher_id)
                )
                if not cursor.fetchone():
                    return error_response("You can only record attendance for your own courses", 403)

            cursor.execute("""
                INSERT INTO attendance
                (student_id,course_id,attendance_date,attendance_status,recorded_by,remarks)
                VALUES (%s,%s,%s,%s,%s,%s)
                RETURNING attendance_id
            """, (
                data["student_id"], data["course_id"], data["attendance_date"],
                data["attendance_status"], g.user_id, data.get("remarks")
            ))
            attendance_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "attendance", attendance_id, "Attendance recorded")

        connection.commit()
        return jsonify({"message": "Attendance recorded", "attendance_id": attendance_id}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create attendance failed")
        return error_response("Attendance creation failed", 400)
    finally:
        connection.close()


@app.route("/attendance/<int:attendance_id>", methods=["PUT"])
def update_attendance(attendance_id):
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can update attendance", 403)

    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_teacher():
                teacher_id = get_current_teacher_id(cursor)
                cursor.execute("""
                    SELECT 1 FROM attendance a
                    JOIN courses c ON c.course_id=a.course_id
                    WHERE a.attendance_id=%s AND c.teacher_id=%s
                """, (attendance_id, teacher_id))
                if not cursor.fetchone():
                    return error_response("Attendance is not in your assigned courses", 403)

            cursor.execute("""
                UPDATE attendance
                SET attendance_status=COALESCE(%s,attendance_status),
                    remarks=COALESCE(%s,remarks)
                WHERE attendance_id=%s
                RETURNING attendance_id
            """, (
                data.get("attendance_status"), data.get("remarks"), attendance_id
            ))
            if not cursor.fetchone():
                return error_response("Attendance record not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "attendance", attendance_id, "Attendance updated")

        connection.commit()
        return jsonify({"message": "Attendance updated", "attendance_id": attendance_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update attendance failed")
        return error_response("Attendance update failed", 400)
    finally:
        connection.close()


# ============================================================
# ASSIGNMENTS
# ============================================================

@app.route("/assignments", methods=["GET"])
def get_assignments():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT DISTINCT a.assignment_id,a.course_id,a.teacher_id,a.title,
                           a.description,a.assigned_date,a.due_date,a.status
                    FROM assignments a
                    JOIN enrollment e ON e.course_id=a.course_id
                    JOIN students s ON s.student_id=e.student_id
                    WHERE s.user_id=%s ORDER BY a.assignment_id
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT DISTINCT a.assignment_id,a.course_id,a.teacher_id,a.title,
                           a.description,a.assigned_date,a.due_date,a.status
                    FROM assignments a
                    JOIN enrollment e ON e.course_id=a.course_id
                    JOIN student_parents sp ON sp.student_id=e.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s ORDER BY a.assignment_id
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT a.assignment_id,a.course_id,a.teacher_id,a.title,
                           a.description,a.assigned_date,a.due_date,a.status
                    FROM assignments a
                    JOIN teachers t ON t.teacher_id=a.teacher_id
                    WHERE t.user_id=%s ORDER BY a.assignment_id
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT assignment_id,course_id,teacher_id,title,description,
                           assigned_date,due_date,status
                    FROM assignments ORDER BY assignment_id
                """)
            rows = cursor.fetchall()

        keys = [
            "assignment_id", "course_id", "teacher_id", "title",
            "description", "assigned_date", "due_date", "status"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


@app.route("/assignments", methods=["POST"])
def create_assignment():
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can create assignments", 403)

    data = request.get_json(silent=True) or {}
    required = ["course_id", "title", "assigned_date", "due_date"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("course_id, title, assigned_date and due_date are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            teacher_id = get_current_teacher_id(cursor) if is_teacher() else data.get("teacher_id")
            if is_teacher():
                cursor.execute(
                    "SELECT 1 FROM courses WHERE course_id=%s AND teacher_id=%s",
                    (data["course_id"], teacher_id)
                )
                if not cursor.fetchone():
                    return error_response("You can only create assignments for your own courses", 403)

            if not teacher_id:
                return error_response("teacher_id is required for administrator-created assignments")

            cursor.execute("""
                INSERT INTO assignments
                (course_id,teacher_id,title,description,assigned_date,due_date,status)
                VALUES (%s,%s,%s,%s,%s,%s,%s)
                RETURNING assignment_id
            """, (
                data["course_id"], teacher_id, data["title"], data.get("description"),
                data["assigned_date"], data["due_date"], data.get("status", "ACTIVE")
            ))
            assignment_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "assignments", assignment_id, "Assignment created")

        connection.commit()
        return jsonify({"message": "Assignment created", "assignment_id": assignment_id}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create assignment failed")
        return error_response("Assignment creation failed", 400)
    finally:
        connection.close()


@app.route("/assignments/<int:assignment_id>", methods=["PUT"])
def update_assignment(assignment_id):
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can update assignments", 403)

    data = request.get_json(silent=True) or {}
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_teacher():
                teacher_id = get_current_teacher_id(cursor)
                cursor.execute(
                    "SELECT 1 FROM assignments WHERE assignment_id=%s AND teacher_id=%s",
                    (assignment_id, teacher_id)
                )
                if not cursor.fetchone():
                    return error_response("You can only update your own assignments", 403)

            cursor.execute("""
                UPDATE assignments
                SET title=COALESCE(%s,title),
                    description=COALESCE(%s,description),
                    assigned_date=COALESCE(%s,assigned_date),
                    due_date=COALESCE(%s,due_date),
                    status=COALESCE(%s,status)
                WHERE assignment_id=%s
                RETURNING assignment_id
            """, (
                data.get("title"), data.get("description"), data.get("assigned_date"),
                data.get("due_date"), data.get("status"), assignment_id
            ))
            if not cursor.fetchone():
                return error_response("Assignment not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "assignments", assignment_id, "Assignment updated")

        connection.commit()
        return jsonify({"message": "Assignment updated", "assignment_id": assignment_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update assignment failed")
        return error_response("Assignment update failed", 400)
    finally:
        connection.close()


# ============================================================
# MARKS
# ============================================================

@app.route("/marks", methods=["GET"])
def get_marks():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_student():
                cursor.execute("""
                    SELECT m.marks_id,m.student_id,m.assignment_id,m.marks_obtained,
                           m.maximum_marks,m.grade,m.evaluated_by,m.evaluated_at
                    FROM marks m
                    JOIN students s ON s.student_id=m.student_id
                    WHERE s.user_id=%s ORDER BY m.marks_id
                """, (g.user_id,))
            elif is_parent():
                cursor.execute("""
                    SELECT m.marks_id,m.student_id,m.assignment_id,m.marks_obtained,
                           m.maximum_marks,m.grade,m.evaluated_by,m.evaluated_at
                    FROM marks m
                    JOIN student_parents sp ON sp.student_id=m.student_id
                    JOIN parents p ON p.parent_id=sp.parent_id
                    WHERE p.user_id=%s ORDER BY m.marks_id
                """, (g.user_id,))
            elif is_teacher():
                cursor.execute("""
                    SELECT m.marks_id,m.student_id,m.assignment_id,m.marks_obtained,
                           m.maximum_marks,m.grade,m.evaluated_by,m.evaluated_at
                    FROM marks m
                    JOIN assignments a ON a.assignment_id=m.assignment_id
                    JOIN teachers t ON t.teacher_id=a.teacher_id
                    WHERE t.user_id=%s ORDER BY m.marks_id
                """, (g.user_id,))
            else:
                cursor.execute("""
                    SELECT marks_id,student_id,assignment_id,marks_obtained,
                           maximum_marks,grade,evaluated_by,evaluated_at
                    FROM marks ORDER BY marks_id
                """)
            rows = cursor.fetchall()

        keys = [
            "mark_id", "student_id", "assignment_id", "marks_obtained",
            "maximum_marks", "grade", "evaluated_by", "evaluated_at"
        ]
        result = []
        for row in rows:
            item = dict(zip(keys, row))
            if item["marks_obtained"] is not None:
                item["marks_obtained"] = float(item["marks_obtained"])
            if item["maximum_marks"] is not None:
                item["maximum_marks"] = float(item["maximum_marks"])
            if item["evaluated_at"] is not None:
                item["evaluated_at"] = item["evaluated_at"].isoformat()
            result.append(item)
        return jsonify(result)
    finally:
        connection.close()


@app.route("/marks", methods=["POST"])
def create_mark():
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can enter marks", 403)

    data = request.get_json(silent=True) or {}
    required = ["student_id", "assignment_id", "marks_obtained", "maximum_marks", "grade"]
    if any(data.get(k) in (None, "") for k in required):
        return error_response("All marks fields are required")

    try:
        obtained = float(data["marks_obtained"])
        maximum = float(data["maximum_marks"])
        if maximum <= 0 or obtained < 0 or obtained > maximum:
            return error_response("Marks must be between zero and maximum marks")
    except (TypeError, ValueError):
        return error_response("Marks must be numeric")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT a.teacher_id,a.course_id
                FROM assignments a WHERE a.assignment_id=%s
            """, (data["assignment_id"],))
            assignment = cursor.fetchone()
            if not assignment:
                return error_response("Assignment not found", 404)

            if is_teacher():
                teacher_id = get_current_teacher_id(cursor)
                if assignment[0] != teacher_id:
                    return error_response("You can only grade your own assignments", 403)

            cursor.execute("""
                INSERT INTO marks
                (student_id,assignment_id,marks_obtained,maximum_marks,grade,evaluated_by)
                VALUES (%s,%s,%s,%s,%s,%s)
                RETURNING marks_id
            """, (
                data["student_id"], data["assignment_id"], obtained, maximum,
                data["grade"], g.user_id
            ))
            mark_id = cursor.fetchone()[0]
            write_audit(cursor, g.user_id, "CREATE", "marks", mark_id, "Marks recorded")

        connection.commit()
        return jsonify({"message": "Marks saved", "mark_id": mark_id}), 201
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Create marks failed")
        return error_response("Could not save marks", 400)
    finally:
        connection.close()


@app.route("/marks/<int:mark_id>", methods=["PUT"])
def update_mark(mark_id):
    if not (is_admin() or is_teacher()):
        return error_response("Only administrators and teachers can update marks", 403)

    data = request.get_json(silent=True) or {}
    try:
        obtained = float(data["marks_obtained"])
        maximum = float(data["maximum_marks"])
        if maximum <= 0 or obtained < 0 or obtained > maximum:
            return error_response("Marks must be between zero and maximum marks")
    except (KeyError, TypeError, ValueError):
        return error_response("Valid marks_obtained and maximum_marks are required")

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            if is_teacher():
                teacher_id = get_current_teacher_id(cursor)
                cursor.execute("""
                    SELECT 1 FROM marks m
                    JOIN assignments a ON a.assignment_id=m.assignment_id
                    WHERE m.marks_id=%s AND a.teacher_id=%s
                """, (mark_id, teacher_id))
                if not cursor.fetchone():
                    return error_response("You can only update marks for your own assignments", 403)

            cursor.execute("""
                UPDATE marks
                SET marks_obtained=%s,maximum_marks=%s,grade=%s,
                    evaluated_by=%s,evaluated_at=CURRENT_TIMESTAMP
                WHERE marks_id=%s RETURNING marks_id
            """, (obtained, maximum, data.get("grade"), g.user_id, mark_id))
            if not cursor.fetchone():
                return error_response("Mark not found", 404)
            write_audit(cursor, g.user_id, "UPDATE", "marks", mark_id, "Marks updated")

        connection.commit()
        return jsonify({"message": "Marks updated", "mark_id": mark_id})
    except psycopg2.Error:
        connection.rollback()
        app.logger.exception("Update marks failed")
        return error_response("Marks update failed", 400)
    finally:
        connection.close()


# ============================================================
# AUDIT LOGS — ADMIN ONLY
# ============================================================

@app.route("/audit-logs", methods=["GET"])
def get_audit_logs():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT log_id,user_id,action,table_name,record_id,
                       action_timestamp,ip_address,description
                FROM audit_log
                ORDER BY action_timestamp DESC
                LIMIT 200
            """)
            rows = cursor.fetchall()

        keys = [
            "log_id", "user_id", "action", "table_name", "record_id",
            "action_timestamp", "ip_address", "description"
        ]
        return jsonify([dict(zip(keys, row)) for row in rows])
    finally:
        connection.close()


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":
    app.run(
        host=os.getenv("FLASK_HOST", "127.0.0.1"),
        port=int(os.getenv("PORT", "5000")),
        debug=os.getenv("FLASK_DEBUG", "1") == "1",
    )