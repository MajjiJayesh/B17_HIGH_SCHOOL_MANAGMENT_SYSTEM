--
-- PostgreSQL database dump
--

\restrict oYegpM90uQlU4nbE4BxbkY73saea4fL7AaK04W4XKMToRhPX15xzX76smXUeooD

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS fk_users_role;
ALTER TABLE IF EXISTS ONLY public.teachers DROP CONSTRAINT IF EXISTS fk_teacher_user;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS fk_student_user;
ALTER TABLE IF EXISTS ONLY public.student_parents DROP CONSTRAINT IF EXISTS fk_student_parent_student;
ALTER TABLE IF EXISTS ONLY public.student_parents DROP CONSTRAINT IF EXISTS fk_student_parent_parent;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS fk_parent_user;
ALTER TABLE IF EXISTS ONLY public.marks DROP CONSTRAINT IF EXISTS fk_marks_teacher;
ALTER TABLE IF EXISTS ONLY public.marks DROP CONSTRAINT IF EXISTS fk_marks_student;
ALTER TABLE IF EXISTS ONLY public.marks DROP CONSTRAINT IF EXISTS fk_marks_assignment;
ALTER TABLE IF EXISTS ONLY public.enrollment DROP CONSTRAINT IF EXISTS fk_enrollment_student;
ALTER TABLE IF EXISTS ONLY public.enrollment DROP CONSTRAINT IF EXISTS fk_enrollment_course;
ALTER TABLE IF EXISTS ONLY public.courses DROP CONSTRAINT IF EXISTS fk_course_teacher;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS fk_audit_user;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS fk_attendance_user;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS fk_attendance_student;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS fk_attendance_course;
ALTER TABLE IF EXISTS ONLY public.assignments DROP CONSTRAINT IF EXISTS fk_assignment_teacher;
ALTER TABLE IF EXISTS ONLY public.assignments DROP CONSTRAINT IF EXISTS fk_assignment_course;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_user_code_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.student_parents DROP CONSTRAINT IF EXISTS unique_student_parent;
ALTER TABLE IF EXISTS ONLY public.enrollment DROP CONSTRAINT IF EXISTS unique_student_course;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS unique_attendance;
ALTER TABLE IF EXISTS ONLY public.teachers DROP CONSTRAINT IF EXISTS teachers_user_id_key;
ALTER TABLE IF EXISTS ONLY public.teachers DROP CONSTRAINT IF EXISTS teachers_pkey;
ALTER TABLE IF EXISTS ONLY public.teachers DROP CONSTRAINT IF EXISTS teachers_employee_code_key;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_user_id_key;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_student_code_key;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_pkey;
ALTER TABLE IF EXISTS ONLY public.student_parents DROP CONSTRAINT IF EXISTS student_parents_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_role_code_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS parents_user_id_key;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS parents_pkey;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS parents_parent_code_key;
ALTER TABLE IF EXISTS ONLY public.marks DROP CONSTRAINT IF EXISTS marks_pkey;
ALTER TABLE IF EXISTS ONLY public.enrollment DROP CONSTRAINT IF EXISTS enrollment_pkey;
ALTER TABLE IF EXISTS ONLY public.courses DROP CONSTRAINT IF EXISTS courses_pkey;
ALTER TABLE IF EXISTS ONLY public.courses DROP CONSTRAINT IF EXISTS courses_course_code_key;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_pkey;
ALTER TABLE IF EXISTS ONLY public.assignments DROP CONSTRAINT IF EXISTS assignments_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN user_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.teachers ALTER COLUMN teacher_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.students ALTER COLUMN student_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.student_parents ALTER COLUMN student_parent_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN role_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.parents ALTER COLUMN parent_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.marks ALTER COLUMN marks_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.enrollment ALTER COLUMN enrollment_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.courses ALTER COLUMN course_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_log ALTER COLUMN log_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.attendance ALTER COLUMN attendance_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assignments ALTER COLUMN assignment_id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_user_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.teachers_teacher_id_seq;
DROP TABLE IF EXISTS public.teachers;
DROP SEQUENCE IF EXISTS public.students_student_id_seq;
DROP TABLE IF EXISTS public.students;
DROP SEQUENCE IF EXISTS public.student_parents_student_parent_id_seq;
DROP TABLE IF EXISTS public.student_parents;
DROP SEQUENCE IF EXISTS public.roles_role_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.parents_parent_id_seq;
DROP TABLE IF EXISTS public.parents;
DROP SEQUENCE IF EXISTS public.marks_marks_id_seq;
DROP TABLE IF EXISTS public.marks;
DROP SEQUENCE IF EXISTS public.enrollment_enrollment_id_seq;
DROP TABLE IF EXISTS public.enrollment;
DROP SEQUENCE IF EXISTS public.courses_course_id_seq;
DROP TABLE IF EXISTS public.courses;
DROP SEQUENCE IF EXISTS public.audit_log_log_id_seq;
DROP TABLE IF EXISTS public.audit_log;
DROP SEQUENCE IF EXISTS public.attendance_attendance_id_seq;
DROP TABLE IF EXISTS public.attendance;
DROP SEQUENCE IF EXISTS public.assignments_assignment_id_seq;
DROP TABLE IF EXISTS public.assignments;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    assignment_id bigint NOT NULL,
    course_id bigint NOT NULL,
    teacher_id bigint NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    assigned_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    due_date timestamp with time zone,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: assignments_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_assignment_id_seq OWNED BY public.assignments.assignment_id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance (
    attendance_id bigint NOT NULL,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    attendance_date date NOT NULL,
    attendance_status character varying(20) NOT NULL,
    recorded_by bigint,
    remarks text
);


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_attendance_id_seq OWNED BY public.attendance.attendance_id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    log_id bigint NOT NULL,
    user_id bigint,
    action character varying(100) NOT NULL,
    table_name character varying(100),
    record_id bigint,
    action_timestamp timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address inet,
    description text
);


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_log_id_seq OWNED BY public.audit_log.log_id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    course_id bigint NOT NULL,
    course_code character varying(50) NOT NULL,
    course_name character varying(100) NOT NULL,
    description text,
    grade smallint,
    teacher_id bigint,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: courses_course_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.courses_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.courses_course_id_seq OWNED BY public.courses.course_id;


