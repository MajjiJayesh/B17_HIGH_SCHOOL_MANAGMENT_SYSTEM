-- =========================================================================
-- 23AIE303 – Database Management Systems
-- Project: Zero-Trust High School Management System
-- Team 17 | Batch 2
-- Members: M. Jayesh (CB.SC.U4AIE24128), K. Siva Adityan (CB.SC.U4AIE24126),
--          MV. Mukesh (CB.SC.U4AIE24138), N. Srinivas (CB.SC.U4AIE24140)
-- Core DBMS Asset: Advanced SQL Queries & Query Design
-- =========================================================================

-- -------------------------------------------------------------------------
-- QUERY 1: Multi-Table Relational JOIN — Comprehensive Student Transcript
-- Combines 5 tables: Students, Enrollment, Courses, Assignments, Marks, Teachers
-- Calculates subject marks, percentages, grades, and teacher details.
-- -------------------------------------------------------------------------
SELECT 
    s.student_id,
    s.student_code,
    (s.first_name || ' ' || s.last_name) AS student_name,
    s.grade AS student_grade,
    s.section,
    c.course_name,
    c.course_code,
    a.title AS assignment_title,
    m.marks_obtained,
    m.maximum_marks,
    ROUND((m.marks_obtained / NULLIF(m.maximum_marks, 0) * 100), 2) AS percentage_score,
    m.grade AS evaluated_grade,
    (t.first_name || ' ' || t.last_name) AS evaluated_by_teacher
FROM students s
JOIN enrollment e 
    ON s.student_id = e.student_id AND e.status = 'ACTIVE'
JOIN courses c 
    ON e.course_id = c.course_id
LEFT JOIN assignments a 
    ON c.course_id = a.course_id
LEFT JOIN marks m 
    ON s.student_id = m.student_id AND a.assignment_id = m.assignment_id
LEFT JOIN teachers t 
    ON c.teacher_id = t.teacher_id
WHERE s.student_id = 1
ORDER BY c.course_name, a.due_date;


-- -------------------------------------------------------------------------
-- QUERY 2: Analytical Aggregation with GROUP BY & HAVING
-- Calculates class averages, submission totals, highest and lowest scores.
-- Filters courses with average student performance >= 70%.
-- -------------------------------------------------------------------------
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    c.grade AS target_grade,
    COUNT(DISTINCT e.student_id) AS enrolled_students,
    COUNT(m.marks_id) AS total_evaluated_submissions,
    ROUND(AVG(m.marks_obtained), 2) AS class_average_marks,
    MAX(m.marks_obtained) AS highest_score,
    MIN(m.marks_obtained) AS lowest_score
FROM courses c
JOIN enrollment e 
    ON c.course_id = e.course_id AND e.status = 'ACTIVE'
LEFT JOIN assignments a 
    ON c.course_id = a.course_id
LEFT JOIN marks m 
    ON a.assignment_id = m.assignment_id
GROUP BY c.course_id, c.course_code, c.course_name, c.grade
HAVING AVG(m.marks_obtained) >= 70.0
ORDER BY class_average_marks DESC;


-- -------------------------------------------------------------------------
-- QUERY 3: Correlated Subquery & CASE Aggregation — At-Risk Attendance Alert
-- Identifies students whose attendance rate is below 75% in any enrolled course.
-- -------------------------------------------------------------------------
SELECT 
    s.student_id,
    s.student_code,
    (s.first_name || ' ' || s.last_name) AS student_name,
    s.grade,
    s.section,
    c.course_name,
    COUNT(att.attendance_id) AS total_classes_conducted,
    COUNT(CASE WHEN att.attendance_status = 'PRESENT' THEN 1 END) AS classes_attended,
    ROUND((COUNT(CASE WHEN att.attendance_status = 'PRESENT' THEN 1 END)::DECIMAL / 
           NULLIF(COUNT(att.attendance_id), 0)) * 100, 2) AS attendance_percentage
FROM students s
JOIN enrollment e 
    ON s.student_id = e.student_id AND e.status = 'ACTIVE'
JOIN courses c 
    ON e.course_id = c.course_id
JOIN attendance att 
    ON s.student_id = att.student_id AND c.course_id = att.course_id
GROUP BY s.student_id, s.student_code, s.first_name, s.last_name, s.grade, s.section, c.course_name
HAVING (COUNT(CASE WHEN att.attendance_status = 'PRESENT' THEN 1 END)::DECIMAL / 
        NULLIF(COUNT(att.attendance_id), 0)) * 100 < 75.00
ORDER BY attendance_percentage ASC;


-- -------------------------------------------------------------------------
-- QUERY 4: Parent-Student Multi-Relationship Mapping with Contact Resolution
-- Resolves primary parent-guardian contacts for each enrolled student.
-- -------------------------------------------------------------------------
SELECT 
    s.student_code,
    (s.first_name || ' ' || s.last_name) AS student_name,
    s.grade,
    sp.relationship,
    sp.is_primary_contact,
    (p.first_name || ' ' || p.last_name) AS parent_name,
    p.phone_num AS guardian_phone,
    p.email AS guardian_email,
    p.address AS residential_address
FROM students s
JOIN student_parents sp 
    ON s.student_id = sp.student_id
JOIN parents p 
    ON sp.parent_id = p.parent_id
WHERE sp.is_primary_contact = TRUE
ORDER BY s.grade, s.last_name;


-- -------------------------------------------------------------------------
-- QUERY 5: Zero-Trust Security Audit Log Inspection
-- Queries chronological user mutations, IP addresses, and state changes.
-- -------------------------------------------------------------------------
SELECT 
    al.log_id,
    al.action_timestamp,
    u.username,
    r.role_name,
    al.action,
    al.table_name,
    al.record_id,
    al.ip_address,
    al.description
FROM audit_log al
LEFT JOIN users u 
    ON al.user_id = u.user_id
LEFT JOIN roles r 
    ON u.role_id = r.role_id
ORDER BY al.action_timestamp DESC
LIMIT 50;


-- -------------------------------------------------------------------------
-- QUERY 6: Atomic Transaction — Secure Course Enrollment with Mutation Log
-- Demonstrates ACID guarantees: BEGIN, INSERT, AUDIT, COMMIT.
-- -------------------------------------------------------------------------
BEGIN;

-- Step 1: Enroll student into course
INSERT INTO enrollment (student_id, course_id, enrollment_date, status)
VALUES (1, 2, CURRENT_DATE, 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING
RETURNING enrollment_id;

-- Step 2: Write audit record for accountability
INSERT INTO audit_log (user_id, action, table_name, record_id, action_timestamp, ip_address, description)
VALUES (1, 'ENROLL_STUDENT', 'enrollment', 1, CURRENT_TIMESTAMP, '10.0.0.4', 'Student ID 1 enrolled into Course ID 2');

COMMIT;
