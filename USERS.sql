INSERT INTO Roles
(Role_code, Role_name, Description, Priority_Level, is_System_role, status)
VALUES
('SUPER_ADMIN', 'Super Administrator', 'Full system administration access', 100, TRUE, 'ACTIVE'),
('ADMIN', 'Administrator', 'Manages school users and operations', 90, TRUE, 'ACTIVE'),
('TEACHER', 'Teacher', 'Manages academic activities', 60, TRUE, 'ACTIVE'),
('STUDENT', 'Student', 'Accesses academic information', 20, TRUE, 'ACTIVE'),
('PARENT', 'Parent', 'Views student academic information', 10, TRUE, 'ACTIVE');


INSERT INTO Users
(User_code, Username, password_hash, email, phone_num, Role_id, account_status)
VALUES
('USR001', 'admin01', 'hashed_admin_password', 'admin@school.com', '9876543210', 1, 'ACTIVE'),
('USR002', 'teacher01', 'hashed_teacher_password', 'teacher@school.com', '9876543211', 3, 'ACTIVE'),
('USR003', 'student01', 'hashed_student_password', 'student@school.com', '9876543212', 4, 'ACTIVE'),
('USR004', 'parent01', 'hashed_parent_password', 'parent@school.com', '9876543213', 5, 'ACTIVE');
INSERT INTO Users
(User_code, Username, password_hash, email, phone_num, Role_id, account_status)
VALUES
('USR006', 'teacher02', 'hashed_teacher_password', 'teacher2@school.com', '9876543214', 3, 'ACTIVE'),
('USR007', 'teacher03', 'hashed_teacher_password', 'teacher3@school.com', '9876543215', 3, 'ACTIVE'),
('USR008', 'student02', 'hashed_student_password', 'student2@school.com', '9876543216', 4, 'ACTIVE'),
('USR009', 'student03', 'hashed_student_password', 'student3@school.com', '9876543217', 4, 'ACTIVE'),
('USR010', 'parent02', 'hashed_parent_password', 'parent2@school.com', '9876543218', 5, 'ACTIVE'),
('USR011', 'parent03', 'hashed_parent_password', 'parent3@school.com', '9876543219', 5, 'ACTIVE');

INSERT INTO Users
(User_code, Username, password_hash, email, phone_num, Role_id, account_status)
VALUES
('USR012', 'teacher04', 'hashed_teacher_password', 'teacher4@school.com', '9876543220', 3, 'ACTIVE'),
('USR013', 'teacher05', 'hashed_teacher_password', 'teacher5@school.com', '9876543221', 3, 'ACTIVE'),
('USR014', 'teacher06', 'hashed_teacher_password', 'teacher6@school.com', '9876543222', 3, 'ACTIVE'),
('USR015', 'teacher07', 'hashed_teacher_password', 'teacher7@school.com', '9876543223', 3, 'ACTIVE'),
('USR016', 'teacher08', 'hashed_teacher_password', 'teacher8@school.com', '9876543224', 3, 'ACTIVE'),
('USR017', 'teacher09', 'hashed_teacher_password', 'teacher9@school.com', '9876543225', 3, 'ACTIVE'),
('USR018', 'teacher10', 'hashed_teacher_password', 'teacher10@school.com', '9876543226', 3, 'ACTIVE');

INSERT INTO Users
(User_code, Username, password_hash, email, phone_num, Role_id, account_status)
VALUES
('USR019', 'student04', 'hashed_student_password', 'student4@school.com', '9876543227', 4, 'ACTIVE'),
('USR020', 'student05', 'hashed_student_password', 'student5@school.com', '9876543228', 4, 'ACTIVE'),
('USR021', 'student06', 'hashed_student_password', 'student6@school.com', '9876543229', 4, 'ACTIVE'),
('USR022', 'student07', 'hashed_student_password', 'student7@school.com', '9876543230', 4, 'ACTIVE'),
('USR023', 'student08', 'hashed_student_password', 'student8@school.com', '9876543231', 4, 'ACTIVE'),
('USR024', 'student09', 'hashed_student_password', 'student9@school.com', '9876543232', 4, 'ACTIVE'),
('USR025', 'student10', 'hashed_student_password', 'student10@school.com', '9876543233', 4, 'ACTIVE'),
('USR026', 'student11', 'hashed_student_password', 'student11@school.com', '9876543234', 4, 'ACTIVE'),
('USR027', 'student12', 'hashed_student_password', 'student12@school.com', '9876543235', 4, 'ACTIVE'),
('USR028', 'student13', 'hashed_student_password', 'student13@school.com', '9876543236', 4, 'ACTIVE'),
('USR029', 'student14', 'hashed_student_password', 'student14@school.com', '9876543237', 4, 'ACTIVE'),
('USR030', 'student15', 'hashed_student_password', 'student15@school.com', '9876543238', 4, 'ACTIVE'),
('USR031', 'student16', 'hashed_student_password', 'student16@school.com', '9876543239', 4, 'ACTIVE'),
('USR032', 'student17', 'hashed_student_password', 'student17@school.com', '9876543240', 4, 'ACTIVE'),
('USR033', 'student18', 'hashed_student_password', 'student18@school.com', '9876543241', 4, 'ACTIVE'),
('USR034', 'student19', 'hashed_student_password', 'student19@school.com', '9876543242', 4, 'ACTIVE'),
('USR035', 'student20', 'hashed_student_password', 'student20@school.com', '9876543243', 4, 'ACTIVE');


