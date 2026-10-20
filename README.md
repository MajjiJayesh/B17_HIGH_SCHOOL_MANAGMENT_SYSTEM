# ZERO-TRUST HIGH SCHOOL MANAGEMENT SYSTEM
### 23AIE303 – Database Management Systems Project
**Department of Artificial Intelligence Engineering | Amrita School of Computing, Coimbatore**

---

## 1. Project Title & Team Details

* **Project Title:** Zero-Trust High School Management System
* **Course:** 23AIE303 – Database Management Systems
* **Batch / Group:** Team 17 | Batch 2 (2024–2028)
* **Database Engine:** PostgreSQL 16 (Relational Database Management System)

### Team Members & Contributions
| Student Name | Roll Number | Key Academic & DBMS Project Contributions |
| :--- | :--- | :--- |
| **K. Siva Aditya** | `CB.SC.U4AIE24126` | Relational Schema Modeling, Referential Constraints, 1NF to BCNF Normalization |
| **M. Jayesh** | `CB.SC.U4AIE24128` | PostgreSQL Database Architecture, Zero-Trust Access Layer, REST APIs |
| **N. Srinivas** | `CB.SC.U4AIE24140` | Frontend Interface, Role-Based Access Control, Security Audit Logging |
| **MV. Mukesh** | `CB.SC.U4AIE24138` | Database DDL/DML, Advanced Multi-Table Queries, Subqueries & Aggregations |

---

## 2. Project Overview & Problem Statement

### 2.1 Project Overview
The **Zero-Trust High School Management System** is a relational database application designed to centralize and secure the complete academic lifecycle of secondary school institutions. Built upon **PostgreSQL 16** with a modern application interface, the system manages twelve core academic domains: **Users, Roles, Students, Teachers, Parents, Student-Parent linkages, Courses, Enrollment, Daily Attendance, Assignments, Exam Marks**, and **System Audit Logs**.

The system adheres to the modern security architecture principle **"Never Trust, Always Verify"** (Zero-Trust) at the database layer:
1. Every access requires explicit identity authentication via cryptographic password hashing (`scrypt`) and role authorization.
2. Granular Role-Based Access Control (RBAC) enforces least-privilege permissions across 4 institutional roles (Admin, Teacher, Student, Parent).
3. Every state-altering database operation is atomically committed and recorded in an immutable, tamper-evident `Audit_Log` table with client IP addresses and UTC timestamps.
4. Parameterized SQL queries via `psycopg2` ensure 100% immunity against SQL injection vulnerabilities.

### 2.2 Problem Statement & Deficiencies in Existing Systems
Traditional high school administration suffers from severe structural and relational limitations:
* **Fragmented Spreadsheets & Data Redundancy:** Disconnected registers across academic departments cause update anomalies, duplicate data, and desynchronized records.
* **Privilege Escalation & Unauthorized Access:** Coarse access controls allow students or unauthorized users to view and tamper with confidential examination marks and attendance logs.
* **Absence of Mutation Auditing:** When academic records are altered, administrators cannot determine who made the change, when it occurred, or which IP address initiated it.
* **SQL Injection Vulnerabilities:** Naïve dynamic string concatenations in legacy school systems expose entire databases to exfiltration or corruption.

---

## 3. Conceptual & Logical Database Design

### 3.1 Core Relational Entities
1. `Roles`: Defines system authorization levels (Administrator, Teacher, Student, Parent).
2. `Users`: System accounts, scrypt password hashes, email, phone, and account status.
3. `Teachers`: Faculty employment data, department, qualification, joining date.
4. `Parents`: Guardian contact information, address, and status.
5. `Students`: Student demographic data, birth date, gender, grade level, section.
6. `Student_Parents`: Associative table resolving M:N relationships between students and guardians.
7. `Courses`: Academic subjects offered, target grade level, assigned teacher.
8. `Enrollment`: Associative table resolving M:N student course enrollments.
9. `Attendance`: Daily class attendance logs (PRESENT, ABSENT, LATE) with recorder user tracking.
10. `Assignments`: Homework, projects, and tests assigned by faculty.
11. `Marks`: Evaluated scores, maximum marks, letter grade, and evaluating faculty.
12. `Audit_Log`: Immutable system security log tracking user IDs, actions, table names, record IDs, IP addresses, and timestamps.

