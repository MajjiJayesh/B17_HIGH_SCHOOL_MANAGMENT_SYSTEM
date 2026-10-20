CREATE TABLE Roles (
    Role_id BIGSERIAL PRIMARY KEY,
    Role_code VARCHAR(50) NOT NULL UNIQUE,
    Role_name VARCHAR(50) NOT NULL,
    Description TEXT,
    Priority_Level SMALLINT,
    is_System_role BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);


CREATE TABLE Users (
    User_id BIGSERIAL PRIMARY KEY,
    User_code VARCHAR(50) NOT NULL UNIQUE,
    Username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_num VARCHAR(15),
    Role_id BIGINT NOT NULL,
    account_status VARCHAR(20) DEFAULT 'ACTIVE',
    last_login TIMESTAMP WITH TIME ZONE,
    failed_login_attempt SMALLINT DEFAULT 0,
    password_last_changed TIMESTAMP WITH TIME ZONE,
    Created_At TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Created_By BIGINT,
    Updated_By BIGINT,

    CONSTRAINT fk_users_role
        FOREIGN KEY (Role_id)
        REFERENCES Roles(Role_id)
);


CREATE TABLE Teachers (
    Teacher_id BIGSERIAL PRIMARY KEY,
    User_id BIGINT NOT NULL UNIQUE,
    Employee_code VARCHAR(50) NOT NULL UNIQUE,
    First_name VARCHAR(100) NOT NULL,
    Last_name VARCHAR(100),
    Department VARCHAR(100),
    Qualification VARCHAR(150),
    Joining_date DATE,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_teacher_user
        FOREIGN KEY (User_id)
        REFERENCES Users(User_id)
);


CREATE TABLE Parents (
    Parent_id BIGSERIAL PRIMARY KEY,
    User_id BIGINT NOT NULL UNIQUE,
    Parent_code VARCHAR(50) NOT NULL UNIQUE,
    First_name VARCHAR(100) NOT NULL,
    Last_name VARCHAR(100),
    Phone_num VARCHAR(15),
    Email VARCHAR(255),
    Address TEXT,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_parent_user
        FOREIGN KEY (User_id)
        REFERENCES Users(User_id)
);


CREATE TABLE Students (
    Student_id BIGSERIAL PRIMARY KEY,
    User_id BIGINT NOT NULL UNIQUE,
    Student_code VARCHAR(50) NOT NULL UNIQUE,
    First_name VARCHAR(100) NOT NULL,
    Last_name VARCHAR(100),
    Date_of_birth DATE,
    Gender VARCHAR(20),
    Grade SMALLINT,
    Section VARCHAR(10),
    Admission_date DATE,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_student_user
        FOREIGN KEY (User_id)
        REFERENCES Users(User_id)
);


CREATE TABLE Student_Parents (
    Student_parent_id BIGSERIAL PRIMARY KEY,
    Student_id BIGINT NOT NULL,
    Parent_id BIGINT NOT NULL,
    Relationship VARCHAR(50),
    Is_primary_contact BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_student_parent_student
        FOREIGN KEY (Student_id)
        REFERENCES Students(Student_id),

    CONSTRAINT fk_student_parent_parent
        FOREIGN KEY (Parent_id)
        REFERENCES Parents(Parent_id),

    CONSTRAINT unique_student_parent
        UNIQUE (Student_id, Parent_id)
);


CREATE TABLE Courses (
    Course_id BIGSERIAL PRIMARY KEY,
    Course_code VARCHAR(50) NOT NULL UNIQUE,
    Course_name VARCHAR(100) NOT NULL,
    Description TEXT,
    Grade SMALLINT,
    Teacher_id BIGINT,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_course_teacher
        FOREIGN KEY (Teacher_id)
        REFERENCES Teachers(Teacher_id)
);


CREATE TABLE Enrollment (
    Enrollment_id BIGSERIAL PRIMARY KEY,
    Student_id BIGINT NOT NULL,
    Course_id BIGINT NOT NULL,
    Enrollment_date DATE DEFAULT CURRENT_DATE,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (Student_id)
        REFERENCES Students(Student_id),

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (Course_id)
        REFERENCES Courses(Course_id),

    CONSTRAINT unique_student_course
        UNIQUE (Student_id, Course_id)
);


CREATE TABLE Attendance (
    Attendance_id BIGSERIAL PRIMARY KEY,
    Student_id BIGINT NOT NULL,
    Course_id BIGINT NOT NULL,
    Attendance_date DATE NOT NULL,
    Attendance_status VARCHAR(20) NOT NULL,
    Recorded_by BIGINT,

    CONSTRAINT fk_attendance_student
        FOREIGN KEY (Student_id)
        REFERENCES Students(Student_id),

    CONSTRAINT fk_attendance_course
        FOREIGN KEY (Course_id)
        REFERENCES Courses(Course_id),

    CONSTRAINT fk_attendance_user
        FOREIGN KEY (Recorded_by)
        REFERENCES Users(User_id),

    CONSTRAINT unique_attendance
        UNIQUE (Student_id, Course_id, Attendance_date)
);


CREATE TABLE Assignments (
    Assignment_id BIGSERIAL PRIMARY KEY,
    Course_id BIGINT NOT NULL,
    Teacher_id BIGINT NOT NULL,
    Title VARCHAR(200) NOT NULL,
    Description TEXT,
    Assigned_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Due_date TIMESTAMP WITH TIME ZONE,
    Status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_assignment_course
        FOREIGN KEY (Course_id)
        REFERENCES Courses(Course_id),

    CONSTRAINT fk_assignment_teacher
        FOREIGN KEY (Teacher_id)
        REFERENCES Teachers(Teacher_id)
);


CREATE TABLE Marks (
    Marks_id BIGSERIAL PRIMARY KEY,
    Student_id BIGINT NOT NULL,
    Assignment_id BIGINT NOT NULL,
    Marks_obtained NUMERIC(5,2) NOT NULL,
    Maximum_marks NUMERIC(5,2) NOT NULL,
    Grade VARCHAR(5),
    Evaluated_by BIGINT,
    Evaluated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_marks_student
        FOREIGN KEY (Student_id)
        REFERENCES Students(Student_id),

    CONSTRAINT fk_marks_assignment
        FOREIGN KEY (Assignment_id)
        REFERENCES Assignments(Assignment_id),

    CONSTRAINT fk_marks_teacher
        FOREIGN KEY (Evaluated_by)
        REFERENCES Teachers(Teacher_id)
);


CREATE TABLE Audit_Log (
    Log_id BIGSERIAL PRIMARY KEY,
    User_id BIGINT,
    Action VARCHAR(100) NOT NULL,
    Table_name VARCHAR(100),
    Record_id BIGINT,
    Action_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    IP_address INET,
    Description TEXT,

    CONSTRAINT fk_audit_user
        FOREIGN KEY (User_id)
        REFERENCES Users(User_id)
);



SELECT DISTINCT attendance_status
FROM attendance
ORDER BY attendance_status;