INSERT INTO Users
(User_code, Username, password_hash, email, phone_num, Role_id, account_status)
VALUES
('USR036', 'parent04', 'hashed_parent_password', 'parent4@school.com', '9876543244', 5, 'ACTIVE'),
('USR037', 'parent05', 'hashed_parent_password', 'parent5@school.com', '9876543245', 5, 'ACTIVE'),
('USR038', 'parent06', 'hashed_parent_password', 'parent6@school.com', '9876543246', 5, 'ACTIVE'),
('USR039', 'parent07', 'hashed_parent_password', 'parent7@school.com', '9876543247', 5, 'ACTIVE'),
('USR040', 'parent08', 'hashed_parent_password', 'parent8@school.com', '9876543248', 5, 'ACTIVE'),
('USR041', 'parent09', 'hashed_parent_password', 'parent9@school.com', '9876543249', 5, 'ACTIVE'),
('USR042', 'parent10', 'hashed_parent_password', 'parent10@school.com', '9876543250', 5, 'ACTIVE');
ins
-- ============================================

-- ============================================
-- 1. TEACHERS
-- ============================================

INSERT INTO Teachers
(User_id, Employee_code, First_name, Last_name, Department, Qualification, Joining_date, Status)
VALUES
(2, 'EMP001', 'Anita', 'Sharma', 'Mathematics', 'M.Sc Mathematics', '2022-06-15', 'ACTIVE');

INSERT INTO Teachers
(User_id, Employee_code, First_name, Last_name, Department, Qualification, Joining_date, Status)
VALUES
(7, 'EMP002', 'Ravi', 'Kumar', 'Science', 'M.Sc Physics', '2021-06-15', 'ACTIVE'),
(8, 'EMP003', 'Priya', 'Reddy', 'English', 'M.A English', '2022-06-15', 'ACTIVE'),
(13, 'EMP004', 'Rahul', 'Sharma', 'Computer Science', 'M.Tech Computer Science', '2020-07-10', 'ACTIVE'),
(14, 'EMP005', 'Sneha', 'Rao', 'Social Studies', 'M.A History', '2023-06-20', 'ACTIVE'),
(15, 'EMP006', 'Kiran', 'Patel', 'Physics', 'M.Sc Physics', '2021-08-12', 'ACTIVE'),
(16, 'EMP007', 'Meena', 'Das', 'Chemistry', 'M.Sc Chemistry', '2022-07-05', 'ACTIVE'),
(17, 'EMP008', 'Vijay', 'Singh', 'Biology', 'M.Sc Biology', '2020-06-18', 'ACTIVE'),
(18, 'EMP009', 'Kavya', 'Nair', 'Mathematics', 'M.Sc Mathematics', '2023-06-12', 'ACTIVE'),
(19, 'EMP010', 'Arun', 'Verma', 'Computer Science', 'M.Tech Computer Science', '2021-07-15', 'ACTIVE');


-- 2. PARENTS
-- ============================================

INSERT INTO Parents
(User_id, Parent_code, First_name, Last_name, Phone_num, Email, Address, Status)
VALUES
(4, 'PAR001', 'Rajesh', 'Kumar', '9876543213',
 'parent@school.com', 'Bangalore, Karnataka', 'ACTIVE');

 INSERT INTO Parents