### 3.2 Cardinality & Relationship Constraints
* `Roles` → `Users`: **1 : N** (One role assigned to multiple users; role deletion restricted).
* `Users` → `Profiles`: **1 : 1** (Each specialized profile references `Users.user_id` with `ON DELETE CASCADE`).
* `Students` ↔ `Parents`: **M : N** (Resolved via `Student_Parents` with `UNIQUE(student_id, parent_id)`).
* `Teachers` → `Courses`: **1 : N** (`Courses.teacher_id` references `Teachers.teacher_id` with `ON DELETE SET NULL`).
* `Students` ↔ `Courses`: **M : N** (Resolved via `Enrollment` with `UNIQUE(student_id, course_id)`).
* `Courses` → `Attendance`: **1 : N** (Enforces `CHECK (attendance_status IN ('PRESENT', 'ABSENT', 'LATE'))`).
* `Assignments` ↔ `Students` → `Marks`: **M : N** (Enforces `CHECK (marks_obtained >= 0 AND marks_obtained <= maximum_marks)`).
* `Users` → `Audit_Log`: **1 : N** (Immutable append-only operational audit trail).

---

## 4. Normalization in Our Project: 1NF to BCNF

The relational schema is mathematically normalized from **1NF through BCNF**:
* **1NF (First Normal Form):** All attribute domains contain strictly atomic values. Multi-valued parent contacts were factored into `Student_Parents` and course lists into `Enrollment`. Defined primary keys for all 12 tables.
* **2NF (Second Normal Form):** Satisfies 1NF. Eliminates partial functional dependencies. In associative relations with composite keys (`Student_Parents`, `Enrollment`, `Marks`), non-prime attributes (e.g. `marks_obtained`, `relationship`) depend strictly upon the complete composite candidate key.
* **3NF (Third Normal Form):** Satisfies 2NF. Eliminates transitive functional dependencies ($X \to Y$, $Y \to Z$). Course faculty information resides strictly within `Teachers`; user credentials reside strictly within `Users`.
* **BCNF (Boyce-Codd Normal Form):** For every non-trivial functional dependency $X \to Y$, determinant $X$ is strictly a superkey. No non-trivial dependencies exist on non-candidate keys. The decomposition is strictly **lossless** and preserves all functional dependencies.

---

## 5. Advanced SQL Implementation & Complex Queries

The repository includes `database/advanced_queries.sql` showcasing:
1. **Multi-Table Relational JOINs:** 5-table INNER/LEFT JOIN generating complete academic report cards across `Students`, `Enrollment`, `Courses`, `Assignments`, `Marks`, and `Teachers`.
2. **Analytical Aggregations:** Computes class average marks, maximum scores, minimum scores, and enrollment headcounts grouped by subject using `COUNT()`, `AVG()`, `MAX()`, `MIN()`, and filtered with `HAVING AVG(marks_obtained) >= 70.0`.
3. **Correlated Subqueries & CASE Logic:** Automated early-warning query detecting students whose attendance percentage falls below the 75% institutional threshold in any active course.
4. **ACID Transactions:** Enrollment workflows wrapped with `BEGIN`, atomic inserts into `Enrollment` and `Audit_Log`, and `COMMIT` with automatic rollback on exception.
5. **Parameterized Prepared Queries:** All 59 backend SQL statements execute using `%s` parameter binding, guaranteeing isolation against SQL injection attacks.

---

## 6. Installation, Setup & Local Execution Instructions

### Prerequisites
* Python 3.10+ installed
* PostgreSQL 14+ installed locally
* Web browser (Chrome, Edge, Firefox)

### Step 1: Navigate to Project Directory
```powershell
cd "d:\high school dbms"
```

### Step 2: Set Up Virtual Environment & Dependencies
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt
```

### Step 3: Populate the Relational Database
Ensure PostgreSQL is running locally, then initialize the tables and seed data:
```powershell
# Create database
psql -U postgres -c "CREATE DATABASE high_school_management;"

# Execute DDL schema and initial seed
psql -U postgres -d high_school_management -f database/DBMS.sql
psql -U postgres -d high_school_management -f database/cloud_db_seed.sql
```

### Step 4: Configure Database Connection
Set environment variables or create `.env` inside `backend/`:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=high_school_management
DB_USER=postgres
DB_PASSWORD=your_local_password
DB_SSLMODE=disable
SECRET_KEY=your_secure_secret_key_2026
PORT=5000
```

### Step 5: Run the Backend Service
```powershell
cd backend
python app.py
```
Backend API will start listening on `http://127.0.0.1:5000`.

### Step 6: Access the Application
Open `http://127.0.0.1:5000/` in any web browser to interact with the system.

### Demo User Accounts for Review:
| System Role | Username | Password | Access Capabilities |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin01` | `Admin@123` | Full administrative oversight, user management, course master lists, audit logs |
| **Teacher** | `teacher01` | `Teacher@123` | Course grading, attendance marking, student marks evaluation |
| **Student** | `student01` | `Student@123` | Enrolled courses, personal attendance percentages, published report cards |
| **Parent** | `parent01` | `Parent@123` | Linked ward monitoring, attendance alerts, exam scorecards |