--
-- Name: enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollment (
    enrollment_id bigint NOT NULL,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    enrollment_date date DEFAULT CURRENT_DATE,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrollment_enrollment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrollment_enrollment_id_seq OWNED BY public.enrollment.enrollment_id;


--
-- Name: marks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marks (
    marks_id bigint NOT NULL,
    student_id bigint NOT NULL,
    assignment_id bigint NOT NULL,
    marks_obtained numeric(5,2) NOT NULL,
    maximum_marks numeric(5,2) NOT NULL,
    grade character varying(5),
    evaluated_by bigint,
    evaluated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: marks_marks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marks_marks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marks_marks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marks_marks_id_seq OWNED BY public.marks.marks_id;


--
-- Name: parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parents (
    parent_id bigint NOT NULL,
    user_id bigint NOT NULL,
    parent_code character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    phone_num character varying(15),
    email character varying(255),
    address text,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: parents_parent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parents_parent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parents_parent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parents_parent_id_seq OWNED BY public.parents.parent_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    role_id bigint NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(50) NOT NULL,
    description text,
    priority_level smallint,
    is_system_role boolean DEFAULT false,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by bigint,
    updated_by bigint
);


--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: student_parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_parents (
    student_parent_id bigint NOT NULL,
    student_id bigint NOT NULL,
    parent_id bigint NOT NULL,
    relationship character varying(50),
    is_primary_contact boolean DEFAULT false
);


--
-- Name: student_parents_student_parent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_parents_student_parent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_parents_student_parent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_parents_student_parent_id_seq OWNED BY public.student_parents.student_parent_id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    student_id bigint NOT NULL,
    user_id bigint NOT NULL,
    student_code character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    date_of_birth date,
    gender character varying(20),
    grade smallint,
    section character varying(10),
    admission_date date,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: students_student_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.students_student_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.students_student_id_seq OWNED BY public.students.student_id;


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teachers (
    teacher_id bigint NOT NULL,
    user_id bigint NOT NULL,
    employee_code character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    department character varying(100),
    qualification character varying(150),
    joining_date date,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teachers_teacher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teachers_teacher_id_seq OWNED BY public.teachers.teacher_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    user_code character varying(50) NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(255),
    phone_num character varying(15),
    role_id bigint NOT NULL,
    account_status character varying(20) DEFAULT 'ACTIVE'::character varying,
    last_login timestamp with time zone,
    failed_login_attempt smallint DEFAULT 0,
    password_last_changed timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by bigint,
    updated_by bigint
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: assignments assignment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN assignment_id SET DEFAULT nextval('public.assignments_assignment_id_seq'::regclass);


--
-- Name: attendance attendance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance ALTER COLUMN attendance_id SET DEFAULT nextval('public.attendance_attendance_id_seq'::regclass);


--
-- Name: audit_log log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN log_id SET DEFAULT nextval('public.audit_log_log_id_seq'::regclass);


--
-- Name: courses course_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses ALTER COLUMN course_id SET DEFAULT nextval('public.courses_course_id_seq'::regclass);


--
-- Name: enrollment enrollment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment ALTER COLUMN enrollment_id SET DEFAULT nextval('public.enrollment_enrollment_id_seq'::regclass);


--
-- Name: marks marks_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks ALTER COLUMN marks_id SET DEFAULT nextval('public.marks_marks_id_seq'::regclass);


--
-- Name: parents parent_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents ALTER COLUMN parent_id SET DEFAULT nextval('public.parents_parent_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: student_parents student_parent_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_parents ALTER COLUMN student_parent_id SET DEFAULT nextval('public.student_parents_student_parent_id_seq'::regclass);


--
-- Name: students student_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students ALTER COLUMN student_id SET DEFAULT nextval('public.students_student_id_seq'::regclass);


--
-- Name: teachers teacher_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers ALTER COLUMN teacher_id SET DEFAULT nextval('public.teachers_teacher_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assignments (assignment_id, course_id, teacher_id, title, description, assigned_date, due_date, status) FROM stdin;
1	1	1	Algebra Assignment	Solve the given algebra problems.	2026-08-10 09:00:00+05:30	2026-08-20 23:59:00+05:30	ACTIVE
2	2	1	Science Project	Prepare a project on renewable energy.	2026-08-11 09:00:00+05:30	2026-08-25 23:59:00+05:30	ACTIVE
3	1	1	Geometry Assignment	Solve the given geometry problems.	2026-08-12 09:00:00+05:30	2026-08-22 23:59:00+05:30	ACTIVE
4	2	1	Science Worksheet	Answer the questions from the science chapter.	2026-08-12 09:00:00+05:30	2026-08-22 23:59:00+05:30	ACTIVE
5	3	2	English Essay	Write an essay about environmental protection.	2026-08-13 09:00:00+05:30	2026-08-23 23:59:00+05:30	ACTIVE
6	4	3	Programming Basics	Write simple programs using Python.	2026-08-13 09:00:00+05:30	2026-08-24 23:59:00+05:30	ACTIVE
7	5	4	History Assignment	Prepare a report about Indian history.	2026-08-14 09:00:00+05:30	2026-08-25 23:59:00+05:30	ACTIVE
8	6	5	Geography Project	Prepare a project about Indian geography.	2026-08-14 09:00:00+05:30	2026-08-26 23:59:00+05:30	ACTIVE
9	7	6	Physics Numericals	Solve the given physics numerical problems.	2026-08-15 09:00:00+05:30	2026-08-27 23:59:00+05:30	ACTIVE
10	8	7	Chemistry Exercise	Complete the chemistry exercises.	2026-08-15 09:00:00+05:30	2026-08-27 23:59:00+05:30	ACTIVE
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance (attendance_id, student_id, course_id, attendance_date, attendance_status, recorded_by, remarks) FROM stdin;
1	1	1	2026-08-10	PRESENT	2	\N
2	1	2	2026-08-10	PRESENT	2	\N
3	1	1	2026-08-11	ABSENT	2	\N
21	2	1	2026-08-10	ABSENT	2	\N
22	2	2	2026-08-10	PRESENT	2	\N
23	3	1	2026-08-10	PRESENT	2	\N
24	3	3	2026-08-10	PRESENT	7	\N
25	4	2	2026-08-11	PRESENT	2	\N
26	4	4	2026-08-11	ABSENT	8	\N
27	5	1	2026-08-11	PRESENT	2	\N
28	5	5	2026-08-11	PRESENT	15	\N
29	19	2	2026-08-16	ABSENT	1	fever
30	2	3	2026-08-16	PRESENT	1	fever
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (log_id, user_id, action, table_name, record_id, action_timestamp, ip_address, description) FROM stdin;
1	2	CREATE	Students	2	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Teacher created student record
2	7	UPDATE	Students	3	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Teacher updated student information
3	8	CREATE	Assignments	3	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Teacher created new assignment
4	13	UPDATE	Marks	4	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Teacher updated student marks
5	14	CREATE	Courses	3	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Administrator created course
6	15	CREATE	Enrollment	5	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Administrator enrolled student in course
7	16	UPDATE	Users	7	2026-08-16 16:03:20.589061+05:30	127.0.0.1	Administrator updated user account
8	1	LOGIN	users	1	2026-08-16 18:32:17.84167+05:30	127.0.0.1	User logged in
9	1	UPDATE	teachers	1	2026-08-16 18:33:39.557389+05:30	127.0.0.1	Teacher updated
10	1	LOGIN	users	1	2026-08-16 19:48:40.789777+05:30	127.0.0.1	User logged in
11	45	CREATE	teachers	11	2026-08-16 19:49:40.858519+05:30	127.0.0.1	Teacher created
12	1	DELETE	students	21	2026-08-16 19:54:02.837291+05:30	127.0.0.1	student deleted
13	1	CREATE	attendance	29	2026-08-16 20:00:37.179933+05:30	127.0.0.1	Attendance recorded
14	1	CREATE	attendance	30	2026-08-16 20:01:15.386254+05:30	127.0.0.1	Attendance recorded
15	1	LOGIN	users	1	2026-08-16 20:02:52.771386+05:30	127.0.0.1	User logged in
16	1	LOGIN	users	1	2026-08-17 10:11:51.796752+05:30	127.0.0.1	User logged in
17	46	CREATE	students	22	2026-08-17 10:17:27.190096+05:30	127.0.0.1	Student created
18	1	UPDATE	students	22	2026-08-17 10:18:21.756904+05:30	127.0.0.1	Student updated
19	1	LOGIN	users	1	2026-08-17 15:27:28.613297+05:30	127.0.0.1	User logged in
20	1	LOGIN	users	1	2026-08-19 10:58:13.894797+05:30	127.0.0.1	User logged in
21	1	LOGIN	users	1	2026-10-10 19:50:12.570886+05:30	127.0.0.1	User logged in
22	1	LOGIN	users	1	2026-10-15 16:41:02.94239+05:30	127.0.0.1	User logged in
23	1	DELETE	marks	3	2026-10-15 16:43:16.385793+05:30	127.0.0.1	Mark deleted
24	1	CREATE	marks	13	2026-10-15 16:43:50.813822+05:30	127.0.0.1	Marks recorded
25	1	CREATE	marks	14	2026-10-15 16:46:04.80455+05:30	127.0.0.1	Marks recorded
26	1	LOGIN	users	1	2026-10-15 17:38:51.835654+05:30	127.0.0.1	User logged in
27	1	LOGIN	users	1	2026-10-15 17:59:02.940224+05:30	127.0.0.1	User logged in
28	1	LOGIN	users	1	2026-10-15 18:39:25.958716+05:30	172.17.0.1	User logged in
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.courses (course_id, course_code, course_name, description, grade, teacher_id, status) FROM stdin;
1	MATH10	Mathematics	Mathematics for Grade 10	10	1	ACTIVE
2	SCI10	Science	Science for Grade 10	10	1	ACTIVE
3	ENG10	English	English language and literature	10	2	ACTIVE
4	CS10	Computer Science	Computer science fundamentals	10	3	ACTIVE
5	HIS10	History	Indian and world history	10	4	ACTIVE
6	GEO10	Geography	Physical and human geography	10	5	ACTIVE
7	PHY10	Physics	Fundamentals of physics	10	6	ACTIVE
8	CHEM10	Chemistry	Fundamentals of chemistry	10	7	ACTIVE
9	BIO10	Biology	Fundamentals of biology	10	8	ACTIVE
10	AI10	Artificial Intelligence	Introduction to artificial intelligence	10	9	ACTIVE
\.


--
-- Data for Name: enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.enrollment (enrollment_id, student_id, course_id, enrollment_date, status) FROM stdin;
1	1	1	2025-06-10	ACTIVE
2	1	2	2025-06-10	ACTIVE
3	1	3	2026-06-10	ACTIVE
4	2	1	2026-06-10	ACTIVE
5	2	2	2026-06-10	ACTIVE
6	2	4	2026-06-10	ACTIVE
7	3	1	2026-06-11	ACTIVE
8	3	3	2026-06-11	ACTIVE
9	3	5	2026-06-11	ACTIVE
10	4	2	2026-06-11	ACTIVE
11	4	4	2026-06-11	ACTIVE
12	4	6	2026-06-11	ACTIVE
13	5	1	2026-06-12	ACTIVE
14	5	5	2026-06-12	ACTIVE
15	5	7	2026-06-12	ACTIVE
16	6	2	2026-06-12	ACTIVE
17	6	6	2026-06-12	ACTIVE
18	6	8	2026-06-12	ACTIVE
19	7	3	2026-06-13	ACTIVE
20	7	4	2026-06-13	ACTIVE
21	7	9	2026-06-13	ACTIVE
22	8	1	2026-06-13	ACTIVE
\.


--
-- Data for Name: marks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marks (marks_id, student_id, assignment_id, marks_obtained, maximum_marks, grade, evaluated_by, evaluated_at) FROM stdin;
4	1	2	42.00	50.00	A	1	2026-08-15 14:39:57.096972+05:30
5	2	1	42.00	50.00	A	1	2026-08-16 16:02:26.508804+05:30
6	3	2	38.00	50.00	B	2	2026-08-16 16:02:26.508804+05:30
7	4	3	45.00	50.00	A	3	2026-08-16 16:02:26.508804+05:30
8	5	4	40.00	50.00	A	4	2026-08-16 16:02:26.508804+05:30
9	6	5	35.00	50.00	B	5	2026-08-16 16:02:26.508804+05:30
10	7	6	47.00	50.00	A	6	2026-08-16 16:02:26.508804+05:30
11	8	7	44.00	50.00	A	7	2026-08-16 16:02:26.508804+05:30
12	9	8	32.00	50.00	B	8	2026-08-16 16:02:26.508804+05:30
13	13	4	78.00	100.00	B	1	2026-10-15 16:43:50.813822+05:30
14	2	1	80.00	100.00	A	1	2026-10-15 16:46:04.80455+05:30
\.


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parents (parent_id, user_id, parent_code, first_name, last_name, phone_num, email, address, status) FROM stdin;
1	4	PAR001	Rajesh	Kumar	9876543213	parent@school.com	Bangalore, Karnataka	ACTIVE
2	11	PAR002	Suresh	Kumar	9876543211	parent2@school.com	Bangalore, Karnataka	ACTIVE
3	12	PAR003	Lakshmi	Reddy	9876543212	parent3@school.com	Hyderabad, Telangana	ACTIVE
4	37	PAR004	Mohan	Sharma	9876543251	parent4@school.com	Bangalore, Karnataka	ACTIVE
5	38	PAR005	Sunita	Patel	9876543252	parent5@school.com	Mysore, Karnataka	ACTIVE
6	39	PAR006	Ramesh	Singh	9876543253	parent6@school.com	Chennai, Tamil Nadu	ACTIVE
7	40	PAR007	Pooja	Rao	9876543254	parent7@school.com	Pune, Maharashtra	ACTIVE
8	41	PAR008	Mahesh	Nair	9876543255	parent8@school.com	Kochi, Kerala	ACTIVE
9	42	PAR009	Deepa	Das	9876543256	parent9@school.com	Kolkata, West Bengal	ACTIVE
10	43	PAR010	Vikram	Verma	9876543257	parent10@school.com	Delhi, India	ACTIVE
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (role_id, role_code, role_name, description, priority_level, is_system_role, status, created_at, updated_at, created_by, updated_by) FROM stdin;
1	SUPER_ADMIN	Super Administrator	Full system administration access	100	t	ACTIVE	2026-08-15 11:12:54.432806+05:30	2026-08-15 11:12:54.432806+05:30	\N	\N
2	ADMIN	Administrator	Manages school users and operations	90	t	ACTIVE	2026-08-15 11:12:54.432806+05:30	2026-08-15 11:12:54.432806+05:30	\N	\N
3	TEACHER	Teacher	Manages academic activities	60	t	ACTIVE	2026-08-15 11:12:54.432806+05:30	2026-08-15 11:12:54.432806+05:30	\N	\N
5	PARENT	Parent	Views student academic information	10	t	ACTIVE	2026-08-15 11:12:54.432806+05:30	2026-08-15 11:12:54.432806+05:30	\N	\N
4	STUDENT	Student	Accesses academic information	20	t	INACTIVE	2026-08-15 11:12:54.432806+05:30	2026-08-15 11:12:54.432806+05:30	\N	\N
\.


--
-- Data for Name: student_parents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_parents (student_parent_id, student_id, parent_id, relationship, is_primary_contact) FROM stdin;
1	1	1	Father	t
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.students (student_id, user_id, student_code, first_name, last_name, date_of_birth, gender, grade, section, admission_date, status) FROM stdin;
2	9	STU002	Aarav	Sharma	2010-03-15	MALE	10	A	2024-06-10	ACTIVE
4	20	STU004	Aditya	Kumar	2010-01-12	MALE	10	B	2024-06-11	ACTIVE
6	22	STU006	Diya	Singh	2010-04-18	FEMALE	10	C	2024-06-12	ACTIVE
7	23	STU007	Ishaan	Rao	2010-11-23	MALE	10	C	2024-06-12	ACTIVE
8	24	STU008	Kavya	Nair	2011-02-14	FEMALE	9	A	2025-06-10	ACTIVE
9	25	STU009	Krishna	Das	2011-05-19	MALE	9	A	2025-06-10	ACTIVE
10	26	STU010	Manav	Verma	2011-08-11	MALE	9	B	2025-06-11	ACTIVE
11	27	STU011	Meera	Kumar	2011-06-25	FEMALE	9	B	2025-06-11	ACTIVE
12	28	STU012	Nikhil	Sharma	2011-03-08	MALE	9	C	2025-06-12	ACTIVE
13	29	STU013	Riya	Reddy	2011-10-17	FEMALE	9	C	2025-06-12	ACTIVE
14	30	STU014	Rohan	Patel	2011-01-29	MALE	9	A	2025-06-13	ACTIVE
15	31	STU015	Saanvi	Singh	2011-12-04	FEMALE	9	A	2025-06-13	ACTIVE
16	32	STU016	Arnav	Rao	2011-04-20	MALE	9	B	2025-06-14	ACTIVE
17	33	STU017	Ira	Nair	2011-07-15	FEMALE	9	B	2025-06-14	ACTIVE
18	34	STU018	Vivaan	Das	2011-09-09	MALE	9	C	2025-06-15	ACTIVE
19	35	STU019	Myra	Verma	2011-02-27	FEMALE	9	C	2025-06-15	ACTIVE
20	36	STU020	Kabir	Kumar	2011-11-13	MALE	9	A	2025-06-16	ACTIVE
22	46	STU0030	Mukesk	Muke	2026-02-18	MALE	12	B	2026-08-17	ACTIVE
5	21	STU005	Ananya	Patel	2010-09-05	FEMALE	9	B	2024-06-11	ACTIVE
1	3	STU001	Arjun	Kumar	2010-05-12	MALE	10	B	2024-06-10	INACTIVE
3	10	STU003	Aditi	Reddy	2010-07-21	FEMALE	9	A	2024-06-10	ACTIVE
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teachers (teacher_id, user_id, employee_code, first_name, last_name, department, qualification, joining_date, status) FROM stdin;
2	7	EMP002	Ravi	Kumar	Science	M.Sc Physics	2021-06-15	ACTIVE
4	13	EMP004	Rahul	Sharma	Computer Science	M.Tech Computer Science	2020-07-10	ACTIVE
5	14	EMP005	Sneha	Rao	Social Studies	M.A History	2023-06-20	ACTIVE
6	15	EMP006	Kiran	Patel	Physics	M.Sc Physics	2021-08-12	ACTIVE
7	16	EMP007	Meena	Das	Chemistry	M.Sc Chemistry	2022-07-05	ACTIVE
8	17	EMP008	Vijay	Singh	Biology	M.Sc Biology	2020-06-18	ACTIVE
9	18	EMP009	Kavya	Nair	Mathematics	M.Sc Mathematics	2023-06-12	ACTIVE
10	19	EMP010	Arun	Verma	Computer Science	M.Tech Computer Science	2021-07-15	ACTIVE
1	2	EMP001	Anita	Sharma	Mathematics	M.Sc Mathematics	2025-06-24	ACTIVE
11	45	EMP0010	srinu	adi	mathematics	M.Sc	2026-08-16	ACTIVE
3	8	EMP003	Priya	Reddy	English	M.Sc Biology	2022-06-15	ACTIVE
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_id, user_code, username, password_hash, email, phone_num, role_id, account_status, last_login, failed_login_attempt, password_last_changed, created_at, updated_at, created_by, updated_by) FROM stdin;
2	USR002	teacher01	hashed_teacher_password	teacher@school.com	9876543211	3	ACTIVE	\N	0	\N	2026-08-15 11:14:12.339732+05:30	2026-08-15 11:14:12.339732+05:30	\N	\N
3	USR003	student01	hashed_student_password	student@school.com	9876543212	4	ACTIVE	\N	0	\N	2026-08-15 11:14:12.339732+05:30	2026-08-15 11:14:12.339732+05:30	\N	\N
4	USR004	parent01	hashed_parent_password	parent@school.com	9876543213	5	ACTIVE	\N	0	\N	2026-08-15 11:14:12.339732+05:30	2026-08-15 11:14:12.339732+05:30	\N	\N
7	USR006	teacher02	hashed_teacher_password	teacher2@school.com	9876543214	3	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
8	USR007	teacher03	hashed_teacher_password	teacher3@school.com	9876543215	3	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
9	USR008	student02	hashed_student_password	student2@school.com	9876543216	4	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
10	USR009	student03	hashed_student_password	student3@school.com	9876543217	4	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
11	USR010	parent02	hashed_parent_password	parent2@school.com	9876543218	5	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
12	USR011	parent03	hashed_parent_password	parent3@school.com	9876543219	5	ACTIVE	\N	0	\N	2026-08-16 15:19:09.758567+05:30	2026-08-16 15:19:09.758567+05:30	\N	\N
13	USR012	teacher04	hashed_teacher_password	teacher4@school.com	9876543220	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
14	USR013	teacher05	hashed_teacher_password	teacher5@school.com	9876543221	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
15	USR014	teacher06	hashed_teacher_password	teacher6@school.com	9876543222	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
16	USR015	teacher07	hashed_teacher_password	teacher7@school.com	9876543223	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
17	USR016	teacher08	hashed_teacher_password	teacher8@school.com	9876543224	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
18	USR017	teacher09	hashed_teacher_password	teacher9@school.com	9876543225	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
19	USR018	teacher10	hashed_teacher_password	teacher10@school.com	9876543226	3	ACTIVE	\N	0	\N	2026-08-16 15:30:46.374422+05:30	2026-08-16 15:30:46.374422+05:30	\N	\N
20	USR019	student04	hashed_student_password	student4@school.com	9876543227	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
21	USR020	student05	hashed_student_password	student5@school.com	9876543228	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
22	USR021	student06	hashed_student_password	student6@school.com	9876543229	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
23	USR022	student07	hashed_student_password	student7@school.com	9876543230	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
24	USR023	student08	hashed_student_password	student8@school.com	9876543231	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
25	USR024	student09	hashed_student_password	student9@school.com	9876543232	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
26	USR025	student10	hashed_student_password	student10@school.com	9876543233	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
27	USR026	student11	hashed_student_password	student11@school.com	9876543234	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
28	USR027	student12	hashed_student_password	student12@school.com	9876543235	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
29	USR028	student13	hashed_student_password	student13@school.com	9876543236	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
30	USR029	student14	hashed_student_password	student14@school.com	9876543237	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
31	USR030	student15	hashed_student_password	student15@school.com	9876543238	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
32	USR031	student16	hashed_student_password	student16@school.com	9876543239	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
33	USR032	student17	hashed_student_password	student17@school.com	9876543240	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
34	USR033	student18	hashed_student_password	student18@school.com	9876543241	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
35	USR034	student19	hashed_student_password	student19@school.com	9876543242	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
36	USR035	student20	hashed_student_password	student20@school.com	9876543243	4	ACTIVE	\N	0	\N	2026-08-16 15:35:11.444335+05:30	2026-08-16 15:35:11.444335+05:30	\N	\N
37	USR036	parent04	hashed_parent_password	parent4@school.com	9876543244	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
38	USR037	parent05	hashed_parent_password	parent5@school.com	9876543245	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
39	USR038	parent06	hashed_parent_password	parent6@school.com	9876543246	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
40	USR039	parent07	hashed_parent_password	parent7@school.com	9876543247	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
41	USR040	parent08	hashed_parent_password	parent8@school.com	9876543248	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
42	USR041	parent09	hashed_parent_password	parent9@school.com	9876543249	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
43	USR042	parent10	hashed_parent_password	parent10@school.com	9876543250	5	ACTIVE	\N	0	\N	2026-08-16 15:40:18.27508+05:30	2026-08-16 15:40:18.27508+05:30	\N	\N
46	USR045	stu0030	scrypt:32768:8:1$JTfP63JtdHmPWC93$7011be043cdd9630974e47b6b3448791aa8e47d9d807320785b61cf8540217ec4f1c531866ae16977628a1d32d965aa5db179d19b22e0bae6dcae4088147a1d2	\N	\N	4	ACTIVE	\N	0	\N	2026-08-17 10:17:27.190096+05:30	2026-08-17 10:17:27.190096+05:30	\N	\N
1	USR001	admin01	scrypt:32768:8:1$pbDk7c6CtBzbfKoY$168a176bf20c9f4cedd951386a750b120c00441c1dd34f5c512d2d839b271335b0204690e142cc5732c448e7fcf380c4d6a9710234b88d5d333ab50b8caff14c	admin@school.com	9876543210	1	ACTIVE	2026-10-15 18:39:25.958716+05:30	0	\N	2026-08-15 11:14:12.339732+05:30	2026-08-15 11:14:12.339732+05:30	\N	\N
45	USR044	emp0010	scrypt:32768:8:1$TzbYiOqbJvUaXG7P$b825aa9c6d211496821d904e80fff484d4216eef7909e099d9a68ed0b092209d338b29c871ebaaa443a99b0e89f520b15a96ab95f5f12d61fd717ac11a72f300	\N	\N	3	ACTIVE	\N	0	\N	2026-08-16 19:49:40.858519+05:30	2026-08-16 19:49:40.858519+05:30	\N	\N
\.


--
-- Name: assignments_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assignments_assignment_id_seq', 10, true);


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_attendance_id_seq', 30, true);


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_log_log_id_seq', 28, true);


--
-- Name: courses_course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.courses_course_id_seq', 10, true);


--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.enrollment_enrollment_id_seq', 22, true);


--
-- Name: marks_marks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marks_marks_id_seq', 14, true);


--
-- Name: parents_parent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parents_parent_id_seq', 10, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 5, true);


--
-- Name: student_parents_student_parent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.student_parents_student_parent_id_seq', 1, true);


--
-- Name: students_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.students_student_id_seq', 24, true);


--
-- Name: teachers_teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.teachers_teacher_id_seq', 11, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 46, true);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (assignment_id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: courses courses_course_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_course_code_key UNIQUE (course_code);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (enrollment_id);


--
-- Name: marks marks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT marks_pkey PRIMARY KEY (marks_id);


--
-- Name: parents parents_parent_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_parent_code_key UNIQUE (parent_code);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (parent_id);


--
-- Name: parents parents_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_user_id_key UNIQUE (user_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: student_parents student_parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT student_parents_pkey PRIMARY KEY (student_parent_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: students students_student_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_student_code_key UNIQUE (student_code);


--
-- Name: students students_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_key UNIQUE (user_id);


--
-- Name: teachers teachers_employee_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_employee_code_key UNIQUE (employee_code);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);


--
-- Name: teachers teachers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);


--
-- Name: attendance unique_attendance; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT unique_attendance UNIQUE (student_id, course_id, attendance_date);


--
-- Name: enrollment unique_student_course; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT unique_student_course UNIQUE (student_id, course_id);


--
-- Name: student_parents unique_student_parent; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT unique_student_parent UNIQUE (student_id, parent_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_code_key UNIQUE (user_code);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: assignments fk_assignment_course; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT fk_assignment_course FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: assignments fk_assignment_teacher; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT fk_assignment_teacher FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id);


--
-- Name: attendance fk_attendance_course; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_course FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: attendance fk_attendance_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: attendance fk_attendance_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_user FOREIGN KEY (recorded_by) REFERENCES public.users(user_id);


--
-- Name: audit_log fk_audit_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: courses fk_course_teacher; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT fk_course_teacher FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id);


--
-- Name: enrollment fk_enrollment_course; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: enrollment fk_enrollment_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: marks fk_marks_assignment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT fk_marks_assignment FOREIGN KEY (assignment_id) REFERENCES public.assignments(assignment_id);


--
-- Name: marks fk_marks_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT fk_marks_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: marks fk_marks_teacher; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT fk_marks_teacher FOREIGN KEY (evaluated_by) REFERENCES public.teachers(teacher_id);


--
-- Name: parents fk_parent_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT fk_parent_user FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: student_parents fk_student_parent_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT fk_student_parent_parent FOREIGN KEY (parent_id) REFERENCES public.parents(parent_id);


--
-- Name: student_parents fk_student_parent_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT fk_student_parent_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: students fk_student_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: teachers fk_teacher_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT fk_teacher_user FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: users fk_users_role; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES public.roles(role_id);


--
-- PostgreSQL database dump complete
--

\unrestrict oYegpM90uQlU4nbE4BxbkY73saea4fL7AaK04W4XKMToRhPX15xzX76smXUeooD