(User_id, Parent_code, First_name, Last_name, Phone_num, Email, Address, Status)
VALUES
(11, 'PAR002', 'Suresh', 'Kumar', '9876543211', 'parent2@school.com', 'Bangalore, Karnataka', 'ACTIVE'),
(12, 'PAR003', 'Lakshmi', 'Reddy', '9876543212', 'parent3@school.com', 'Hyderabad, Telangana', 'ACTIVE'),
(37, 'PAR004', 'Mohan', 'Sharma', '9876543251', 'parent4@school.com', 'Bangalore, Karnataka', 'ACTIVE'),
(38, 'PAR005', 'Sunita', 'Patel', '9876543252', 'parent5@school.com', 'Mysore, Karnataka', 'ACTIVE'),
(39, 'PAR006', 'Ramesh', 'Singh', '9876543253', 'parent6@school.com', 'Chennai, Tamil Nadu', 'ACTIVE'),
(40, 'PAR007', 'Pooja', 'Rao', '9876543254', 'parent7@school.com', 'Pune, Maharashtra', 'ACTIVE'),
(41, 'PAR008', 'Mahesh', 'Nair', '9876543255', 'parent8@school.com', 'Kochi, Kerala', 'ACTIVE'),
(42, 'PAR009', 'Deepa', 'Das', '9876543256', 'parent9@school.com', 'Kolkata, West Bengal', 'ACTIVE'),
(43, 'PAR010', 'Vikram', 'Verma', '9876543257', 'parent10@school.com', 'Delhi, India', 'ACTIVE');


-- ============================================
-- 3. STUDENTS
-- ============================================

INSERT INTO Students
(User_id, Student_code, First_name, Last_name, Date_of_birth,
 Gender, Grade, Section, Admission_date, Status)
VALUES
(3, 'STU001', 'Arjun', 'Kumar', '2010-05-12',
 'MALE', 10, 'A', '2024-06-10', 'ACTIVE');

 INSERT INTO Students
(User_id, Student_code, First_name, Last_name, Date_of_birth,
 Gender, Grade, Section, Admission_date, Status)
VALUES
(9, 'STU002', 'Aarav', 'Sharma', '2010-03-15', 'MALE', 10, 'A', '2024-06-10', 'ACTIVE'),
(10, 'STU003', 'Aditi', 'Reddy', '2010-07-21', 'FEMALE', 10, 'A', '2024-06-10', 'ACTIVE'),
(20, 'STU004', 'Aditya', 'Kumar', '2010-01-12', 'MALE', 10, 'B', '2024-06-11', 'ACTIVE'),
(21, 'STU005', 'Ananya', 'Patel', '2010-09-05', 'FEMALE', 10, 'B', '2024-06-11', 'ACTIVE'),
(22, 'STU006', 'Diya', 'Singh', '2010-04-18', 'FEMALE', 10, 'C', '2024-06-12', 'ACTIVE'),
(23, 'STU007', 'Ishaan', 'Rao', '2010-11-23', 'MALE', 10, 'C', '2024-06-12', 'ACTIVE'),
(24, 'STU008', 'Kavya', 'Nair', '2011-02-14', 'FEMALE', 9, 'A', '2025-06-10', 'ACTIVE'),
(25, 'STU009', 'Krishna', 'Das', '2011-05-19', 'MALE', 9, 'A', '2025-06-10', 'ACTIVE'),
(26, 'STU010', 'Manav', 'Verma', '2011-08-11', 'MALE', 9, 'B', '2025-06-11', 'ACTIVE'),
(27, 'STU011', 'Meera', 'Kumar', '2011-06-25', 'FEMALE', 9, 'B', '2025-06-11', 'ACTIVE'),
(28, 'STU012', 'Nikhil', 'Sharma', '2011-03-08', 'MALE', 9, 'C', '2025-06-12', 'ACTIVE'),
(29, 'STU013', 'Riya', 'Reddy', '2011-10-17', 'FEMALE', 9, 'C', '2025-06-12', 'ACTIVE'),
(30, 'STU014', 'Rohan', 'Patel', '2011-01-29', 'MALE', 9, 'A', '2025-06-13', 'ACTIVE'),
(31, 'STU015', 'Saanvi', 'Singh', '2011-12-04', 'FEMALE', 9, 'A', '2025-06-13', 'ACTIVE'),
(32, 'STU016', 'Arnav', 'Rao', '2011-04-20', 'MALE', 9, 'B', '2025-06-14', 'ACTIVE'),
(33, 'STU017', 'Ira', 'Nair', '2011-07-15', 'FEMALE', 9, 'B', '2025-06-14', 'ACTIVE'),
(34, 'STU018', 'Vivaan', 'Das', '2011-09-09', 'MALE', 9, 'C', '2025-06-15', 'ACTIVE'),
(35, 'STU019', 'Myra', 'Verma', '2011-02-27', 'FEMALE', 9, 'C', '2025-06-15', 'ACTIVE'),
(36, 'STU020', 'Kabir', 'Kumar', '2011-11-13', 'MALE', 9, 'A', '2025-06-16', 'ACTIVE');

 

-- ============================================
-- 4. STUDENT-PARENT RELATIONSHIP
-- ============================================

INSERT INTO Student_Parents
(Student_id, Parent_id, Relationship, Is_primary_contact)
VALUES
(1, 1, 'Father', TRUE);


-- ============================================
-- 5. COURSES
-- ============================================

INSERT INTO Courses
(Course_code, Course_name, Description, Grade, Teacher_id, Status)
VALUES
('MATH10', 'Mathematics', 'Mathematics for Grade 10', 10, 1, 'ACTIVE'),
('SCI10', 'Science', 'Science for Grade 10', 10, 1, 'ACTIVE');

INSERT INTO Courses
(Course_code, Course_name, Description, Grade, Teacher_id, Status)
VALUES
('ENG10', 'English', 'English language and literature', 10, 2, 'ACTIVE'),
('CS10', 'Computer Science', 'Computer science fundamentals', 10, 3, 'ACTIVE'),
('HIS10', 'History', 'Indian and world history', 10, 4, 'ACTIVE'),
('GEO10', 'Geography', 'Physical and human geography', 10, 5, 'ACTIVE'),
('PHY10', 'Physics', 'Fundamentals of physics', 10, 6, 'ACTIVE'),
('CHEM10', 'Chemistry', 'Fundamentals of chemistry', 10, 7, 'ACTIVE'),
('BIO10', 'Biology', 'Fundamentals of biology', 10, 8, 'ACTIVE'),
('AI10', 'Artificial Intelligence', 'Introduction to artificial intelligence', 10, 9, 'ACTIVE');


-- ============================================
-- 6. ENROLLMENT
-- ============================================

INSERT INTO Enrollment
(Student_id, Course_id, Enrollment_date, Status)
VALUES
(1, 1, '2025-06-10', 'ACTIVE'),
(1, 2, '2025-06-10', 'ACTIVE');

INSERT INTO Enrollment
(Student_id, Course_id, Enrollment_date, Status)
VALUES
(1, 3, '2026-06-10', 'ACTIVE'),
(2, 1, '2026-06-10', 'ACTIVE'),
(2, 2, '2026-06-10', 'ACTIVE'),
(2, 4, '2026-06-10', 'ACTIVE'),
(3, 1, '2026-06-11', 'ACTIVE'),
(3, 3, '2026-06-11', 'ACTIVE'),
(3, 5, '2026-06-11', 'ACTIVE'),
(4, 2, '2026-06-11', 'ACTIVE'),
(4, 4, '2026-06-11', 'ACTIVE'),
(4, 6, '2026-06-11', 'ACTIVE');

INSERT INTO Enrollment
(Student_id, Course_id, Enrollment_date, Status)
VALUES
(5, 1, '2026-06-12', 'ACTIVE'),
(5, 5, '2026-06-12', 'ACTIVE'),
(5, 7, '2026-06-12', 'ACTIVE'),
(6, 2, '2026-06-12', 'ACTIVE'),
(6, 6, '2026-06-12', 'ACTIVE'),
(6, 8, '2026-06-12', 'ACTIVE'),
(7, 3, '2026-06-13', 'ACTIVE'),
(7, 4, '2026-06-13', 'ACTIVE'),
(7, 9, '2026-06-13', 'ACTIVE'),
(8, 1, '2026-06-13', 'ACTIVE');
-- ============================================
-- 7. ATTENDANCE
-- ============================================

INSERT INTO Attendance
(Student_id, Course_id, Attendance_date, Attendance_status, Recorded_by)
VALUES
(1, 1, '2026-08-10', 'PRESENT', 2),
(1, 2, '2026-08-10', 'PRESENT', 2),
(1, 1, '2026-08-11', 'ABSENT', 2);
INSERT INTO Attendance
(Student_id, Course_id, Attendance_date, Attendance_status, Recorded_by)
VALUES
(2, 1, '2026-08-10', 'ABSENT', 2),
(2, 2, '2026-08-10', 'PRESENT', 2),
(3, 1, '2026-08-10', 'PRESENT', 2),
(3, 3, '2026-08-10', 'PRESENT', 7),
(4, 2, '2026-08-11', 'PRESENT', 2),
(4, 4, '2026-08-11', 'ABSENT', 8),
(5, 1, '2026-08-11', 'PRESENT', 2),
(5, 5, '2026-08-11', 'PRESENT', 15);
-- ============================================
-- 8. ASSIGNMENTS
-- ============================================

INSERT INTO Assignments
(Course_id, Teacher_id, Title, Description, Assigned_date, Due_date, Status)
VALUES
(1, 1, 'Algebra Assignment',
 'Solve the given algebra problems.',
 '2026-08-10 09:00:00+05:30',
 '2026-08-20 23:59:00+05:30',
 'ACTIVE'),
(2, 1, 'Science Project',
 'Prepare a project on renewable energy.',
 '2026-08-11 09:00:00+05:30',
 '2026-08-25 23:59:00+05:30',
 'ACTIVE');
INSERT INTO Assignments
(Course_id, Teacher_id, Title, Description, Assigned_date, Due_date, Status)
VALUES
(1, 1, 'Geometry Assignment',
 'Solve the given geometry problems.',
 '2026-08-12 09:00:00+05:30',
 '2026-08-22 23:59:00+05:30',
 'ACTIVE'),
(2, 1, 'Science Worksheet',
 'Answer the questions from the science chapter.',
 '2026-08-12 09:00:00+05:30',
 '2026-08-22 23:59:00+05:30',
 'ACTIVE'),
(3, 2, 'English Essay',
 'Write an essay about environmental protection.',
 '2026-08-13 09:00:00+05:30',
 '2026-08-23 23:59:00+05:30',
 'ACTIVE'),
(4, 3, 'Programming Basics',
 'Write simple programs using Python.',
 '2026-08-13 09:00:00+05:30',
 '2026-08-24 23:59:00+05:30',
 'ACTIVE'),
(5, 4, 'History Assignment',
 'Prepare a report about Indian history.',
 '2026-08-14 09:00:00+05:30',
 '2026-08-25 23:59:00+05:30',
 'ACTIVE'),
(6, 5, 'Geography Project',
 'Prepare a project about Indian geography.',
 '2026-08-14 09:00:00+05:30',
 '2026-08-26 23:59:00+05:30',
 'ACTIVE'),
(7, 6, 'Physics Numericals',
 'Solve the given physics numerical problems.',
 '2026-08-15 09:00:00+05:30',
 '2026-08-27 23:59:00+05:30',
 'ACTIVE'),
(8, 7, 'Chemistry Exercise',
 'Complete the chemistry exercises.',
 '2026-08-15 09:00:00+05:30',
 '2026-08-27 23:59:00+05:30',
 'ACTIVE');
-- ============================================
-- 9. MARKS
-- ============================================

INSERT INTO Marks
(Student_id, Assignment_id, Marks_obtained, Maximum_marks, Grade, Evaluated_by)
VALUES
(1, 1, 45.00, 50.00, 'A', 1),
(1, 2, 42.00, 50.00, 'A', 1);
INSERT INTO Marks
(Student_id, Assignment_id, Marks_obtained, Maximum_marks, Grade, Evaluated_by)
VALUES
(2, 1, 42.00, 50.00, 'A', 1),
(3, 2, 38.00, 50.00, 'B', 2),
(4, 3, 45.00, 50.00, 'A', 3),
(5, 4, 40.00, 50.00, 'A', 4),
(6, 5, 35.00, 50.00, 'B', 5),
(7, 6, 47.00, 50.00, 'A', 6),
(8, 7, 44.00, 50.00, 'A', 7),
(9, 8, 32.00, 50.00, 'B', 8);


-- ============================================
-- 10. AUDIT LOG
-- ============================================

INSERT INTO Audit_Log
(User_id, Action, Table_name, Record_id, IP_address, Description)
VALUES
(1, 'CREATE', 'Users', 2, '127.0.0.1',
 'Administrator created teacher account'),

(2, 'CREATE', 'Attendance', 1, '127.0.0.1',
 'Teacher recorded student attendance'),

(2, 'UPDATE', 'Marks', 1, '127.0.0.1',
 'Teacher updated student assignment marks');
 INSERT INTO Audit_Log
(User_id, Action, Table_name, Record_id, IP_address, Description)
VALUES
(2, 'CREATE', 'Students', 2, '127.0.0.1', 'Teacher created student record'),
(7, 'UPDATE', 'Students', 3, '127.0.0.1', 'Teacher updated student information'),
(8, 'CREATE', 'Assignments', 3, '127.0.0.1', 'Teacher created new assignment'),
(13, 'UPDATE', 'Marks', 4, '127.0.0.1', 'Teacher updated student marks'),
(14, 'CREATE', 'Courses', 3, '127.0.0.1', 'Administrator created course'),
(15, 'CREATE', 'Enrollment', 5, '127.0.0.1', 'Administrator enrolled student in course'),
(16, 'UPDATE', 'Users', 7, '127.0.0.1', 'Administrator updated user account');