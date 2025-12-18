--
-- PostgreSQL database dump
--

\restrict pco1D7Bh0dbxpNcp9wW8LZSNgiETjBk29UOGhJ3hmqPJjkoNTjQEaZyNHjnVwgU

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_settings (
    id integer DEFAULT 1 NOT NULL,
    "allowNewEnrollments" boolean DEFAULT true NOT NULL,
    "allowNewDrugs" boolean DEFAULT true NOT NULL,
    "allowNewDepartments" boolean DEFAULT true NOT NULL,
    "allowNewPatients" boolean DEFAULT true NOT NULL
);


ALTER TABLE public.app_settings OWNER TO postgres;

--
-- Name: defaulters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.defaulters (
    id integer NOT NULL,
    enrollment_id integer,
    drug_id integer,
    patient_id integer,
    last_refill_date date,
    days_since_refill integer,
    defaulter_date date DEFAULT CURRENT_DATE,
    remarks text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.defaulters OWNER TO postgres;

--
-- Name: defaulters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.defaulters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.defaulters_id_seq OWNER TO postgres;

--
-- Name: defaulters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.defaulters_id_seq OWNED BY public.defaulters.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: drugs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drugs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    department_id integer,
    quota_number integer DEFAULT 0 NOT NULL,
    active_patients integer DEFAULT 0,
    price numeric(10,2) DEFAULT 0.00 NOT NULL,
    calculation_method character varying(100) DEFAULT 'monthly'::character varying,
    remarks text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.drugs OWNER TO postgres;

--
-- Name: drugs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drugs_id_seq OWNER TO postgres;

--
-- Name: drugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drugs_id_seq OWNED BY public.drugs.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    drug_id integer,
    patient_id integer,
    prescription_start_date date NOT NULL,
    prescription_end_date date,
    latest_refill_date date,
    spub boolean DEFAULT false,
    remarks text,
    cost_per_year numeric(10,2) DEFAULT 0.00,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    dose_per_day text,
    cost_per_day numeric(10,2) DEFAULT 0.00 NOT NULL
);


ALTER TABLE public.enrollments OWNER TO postgres;

--
-- Name: COLUMN enrollments.dose_per_day; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.enrollments.dose_per_day IS 'Dose information as free text (e.g., "10 mg tds", "5mg daily", etc.)';


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enrollments_id_seq OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    ic_number character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_id_seq OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255),
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ic_number character varying(20)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: defaulters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defaulters ALTER COLUMN id SET DEFAULT nextval('public.defaulters_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: drugs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugs ALTER COLUMN id SET DEFAULT nextval('public.drugs_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_settings (id, "allowNewEnrollments", "allowNewDrugs", "allowNewDepartments", "allowNewPatients") FROM stdin;
1	t	t	f	t
\.


--
-- Data for Name: defaulters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.defaulters (id, enrollment_id, drug_id, patient_id, last_refill_date, days_since_refill, defaulter_date, remarks, created_at) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, created_at, updated_at) FROM stdin;
6	01 - Medical	2025-09-10 09:06:01.368795	2025-10-06 10:56:36.002259
21	01a - Dermatology (Medical)	2025-09-24 11:45:20.821922	2025-10-03 11:56:11.855953
22	01b - Infectious Disease (Medical)	2025-10-01 14:55:15.335583	2025-10-03 11:56:33.904655
7	02 - Surgical	2025-09-10 09:06:35.00156	2025-10-03 11:56:43.698168
15	10 - Rehab Clinic	2025-09-10 12:13:49.879691	2025-10-03 11:57:30.797283
10	08 - Paediatric	2025-09-10 09:06:55.625412	2025-10-03 11:57:34.606158
13	06 - Psychiatric	2025-09-10 12:13:24.299286	2025-10-03 11:57:37.142109
14	07 - Ear, Nose & Throat (ENT)	2025-09-10 12:13:38.940318	2025-10-03 11:57:40.64774
8	04 - Orthopaedic	2025-09-10 09:06:41.905509	2025-10-03 11:57:43.349375
12	05 - Obstetric & Gynaecology (O&G)	2025-09-10 12:13:15.867364	2025-10-03 11:57:46.013853
11	03 - Ophthalmology	2025-09-10 09:07:13.845415	2025-10-03 11:57:53.999236
9	09 - Nephrology	2025-09-10 09:06:50.92915	2025-10-03 11:58:01.8869
\.


--
-- Data for Name: drugs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drugs (id, name, department_id, quota_number, active_patients, price, calculation_method, remarks, created_at, updated_at) FROM stdin;
5	Amlodipine + Valsartan 10mg/160mg Tab (EXFORGE)	6	20	0	0.48	daily	\N	2025-09-10 10:26:15.789556	2025-09-10 10:48:47.904629
9	Cholestyramine Resin 4g	6	1	0	375.11	daily	DCM 01/24 - New Drug	2025-09-10 15:57:10.960483	2025-09-10 15:57:10.960483
11	Dabigatran 150mg Cap (PRADAXA)	6	20	0	102.49	daily	DCM 02/24 - Update Quota 20 (+5)	2025-09-10 15:57:44.520162	2025-09-10 15:57:44.520162
15	Febuxostat 80mg Tab	6	10	0	65.78	daily	DCM 01/24 - Update Quota 10	2025-09-10 16:03:11.994307	2025-09-10 16:03:11.994307
16	Fenofibrate 145mg Tab	6	35	0	29.10	daily	DCM 01/25 - Update Quota 35	2025-09-10 16:03:31.205095	2025-09-10 16:03:31.205095
17	Dutasteride 0.5mg and Tamsulosin 0.4mg Cap (DUODART)	7	25	0	147.90	daily	\N	2025-09-10 16:04:08.823288	2025-09-10 16:04:08.823288
19	Solifenacin 5mg Tab (VESICARE)	7	2	0	80.70	daily	\N	2025-09-10 16:04:45.344254	2025-09-10 16:04:45.344254
21	Atropine 0.01% Eye Drop	11	5	0	69.80	daily	\N	2025-09-10 16:10:19.171097	2025-09-10 16:10:19.171097
22	Natamycin 5% Eye Drop	11	5	0	18.50	daily	\N	2025-09-10 16:10:29.013968	2025-09-10 16:10:29.013968
7	Denosumab in 1.0mL solution 60mg/mL (PROLIA)	8	10	0	3.60	\N	UPDATE DCM 01/25 - QUOTA 10 PATIENT PER YEAR - DOSE 6 MONTHLY\nRM 648.05 / PFS	2025-09-10 11:08:26.436334	2025-11-20 09:50:40.195891
26	Ivabradine 5mg Tab (CORALAN)	6	5	0	1.00	daily	\N	2025-09-17 16:00:00	2025-09-17 16:00:00
27	Leflunomide 20mg Tab	6	40	0	1.00	daily	DCM 01/25 - Update Quota 40	2025-09-17 16:00:00	2025-09-17 16:00:00
28	Mercaptopurine 50mg Tab	6	1	0	1.00	daily	DCM 02/23 - New Drug	2025-09-17 16:00:00	2025-09-17 16:00:00
29	Mesalazine 1g Supp / Enema	6	3	0	1.00	daily	DCM 02/24 - Update Quota 3 (+1)	2025-09-17 16:00:00	2025-09-17 16:00:00
30	Mesalazine 500mg MR Tab	6	8	0	1.00	daily	DCM 02/24 - Update Quota 8 (+3)	2025-09-17 16:00:00	2025-09-17 16:00:00
33	Oxcarbazepine 300mg Tab	6	1	0	1.00	daily	DCM 02/23 - New Drug	2025-09-17 16:00:00	2025-09-17 16:00:00
34	Oxybutynin Chloride 5 mg Tab	6	1	0	1.00	daily	DCM 01/24 - New Drug	2025-09-17 16:00:00	2025-09-17 16:00:00
35	Pramipexole 0.125mg & 1mg Tab (SIFROL)	6	5	0	1.00	daily	DCM 01/25 - Update Quota 5	2025-09-17 16:00:00	2025-09-17 16:00:00
37	Sacubitril / Valsartan 100mg Tab (ENTRESTO) 	6	20	0	1.00	daily	DCM 01/25 - Update Quota 20	2025-09-17 16:00:00	2025-09-17 16:00:00
38	Ropinirole 0.25mg Tab	6	2	0	1.00	daily	DCM 02/24 - 1mg dah keluar, 0.25mg belum (?)	2025-09-17 16:00:00	2025-09-17 16:00:00
41	Budesonide 9mg Prolonged Release Tablets	6	1	0	1.00	daily	DCM 01/25 - New Drug	2025-09-17 16:00:00	2025-09-17 16:00:00
42	Anagrelide 0.5mg Capsule 	6	1	0	1.00	daily	\N	2025-09-17 16:00:00	2025-09-17 16:00:00
46	Indacaterol 110mcg + Glycopyrronium 50mcg Inhaler (ULTIBRO)	6	100	0	1.00	daily	DCM 02/24 - Update Quota 100 (+10)	2025-09-17 16:00:00	2025-09-17 16:00:00
48	Tiotropium + Olodaterol Inhalation (SPIOLTO)	6	70	0	1.00	daily	DCM 02/24 - Update Quota 70 (+10)	2025-09-17 16:00:00	2025-09-17 16:00:00
49	Tiotropium 2.5mcg Inhalation (SPIRIVA)	6	10	0	1.00	daily	\N	2025-09-17 16:00:00	2025-09-17 16:00:00
45	Insulin Aspart 30% Protaminated 70% (NOVOMIX)	6	10	0	0.08	daily	DCM 01/25 - Update Quota 10	2025-09-17 16:00:00	2025-10-01 11:46:48.504901
32	KIV OPEN Mycophenolate Mofetil 500mg Tab	6	1	0	1.00	daily	DCM 02/24 - Add Neuro 1 Pt	2025-09-17 16:00:00	2025-10-01 10:25:09.90985
54	Abacavir 300mg Tab	22	30	0	2.02	\N	DCM 02/24 - New Drug (Case Basis) || RM 121.00 / 60s	2025-09-17 16:00:00	2025-11-05 11:57:05.948827
31	KIV OPEN Morphine Sulphate 30mg & 10mg PR Tablet	6	5	0	1.00	daily	\N	2025-09-17 16:00:00	2025-10-01 10:25:48.426992
39	KIV OPEN Itopride Hydrochloride 50mg Tab (GANATON)	6	5	0	1.00	daily	DCM 01/25 - Add Medical 5	2025-09-17 16:00:00	2025-10-01 10:26:06.298467
18	KIV OPEN Itopride Hydrochloride 50mg Tab (GANATON)	7	10	0	28.00	daily	\N	2025-09-10 16:04:22.609937	2025-10-01 10:26:12.338324
36	KIV OPEN Rivaroxaban 20mg Tab (XARELTO)	6	30	0	1.00	daily	DCM 01/25 - Update Quota 30	2025-09-17 16:00:00	2025-10-01 10:26:26.003538
13	KIV OPEN Entacapone 200mg Tab	6	2	0	170.00	daily	DCM 01/25 - Update Quota 2	2025-09-10 16:02:09.497533	2025-10-01 10:26:35.314891
14	KIV OPEN Entecavir 0.5mg Tab	6	5	0	84.60	daily	DCM 02/24 - Update Quota 5 (+2)	2025-09-10 16:02:44.269287	2025-10-01 10:27:00.977782
47	KIV OPEN Salmeterol + Fluticasone 50/500mcg Inhaler (SERETIDE)	6	8	0	1.00	daily	\N	2025-09-17 16:00:00	2025-10-01 10:27:12.433475
6	KIV OPEN Bicalutamide 50mg Tab (CASODEX)	7	1	0	1.78	daily	\N	2025-09-10 11:07:44.287473	2025-10-01 10:27:24.235338
12	Empagliflozin 25mg Tab (JARDIANCE)	6	80	0	1.73	daily	DCM 01/25 - Update Quota 80	2025-09-10 16:01:51.855123	2025-10-01 11:41:33.675821
10	Clobazam 10mg Tab	6	3	0	0.66	daily	DCM 01/25 - Update Quota 3	2025-09-10 15:57:25.710229	2025-10-01 11:42:31.931747
40	Levofloxacin 500mg Tab	6	5	0	1.42	daily	DCM 01/25 - Add Medical 5	2025-09-17 16:00:00	2025-10-01 11:44:11.104305
43	Insulin Aspart 100iu/ml (NOVORAPID) (Medical)	6	35	0	0.06	daily	DCM 01/25 - Update Quota 35	2025-09-17 16:00:00	2025-10-01 11:46:14.333215
44	Insulin Detemir 100iu/ml (LEVEMIR)	6	50	0	0.10	daily	DCM 01/25 - Update Quota 50	2025-09-17 16:00:00	2025-10-01 11:48:04.971506
8	KIV OPEN Amantadine 100mg Cap	6	8	0	0.92	\N	Open Quota on DCM 02/25	2025-09-10 15:22:01.446284	2025-10-03 15:04:45.331539
20	Propiverine 15mg Tab (MICTONORM)	7	25	0	1.82	\N	\N	2025-09-10 16:05:01.276395	2025-10-29 10:03:22.725553
50	Clofazimine 100mg Cap	22	30	0	1.00	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:51:28.256646
23	Hylo-Comod Eye Drop	11	30	0	1.00	\N	RM 30.00 per bot	2025-09-10 16:10:43.857598	2025-11-10 12:38:01.338192
55	Abacavir Sulphate 600mg & Lamivudine 300mg Tab	22	30	0	1.00	\N	DCM 02/24 - New Drug (Case Basis)	2025-09-17 16:00:00	2025-10-29 14:51:02.252628
51	Cycloserine 250mg Tab	22	30	0	10.40	\N	DCM 02/23 - Add Medical (Case Basis)	2025-09-17 16:00:00	2025-10-29 14:51:37.30016
56	Dolutegravir 50mg Tab	22	30	0	1.00	\N	DCM 02/24 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:51:44.511374
57	Efavirenz 200 mg Tab	22	30	0	1.00	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:51:50.263092
59	Efavirenz 600mg, Emtricitabine 200mg,Tenofovir 300mg Tablet (TRUSTIVA)	22	30	0	1.00	\N	\N	2025-09-17 16:00:00	2025-10-29 14:51:55.519114
52	Ethionamide 250mg Tab	22	30	0	1.00	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:52:01.992323
60	Lamivudine 150mg Tab	22	30	0	1.00	\N	\N	2025-09-17 16:00:00	2025-10-29 14:52:08.288084
53	Linezolid 600mg Tab	22	30	0	1.00	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:52:13.810092
58	Lopinavir 200mg + Ritonavir 50mg Tab (KALETRA)	22	30	0	4.13	\N	DCM 02/24 - Add Medical Case Basis	2025-09-17 16:00:00	2025-10-29 14:52:19.466944
24	Romosozumab 105 mg/1.17 ml pre-filled Syringe	8	2	0	47.20	\N	RM 1,415.90 per pfs, inject monthly	2025-09-10 16:11:00.947908	2025-11-04 16:22:44.453703
25	Multivitamin Tablet	8	20	0	0.14	\N	For Discharged Patient Only -- RM 8.40 / 60's	2025-09-10 16:11:14.446751	2025-11-10 12:52:54.924567
83	Quetiapine XR 50 mg // 200mg // 400mg Tab (SEROQUEL XR)	13	25	0	1.00	daily	DCM 01/24 - Update Quota 25	2025-09-17 16:00:00	2025-09-17 16:00:00
84	Rivastigmine 1.5mg & 3mg Tab	13	10	0	1.00	daily	\N	2025-09-17 16:00:00	2025-09-17 16:00:00
85	Rivastigmine 9.5mcg Patch (EXELON)	13	5	0	1.00	daily	\N	2025-09-17 16:00:00	2025-09-17 16:00:00
86	Vortioxetine 10mg Tab (BRINTELLIX)	13	40	0	1.00	daily	DCM 01/25 - Update Quota 40	2025-09-17 16:00:00	2025-09-17 16:00:00
87	Venlafaxine HCl 75 mg & 150 mg ER Capsule	13	10	0	1.00	daily	DCM 02/23 - New Drug (75mg)\nDCM 01/25 - New Drug (150mg)	2025-09-17 16:00:00	2025-09-17 16:00:00
88	Valbenazine 40mg Capsule	13	1	0	1.00	daily	DCM 01/25 - New Drug	2025-09-17 16:00:00	2025-09-17 16:00:00
94	Lopinavir 200mg + Ritonavir 50mg Tab (KALETRA)	10	1	0	4.13	daily	DCM 02/24 - Add Medical Case Basis	2025-09-17 16:00:00	2025-10-01 11:43:14.476886
63	Tacrolimus 0.1% Ointment	21	5	0	1.00	daily	DCM 02/24 - New Drug	2025-09-17 16:00:00	2025-09-24 11:46:11.792045
73	Amisulpiride 100 & 400mg Tab (SOLIAN)	13	40	0	1.40	\N	100MG RM42.05 / 30's -- 400MG RM156.52 / 30's	2025-09-17 16:00:00	2025-11-24 11:12:34.964914
97	Cycloserine 250mg  Tab (Paeds)	10	60	0	10.40	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-27 09:35:02.040191
80	KIV OPEN Mirtazapine 15mg Tab (REMERON)	13	50	0	1.00	daily	DCM 02/24 - Update Quota 50 (+20)	2025-09-17 16:00:00	2025-10-01 10:26:48.50692
99	KIV OPEN Dipyridamole 75mg Tab	10	3	0	1.00	daily	DCM 02/24 - Update Quota 3 (+2)	2025-09-17 16:00:00	2025-10-01 10:27:33.427407
102	KIV OPEN Levetiracetam 100 mg/ml Oral Solution	10	5	0	1.00	daily	DCM 01/25 - New Drug	2025-09-17 16:00:00	2025-10-01 10:27:44.265491
62	KIV OPEN Isotretinoin 10 mg Cap	21	5	0	1.00	daily	DCM 02/24 - New Drug	2025-09-17 16:00:00	2025-10-01 10:27:54.626141
64	KIV OPEN Acitretin 25 mg Capsule	21	1	0	1.00	daily	DCM 01/25 - New Drug	2025-09-17 16:00:00	2025-10-01 10:28:10.430577
65	KIV OPEN Salicylic acid, Sulphur and Liquid Coal Tar Ointment	21	5	0	1.00	daily	DCM 01/25 - New Drug	2025-09-17 16:00:00	2025-10-01 10:28:25.737752
112	Piracetam 1.2 g Tablet	15	5	0	1.14	\N	New Drug DCM 01/25 -- RM 22.80/20's	2025-09-17 16:00:00	2025-11-20 11:21:17.592063
105	Iberet Folic	9	25	0	0.60	daily	DCM 01/19 - Add Nephro as quota	2025-09-17 16:00:00	2025-10-01 11:41:11.939639
106	Sevelamer 800mg Tab	9	15	0	1.33	daily	DCM 02/24 - Update Quota 15 (+5)	2025-09-17 16:00:00	2025-10-01 11:41:22.518932
109	Everolimus 0.25mg/0.75mg Tablet	9	3	0	22.09	\N	New Drug DCM 01/25 -- 0.75mg RM 1,325.40/60's -- 0.25mg: RM 450.00/60's	2025-09-17 16:00:00	2025-11-20 11:24:34.708274
72	Agomelatine 25mg Tab (VALDOXAN) 	13	35	0	3.90	\N	UPDATED DCM 02/23 -- RM 108.36/ 28's	2025-09-17 16:00:00	2025-11-24 09:40:39.975808
100	Cholecalciferol 1000 IU Tab	10	15	0	0.34	\N	!! REQUIRES KPK APPROVAL !!\nDCM 02/24 - Update Quota 15 (+10)	2025-09-17 16:00:00	2025-10-27 10:12:09.96811
111	Mirabegron 50mg Prolonged Release Tablet	15	3	0	2.62	\N	New Drug DCM 01/25 -- RM 78.52/30's	2025-09-17 16:00:00	2025-11-20 11:21:44.472437
95	Sildenafil 100mg Tab	10	10	0	2.00	daily	\N	2025-09-17 16:00:00	2025-10-01 11:43:24.508612
96	Vigabatrin 500mg Tab	10	5	0	3.35	daily	\N	2025-09-17 16:00:00	2025-10-01 11:43:34.931373
89	Desloratadine 5mg Tab (AERIUS)	14	30	0	0.22	\N	\N	2025-09-17 16:00:00	2025-10-27 10:14:05.156036
92	Clobazam 10mg Tab (Paeds)	10	30	0	0.66	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:53:10.017436
68	Human chorionic gonadotropin (HCG) 5000iu inj (PREGNYL) 	12	20	0	0.21	\N	Quota 20 pt per year (TO SUPPLY MAX 2 TIMES PER YEAR FOR EACH PT) RM 38.40 per vial - 1 year max 2 vial	2025-09-17 16:00:00	2025-11-04 10:12:57.411343
93	Everolimus 5mg Tab	10	1	0	119.51	\N	RM 3,585.24 / 30's	2025-09-17 16:00:00	2025-11-11 12:34:10.104004
71	Insulin aspart 100 iu/ml (NOVORAPID) (O&G)	12	3	0	0.06	daily	\N	2025-09-17 16:00:00	2025-10-01 11:46:22.60343
104	Insulin Detemir 100iu/ml (LEVEMIR) (Paeds)	10	30	0	0.10	\N	(Case Basis)	2025-09-17 16:00:00	2025-10-29 14:52:44.072478
98	Levofloxacin 500mg Tab (Paeds)	10	30	0	1.42	\N	DCM 02/23 - Update Case Basis	2025-09-17 16:00:00	2025-10-29 14:52:52.710816
113	Insulin Glargine 300 IU/ 3 ml Inj	10	3	0	0.07	daily	DCM 02/25 - NEW DRUG	2025-10-01 12:19:03.049346	2025-10-01 12:19:03.049346
110	KIV OPEN Amantadine 100mg Cap	15	2	0	0.92	\N	Updated DCM 01/25 -- RM 91.73 / 100's	2025-09-17 16:00:00	2025-11-20 11:22:09.606845
107	Empagliflozin 25mg Tab (JARDIANCE) (Nephro)	9	10	0	1.73	\N	Updated DCM 02/24 -- RM 49.86 / 30's	2025-09-17 16:00:00	2025-11-20 11:22:56.930879
74	Aripiprazole 400mg Injection	13	2	0	22.90	\N	UPDATED DCM 01/24 -- RM 686.50/vial	2025-09-17 16:00:00	2025-11-24 15:34:34.573441
103	Insulin Aspart 100iu/ml (NOVORAPID) (Paeds)	10	30	0	0.06	\N	(Case Basis)	2025-09-17 16:00:00	2025-10-29 14:52:33.063657
91	KIV OPEN Desloratadine 2.5mg/5ml Syrup	14	5	0	8.86	daily	DCM 02/24 - New Drug	2025-09-17 16:00:00	2025-10-03 12:03:07.818268
61	Betamethasone/Salicylic Acid lotion	21	10	0	0.60	\N	DCM 02/24 - New Drug || BETAMETHASONE DIPROPIONATE 0.064% & SALICYLIC ACID 2% LOTION || RM 17.74/30ml	2025-09-17 16:00:00	2025-11-05 11:55:29.953303
67	Etonogestrel 68 mg Implant (IMPLANON)	12	5	0	0.84	\N	Quota 5 patients per year (A single IMPLANON is inserted for 3 years) RM 304.35 per unit	2025-09-17 16:00:00	2025-11-04 10:11:13.136999
70	Progesterone 100mg Capsule/Pessary	12	10	0	2.37	\N	DCM 01/24 - New Drug	2025-09-17 16:00:00	2025-10-27 12:01:09.928378
66	Dienogest 2mg Tab	12	15	0	5.00	\N	DCM 01/24 - Update Quota 15 -- \n1 Tab OD	2025-09-17 16:00:00	2025-10-27 12:01:37.223724
69	Levonorgestrel 52mg intrauterin (MIRENA) 	12	10	0	1.75	\N	Quota 10 pt per year (One MIRENA IUD is effective for 5 years) RM 637.08 per unit	2025-09-17 16:00:00	2025-11-04 10:10:54.19364
101	Multivitamin Infant Drops (APPETON)	10	20	0	0.64	\N	DCM 02/23 - Add Outpatient -- RM 19.25/30ml\n	2025-09-17 16:00:00	2025-11-10 11:45:50.394608
75	Asenapine 5mg & 10mg Sublingual Tab (SAPHRIS)	13	5	0	8.86	\N	[5MG & 10MG] RM 531.30 / 60's	2025-09-17 16:00:00	2025-11-24 15:37:11.529247
78	Duloxetine 30mg & 60mg Cap (CYMBALTA)	13	15	0	0.97	\N	UPDATED DCM 02/23 -- 30MG RM 68.00/70's -- 60MG RM 86.00/100's	2025-09-17 16:00:00	2025-11-24 16:01:51.071324
76	Atomoxetine HCl 40mg Cap (STRATTERA)	13	1	0	0.85	\N	NEW DRUG DCM 02/24 - 168.70/200's -- REQ IMPORT PERMIT	2025-09-17 16:00:00	2025-11-24 15:41:21.714383
77	Brexpiprazole 4mg Film-Coated Tab	13	1	0	16.16	\N	NEW DRUG DCM 01/24 -- RM 452.58/28's -- KPK ITEM	2025-09-17 16:00:00	2025-11-24 15:42:31.473332
79	Methylphenidate XR 18 & 36mg Tab (CONCERTA)	13	15	0	11.67	\N	UPDATED DCM 02/23 -- 18MG RM 224.50/30's -- 36MG RM 350.00/30's	2025-09-17 16:00:00	2025-11-24 16:03:00.73387
81	Paliperidone 100mg // 150mg Injection (INVEGA SUSTENNA)	13	10	0	30.60	\N	UPDATED DCM 01/24 -- RM 917.67/pfs (Both 100 & 150mg) -- Monthly	2025-09-17 16:00:00	2025-11-24 16:09:08.020742
82	Paliperidone ER 3mg // 6mg // 9mg Tab (INVEGA)	13	15	0	13.52	\N	UPDATED DCM 02/23 - 3MG & 6MG RM378.50/28's -- 9MG RM454.40/28's	2025-09-17 16:00:00	2025-11-24 16:21:59.265605
90	Ciprofloxacin & Fluocinolone Ear Drops (CEFTRAXAL PLUS)	14	15	0	0.08	\N	RM 28.00 per bot -- \nInform DIS & KU OPD   @   Share dalam group jabatan jika ada kes (untuk follow up borang KPK (Patient Basis) -- \nDCM 02/23 - Update Quota 15 Patients PER YEAR\nIndication: For the treatment of acute otitis externa and acute otitis media in patients with tympanostomy tubes or tympanic membrane perforation. Administer 6 drops twice daily for 7 days.\n	2025-09-17 16:00:00	2025-11-11 10:10:40.699278
115	(2026) Insulin Glargine 300IU/3ml Inj (Prefilled Pen) 	10	3	0	0.07	\N	DCM 02/25 -- RM 101.70 / 5 pens/300 iu	2025-11-11 10:55:54.004286	2025-11-11 10:55:54.004286
116	(2026) Dolutegravir 50mg, Lamivudine 300mg, Tenofovir 300mg FC Tab	10	2	0	6.97	\N	DCM 02/25 -- RM 209.00 / 30 tab -- Dose 1 tab od	2025-11-11 10:57:25.840668	2025-11-11 10:57:25.840668
117	(2026) Ciclosporin 0.5% Eye Drop	11	1	0	2.00	\N	DCM 02/25 -- Cost RM 729.60 / patient / year\n	2025-11-11 10:58:40.595169	2025-11-11 10:58:40.595169
118	(2026) Diltiazem 100mg SR Cap	6	1	0	0.95	\N	DCM 02/25 -- RM 94.60 / 100's -- RM 345.29/ patient / year -- Dose 100mg od\n	2025-11-11 10:59:55.297681	2025-11-11 10:59:55.297681
119	(2026) Calcipotriol 50mcg/g & Betamethasone Dipropionate 0.5mg/g Cutaneous Foam	21	2	0	6.40	\N	DCM 02/25 -- RM 233.50/60g -- RM 2,335.00/ patient / year\n\n	2025-11-11 11:01:15.246594	2025-11-11 11:01:15.246594
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollments (id, drug_id, patient_id, prescription_start_date, prescription_end_date, latest_refill_date, spub, remarks, cost_per_year, is_active, created_at, updated_at, dose_per_day, cost_per_day) FROM stdin;
66	107	917	2025-01-16	\N	2025-05-08	t	\N	303.32	t	2025-10-07 14:00:51.131178	2025-10-22 12:27:23.645266	12.5mg od	0.83
28	8	1813	2025-08-14	2025-03-15	2025-03-15	t	\N	671.60	t	2025-09-18 16:19:23.804208	2025-10-29 16:00:03.300542	100mg bd	1.84
34	112	1094	2025-04-24	2025-07-24	2025-10-03	\N	1.2g BD 1/52 then 2.4g BD 12/52	1664.40	t	2025-10-01 10:47:43.989487	2025-10-03 11:15:58.382397	1.2g bd	4.56
30	8	1713	2025-05-15	2024-05-01	\N	t	STARTED BY DR NORA, S/T DR JOHAN	335.80	t	2025-09-22 09:51:53.559019	2025-10-06 11:11:14.258211	100mg od	0.92
33	109	1274	2025-08-28	2025-11-20	2025-09-24	f	(0.25mg + 0.75mg) x bd\nDr Nuzaimin	21600.70	t	2025-09-22 10:03:51.2937	2025-10-22 08:24:10.01877	1mg bd	59.18
32	109	1182	2025-08-28	2025-08-28	2025-08-28	f	0.75mg x3/3 bd started by Dr Nuzaimin	53852.10	t	2025-09-22 10:01:57.697623	2025-10-22 08:24:24.830333	2.25mg bd	147.54
31	109	985	2025-07-09	\N	2025-04-15	f	STARTED BY DR NUZAIMIN	72715.30	t	2025-09-22 09:59:11.038573	2025-10-22 08:25:07.533959	3.5mg om / 3.25mg on	199.22
53	105	142	2025-10-07	\N	2025-08-31	f	\N	219.00	t	2025-10-07 13:10:04.409613	2025-11-11 12:38:56.982071	\N	0.60
79	92	1277	2025-01-01	\N	2025-07-29	f	\N	481.80	t	2025-10-22 14:17:09.190611	2025-10-30 12:18:54.237037	10mg bd	1.32
60	106	86	2025-10-07	\N	2025-05-13	f	\N	2912.70	t	2025-10-07 13:26:00.98445	2025-10-22 12:07:22.533568	1600mg tds	7.98
52	105	1431	2025-10-07	\N	2025-07-03	\N	\N	219.00	t	2025-10-07 13:09:52.545013	2025-11-11 12:39:00.524415	\N	0.60
90	96	1244	2025-01-01	\N	2025-04-23	f	\N	3668.25	t	2025-10-27 09:09:57.628095	2025-10-29 15:56:54.092301	750mg bd	10.05
62	106	398	2025-10-07	\N	2025-04-03	f	\N	1456.35	t	2025-10-07 13:26:19.907185	2025-10-22 12:07:45.234155	800mg tds	3.99
55	106	577	2025-10-07	\N	2025-08-06	f	\N	1456.35	t	2025-10-07 13:23:11.909974	2025-10-22 12:07:55.549045	800mg tds	3.99
80	92	994	2025-01-01	\N	2025-01-07	f	\N	120.45	t	2025-10-22 14:18:22.034657	2025-10-30 12:19:10.873815	2.5mg bd	0.33
59	106	605	2025-10-07	\N	2025-02-20	f	\N	1456.35	t	2025-10-07 13:25:40.010788	2025-10-22 12:08:08.206751	800mg tds	3.99
58	106	608	2025-10-07	\N	2025-10-09	f	\N	1456.35	t	2025-10-07 13:25:28.577165	2025-10-22 12:08:25.524794	800mg tds	3.99
63	106	731	2025-10-07	\N	2025-08-11	f	\N	2912.70	t	2025-10-07 13:26:31.146642	2025-10-22 12:08:43.04302	1600mg tds	7.98
56	106	784	2025-10-07	\N	2025-09-10	t	\N	2912.70	t	2025-10-07 13:24:53.583748	2025-10-22 12:08:58.585441	1600mg tds	7.98
65	106	1007	2025-10-07	\N	2025-10-02	f	\N	1941.80	t	2025-10-07 13:26:50.099138	2025-10-22 12:09:13.529336	1600mg bd	5.32
61	106	1553	2025-10-07	\N	2025-05-13	f	\N	1456.35	t	2025-10-07 13:26:10.05642	2025-10-22 12:09:39.717327	800mg tds	3.99
76	106	1977	2025-10-09	\N	2025-10-09	f	Dr Fatimah	485.45	t	2025-10-22 12:05:32.694035	2025-10-22 12:09:48.425274	800mg od	1.33
64	106	1959	2025-10-07	\N	2025-07-24	f	\N	1456.35	t	2025-10-07 13:26:39.711298	2025-10-22 12:09:57.964777	800mg tds	3.99
83	92	148	2025-03-19	\N	2025-03-19	f	\N	60.23	t	2025-10-22 14:19:59.208444	2025-10-22 14:19:59.208444	2.5mg od	0.17
89	96	124	2025-01-01	\N	2025-09-12	f	\N	2445.50	t	2025-10-27 09:09:45.052254	2025-10-29 15:56:39.615237	500mg bd	6.70
27	8	1154	2025-06-24	2025-05-15	2025-10-29	\N	100MG OD STARTED BY DR.ADLINA (S/T DR. JOHAN)	335.80	t	2025-09-18 16:18:33.041453	2025-10-29 16:24:30.65968	100mg od	0.92
42	105	728	2025-10-07	\N	2025-05-08	\N	\N	219.00	t	2025-10-07 12:15:11.974177	2025-11-11 12:39:47.439841	\N	0.60
88	95	1978	2025-10-26	\N	2025-10-26	f	\N	730.00	t	2025-10-27 09:09:10.712124	2025-11-11 12:36:39.88513	0.7mg qid	2.00
78	92	1391	2025-01-01	\N	2025-01-08	t	DR HAWA S/T DR LIEW & NEURO VISIT, 10MG BD, SPUB KASAP	481.80	t	2025-10-22 12:55:22.166457	2025-10-30 12:18:50.944587	10mg bd	1.32
26	8	1800	2025-01-01	2025-06-30	2024-05-04	f	100MG BD STARTED BY DR JOHAN (SPUB KK JEMENTAH)	335.80	t	2025-09-18 16:16:43.773075	2025-10-30 12:18:57.122552	100mg bd	0.92
81	92	1225	2025-01-01	\N	2025-09-22	f	\N	120.45	t	2025-10-22 14:18:49.8132	2025-10-30 12:19:13.590395	5mg on	0.33
82	92	1689	2025-01-01	\N	2025-09-09	f	\N	240.90	t	2025-10-22 14:19:33.126181	2025-10-30 12:19:24.863273	5mg bd	0.66
117	90	207	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:35:45.881395	2025-11-11 12:31:13.672568	\N	0.08
116	90	1206	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:35:40.666574	2025-11-11 12:31:16.421597	\N	0.08
115	90	1299	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:35:34.22408	2025-11-11 12:31:18.529652	\N	0.08
114	90	781	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:35:25.412567	2025-11-11 12:31:21.141879	\N	0.08
113	90	1448	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:33:37.297401	2025-11-11 12:31:23.075175	\N	0.08
112	89	1762	2025-10-27	\N	2025-10-24	f	\N	80.30	t	2025-10-27 10:31:20.42242	2025-11-11 12:31:31.536094	\N	0.22
111	89	1983	2025-10-27	\N	2025-10-02	f	\N	80.30	t	2025-10-27 10:31:11.182105	2025-11-11 12:31:34.353923	\N	0.22
109	89	1733	2025-10-27	\N	2025-09-05	f	\N	80.30	t	2025-10-27 10:30:11.795873	2025-11-11 12:31:37.916759	\N	0.22
110	89	1982	2025-10-27	\N	2025-10-01	f	\N	80.30	t	2025-10-27 10:30:37.639412	2025-11-11 12:31:40.4241	\N	0.22
108	89	1049	2025-10-27	\N	2025-09-03	f	\N	80.30	t	2025-10-27 10:29:58.131138	2025-11-11 12:31:43.649276	\N	0.22
107	89	1649	2025-10-27	\N	2025-07-21	f	\N	80.30	t	2025-10-27 10:29:50.807579	2025-11-11 12:31:47.824445	\N	0.22
106	89	1016	2025-10-27	\N	2025-07-09	f	\N	80.30	t	2025-10-27 10:29:43.62085	2025-11-11 12:31:52.105622	\N	0.22
105	89	1744	2025-10-27	\N	2025-06-18	f	\N	80.30	t	2025-10-27 10:29:34.063972	2025-11-11 12:31:56.693633	\N	0.22
104	89	462	2025-10-27	\N	2025-10-15	f	\N	80.30	t	2025-10-27 10:29:24.619038	2025-11-11 12:31:59.23388	\N	0.22
103	89	1032	2025-10-27	\N	2025-02-12	f	\N	80.30	t	2025-10-27 10:29:16.443582	2025-11-11 12:32:03.816696	\N	0.22
102	89	308	2025-10-27	\N	2025-03-28	f	\N	80.30	t	2025-10-27 10:29:07.135667	2025-11-11 12:32:07.206256	\N	0.22
101	89	1830	2025-10-27	\N	2025-03-26	f	\N	80.30	t	2025-10-27 10:28:55.319141	2025-11-11 12:32:11.346471	\N	0.22
100	89	683	2025-10-27	\N	2025-07-08	f	\N	80.30	t	2025-10-27 10:28:42.59368	2025-11-11 12:32:15.151311	\N	0.22
99	89	201	2025-10-27	\N	2025-03-07	f	\N	80.30	t	2025-10-27 10:28:30.924045	2025-11-11 12:32:17.743496	\N	0.22
98	89	1132	2025-10-27	\N	2025-03-05	f	\N	80.30	t	2025-10-27 10:28:20.050184	2025-11-11 12:32:22.993542	\N	0.22
97	89	332	2025-10-27	\N	2025-01-16	f	\N	80.30	t	2025-10-27 10:27:23.772111	2025-11-11 12:32:25.98888	\N	0.22
96	89	59	2025-10-27	\N	2025-01-23	f	\N	80.30	t	2025-10-27 10:27:15.503924	2025-11-11 12:32:28.254999	\N	0.22
95	89	1826	2025-10-27	\N	2025-03-18	f	\N	80.30	t	2025-10-27 10:27:04.872172	2025-11-11 12:32:31.089129	\N	0.22
94	89	1163	2025-10-27	\N	2025-05-26	f	\N	80.30	t	2025-10-27 10:26:55.387965	2025-11-11 12:32:33.931321	\N	0.22
93	89	1965	2025-10-27	\N	2025-05-28	f	\N	80.30	t	2025-10-27 10:26:47.896743	2025-11-11 12:32:37.216483	\N	0.22
92	89	1681	2025-10-27	\N	2025-05-08	f	\N	80.30	t	2025-10-27 10:26:35.792992	2025-11-11 12:32:40.998177	\N	0.22
87	95	826	2025-10-22	\N	2025-10-22	f	\N	730.00	t	2025-10-27 09:08:26.910911	2025-11-11 12:36:42.994442	1mg tds	2.00
86	95	213	2025-09-02	\N	2025-09-02	f	\N	730.00	t	2025-10-27 09:07:31.063032	2025-11-11 12:36:45.943867	1mg qid	2.00
85	95	1242	2025-07-01	\N	2025-07-29	f	\N	730.00	t	2025-10-27 09:07:13.77668	2025-11-11 12:36:48.928223	10mg tds	2.00
84	95	1239	2025-07-01	\N	2025-07-29	f	\N	730.00	t	2025-10-27 09:06:56.201847	2025-11-11 12:36:51.464237	10mg tds	2.00
57	106	1194	2025-10-07	\N	2025-05-08	f	\N	2912.70	t	2025-10-07 13:25:10.361799	2025-11-11 12:37:29.103732	1.6g tds	7.98
51	105	1644	2025-10-07	\N	2025-07-18	\N	\N	219.00	t	2025-10-07 13:09:33.351427	2025-11-11 12:39:03.078286	\N	0.60
50	105	985	2025-10-07	\N	2025-04-15	\N	\N	219.00	t	2025-10-07 13:09:20.524664	2025-11-11 12:39:06.120782	\N	0.60
49	105	1351	2025-10-07	\N	2025-05-08	\N	\N	219.00	t	2025-10-07 13:09:05.982183	2025-11-11 12:39:10.039978	\N	0.60
48	105	608	2025-10-07	\N	2025-08-05	\N	\N	219.00	t	2025-10-07 13:08:50.558286	2025-11-11 12:39:13.312421	\N	0.60
47	105	1146	2025-10-07	\N	2025-05-08	\N	\N	219.00	t	2025-10-07 13:07:14.250667	2025-11-11 12:39:17.120301	\N	0.60
46	105	1064	2025-10-07	\N	2025-04-10	\N	\N	219.00	t	2025-10-07 13:06:58.28374	2025-11-11 12:39:19.392347	\N	0.60
44	105	1310	2025-10-07	\N	2025-07-17	\N	\N	219.00	t	2025-10-07 12:50:55.699573	2025-11-11 12:39:24.552342	\N	0.60
43	105	1346	2025-01-01	\N	2025-05-08	\N	\N	219.00	t	2025-10-07 12:16:19.639746	2025-11-11 12:39:26.92469	\N	0.60
41	105	539	2025-10-07	\N	2025-02-18	\N	\N	219.00	t	2025-10-07 12:14:40.139918	2025-11-11 12:39:50.104323	\N	0.60
40	105	1674	2025-10-07	\N	2025-08-04	\N	\N	219.00	t	2025-10-07 12:13:59.050891	2025-11-11 12:39:57.952079	\N	0.60
39	105	136	2025-10-07	\N	2025-08-27	f	\N	219.00	t	2025-10-07 12:13:46.160821	2025-11-20 11:04:38.035606	\N	0.60
177	20	1840	2025-10-09	2026-04-04	2025-10-09	f	\N	664.30	t	2025-10-29 10:07:09.179599	2025-10-29 10:11:53.293835	15mg od	1.82
139	68	1152	2025-10-27	\N	2025-10-27	f	\N	67.89	t	2025-10-27 11:11:33.54673	2025-10-27 11:12:35.713931	\N	0.19
133	68	1172	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:10:49.806739	2025-10-27 11:12:41.086203	\N	0.19
134	68	1198	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:10:55.90818	2025-10-27 11:12:43.683118	\N	0.19
136	68	1255	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:11.817398	2025-10-27 11:12:47.467245	\N	0.19
135	68	1314	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:03.698204	2025-10-27 11:12:50.739707	\N	0.19
132	68	1318	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:10:41.919878	2025-10-27 11:12:54.090184	\N	0.19
137	68	1399	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:19.372605	2025-10-27 11:12:56.799233	\N	0.19
140	68	1515	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:48.338225	2025-10-27 11:13:00.533187	\N	0.19
138	68	1787	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:25.864755	2025-10-27 11:13:03.562375	\N	0.19
131	68	1666	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:10:34.07058	2025-10-27 11:13:05.978577	\N	0.19
141	68	1973	2025-10-27	\N	2025-10-27	f	\N	69.35	t	2025-10-27 11:11:58.37624	2025-10-27 11:13:10.122495	\N	0.19
130	67	1232	2025-10-27	\N	2025-10-27	f	\N	306.60	t	2025-10-27 10:42:16.261594	2025-10-27 11:13:37.365685	\N	0.84
128	67	1431	2025-10-27	\N	2025-10-27	f	\N	306.60	t	2025-10-27 10:42:05.154308	2025-10-27 11:13:41.019012	\N	0.84
129	67	1477	2025-10-27	\N	2025-10-27	f	\N	306.60	t	2025-10-27 10:42:11.049856	2025-10-27 11:13:43.906074	\N	0.84
142	69	1718	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:42:18.703082	2025-10-27 11:42:18.703082	\N	1.75
143	69	1210	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:50:06.09199	2025-10-27 11:50:06.09199	\N	1.75
144	69	1599	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:50:46.757443	2025-10-27 11:50:52.649645	\N	1.75
145	69	348	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:51:33.968361	2025-10-27 11:51:33.968361	\N	1.75
146	69	1296	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:51:42.583679	2025-10-27 11:51:42.583679	\N	1.75
148	69	344	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:51:59.81551	2025-10-27 11:51:59.81551	\N	1.75
149	69	1653	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:52:10.21159	2025-10-27 11:52:10.21159	\N	1.75
158	66	1193	2025-03-20	\N	2025-05-21	f	\N	1825.00	t	2025-10-27 11:57:09.454749	2025-10-27 11:57:09.454749	\N	5.00
159	66	1266	2025-03-22	\N	2025-07-12	f	\N	1825.00	t	2025-10-27 11:57:27.670545	2025-10-27 11:57:46.828146	\N	5.00
160	66	1711	2025-04-10	\N	2025-08-21	f	\N	1825.00	t	2025-10-27 11:58:05.680059	2025-10-27 11:58:05.680059	\N	5.00
161	66	1123	2025-05-15	\N	2025-09-25	f	\N	1825.00	t	2025-10-27 11:58:19.797729	2025-10-27 11:58:19.797729	\N	5.00
162	66	1171	2025-05-22	\N	2025-10-09	f	\N	1825.00	t	2025-10-27 11:58:30.842863	2025-10-27 11:58:30.842863	\N	5.00
163	66	1507	2025-05-10	\N	2025-10-27	f	\N	1825.00	t	2025-10-27 11:58:43.720608	2025-10-27 11:58:43.720608	\N	5.00
164	70	1985	2025-10-24	\N	2025-10-24	f	\N	1730.10	t	2025-10-27 12:01:06.264641	2025-10-27 12:02:26.894826	100mg bd PV	4.74
165	70	191	2025-04-06	\N	2025-04-07	f	\N	3460.20	t	2025-10-27 12:03:56.185225	2025-10-27 12:03:56.185225	200mg bd	9.48
166	70	1428	2025-05-22	\N	2025-05-22	f	\N	865.05	t	2025-10-27 12:04:17.403011	2025-10-27 12:04:17.403011	100mg od	2.37
167	70	1264	2025-06-12	\N	2025-10-16	f	\N	1730.10	t	2025-10-27 12:04:48.950088	2025-10-27 12:04:48.950088	100mg bd	4.74
168	70	1280	2025-07-09	\N	2025-10-14	f	\N	1730.10	t	2025-10-27 12:05:09.362222	2025-10-27 12:05:09.362222	100mg bd	4.74
169	70	1710	2025-10-27	\N	2025-11-12	f	\N	3460.20	t	2025-10-27 12:06:44.686128	2025-10-27 12:06:44.686128	200mg bd	9.48
170	70	1268	2025-08-24	\N	2025-08-24	f	\N	1730.10	t	2025-10-27 12:07:16.848522	2025-10-27 12:07:16.848522	100mg bd	4.74
171	70	1258	2025-08-29	\N	2025-08-29	f	\N	1730.10	t	2025-10-27 12:07:35.040955	2025-10-27 12:07:35.040955	100mg bd	4.74
172	70	1986	2025-10-03	\N	2025-10-03	f	\N	1730.10	t	2025-10-27 12:08:23.23236	2025-10-27 12:08:23.23236	200mg od	4.74
175	20	1873	2025-09-25	2026-04-23	2025-10-23	f	\N	1328.60	t	2025-10-29 10:04:48.418258	2025-10-29 10:04:48.418258	15mg bd	3.64
176	20	627	2025-08-08	2025-12-01	2025-08-08	f	\N	664.30	t	2025-10-29 10:06:23.016903	2025-10-29 10:06:23.016903	15mg od	1.82
179	20	1406	2025-07-07	2026-01-05	2025-09-17	f	\N	1328.60	t	2025-10-29 10:15:36.508389	2025-10-29 10:15:36.508389	15mg bd	3.64
180	20	94	2025-10-16	2026-04-14	2025-10-16	f	\N	664.30	t	2025-10-29 10:16:32.259252	2025-10-29 10:16:32.259252	15mg od	1.82
181	20	1970	2025-10-09	2026-04-09	2025-10-29	t	\N	1328.60	t	2025-10-29 10:17:13.722778	2025-10-29 10:17:13.722778	15mg bd	3.64
182	20	1805	2025-08-18	2026-02-16	2025-08-18	t	SPUB KK Pekan Air Panas	1328.60	t	2025-10-29 10:22:49.312871	2025-10-29 10:22:49.312871	15mg bd	3.64
183	20	57	2025-05-26	2026-05-11	2025-10-22	f	\N	1328.60	t	2025-10-29 10:24:21.90896	2025-10-29 10:24:21.90896	15mg bd	3.64
184	20	1115	2025-04-11	2025-12-01	2025-06-06	f	\N	664.30	t	2025-10-29 10:42:50.320106	2025-10-29 10:42:50.320106	15mg od	1.82
185	20	1549	2025-05-26	2025-11-17	2025-09-26	f	\N	1328.60	t	2025-10-29 10:43:27.175321	2025-10-29 10:43:27.175321	15mg bd	3.64
186	20	1415	2025-06-09	2026-01-26	2025-08-11	f	\N	1328.60	t	2025-10-29 10:44:30.937138	2025-10-29 10:44:30.937138	15mg bd	3.64
187	20	913	2025-08-18	2026-02-19	2025-08-18	t	SPUB KK JEMENTAH	1328.60	t	2025-10-29 10:45:42.012114	2025-10-29 10:45:42.012114	15mg bd	3.64
188	20	1811	2025-10-13	2026-04-30	2025-10-29	f	\N	1328.60	t	2025-10-29 10:47:01.528402	2025-10-29 10:47:01.528402	15mg bd	3.64
189	20	564	2025-10-13	2026-04-30	2025-10-13	f	\N	1328.60	t	2025-10-29 10:47:41.351103	2025-10-29 10:47:41.351103	15mg bd	3.64
190	20	446	2025-06-26	\N	2025-09-30	f	\N	0.00	f	2025-10-29 10:50:03.402654	2025-10-29 10:50:35.616987	\N	0.00
178	20	503	2025-03-27	2025-12-29	2025-03-27	t	STARTED BY DR DINESH TCA DR 150724 (SPUB PERWIRA JAYA)	1992.90	t	2025-10-29 10:14:45.257868	2025-10-29 10:50:57.894429	15mg tds	5.46
147	69	1200	2025-10-27	\N	2025-10-27	f	\N	638.75	t	2025-10-27 11:51:50.041344	2025-10-29 15:44:35.884018	\N	1.75
29	8	1896	2025-03-26	2025-06-24	2025-09-22	\N	100MG BD STARTED BY DR VEELOSHINA S/T DR JOHAN	671.60	t	2025-09-18 16:25:14.175155	2025-10-29 16:00:00.564876	100mg bd	1.84
174	19	1097	2025-01-01	\N	2025-05-23	f	\N	981.85	t	2025-10-27 12:27:09.34534	2025-10-30 12:18:21.197251	\N	2.69
173	19	291	2025-01-01	\N	2025-09-29	f	\N	981.85	t	2025-10-27 12:26:46.846785	2025-10-30 12:18:31.970257	\N	2.69
150	66	1939	2025-01-01	\N	2025-03-11	f	\N	1825.00	t	2025-10-27 11:54:41.908899	2025-10-30 12:18:59.829238	\N	5.00
151	66	1648	2025-01-01	\N	2025-10-10	f	\N	1825.00	t	2025-10-27 11:54:54.891114	2025-10-30 12:19:02.490901	\N	5.00
152	66	1179	2025-01-01	\N	2025-10-09	f	\N	1825.00	t	2025-10-27 11:55:07.624735	2025-10-30 12:19:05.563882	\N	5.00
153	66	1322	2025-01-01	\N	2025-08-08	f	\N	1825.00	t	2025-10-27 11:55:34.578313	2025-10-30 12:19:08.171882	\N	5.00
154	66	1580	2025-01-01	\N	2025-03-27	f	\N	1825.00	t	2025-10-27 11:55:52.744496	2025-10-30 12:19:16.556391	\N	5.00
155	66	1544	2025-01-01	\N	2025-06-19	f		1825.00	t	2025-10-27 11:56:18.449281	2025-10-30 12:19:18.65206	\N	5.00
156	66	1569	2025-01-01	\N	2025-10-23	f	\N	1825.00	t	2025-10-27 11:56:34.56832	2025-10-30 12:19:21.342044	\N	5.00
157	66	1170	2025-01-01	\N	2025-09-04	f	\N	1825.00	t	2025-10-27 11:56:54.742654	2025-10-30 12:19:58.442652	\N	5.00
127	90	903	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:37:40.026397	2025-11-11 12:30:47.822864	\N	0.08
193	7	194	2025-05-20	\N	2025-11-04	f	\N	13140.00	t	2025-11-04 09:01:16.811618	2025-11-04 09:01:16.811618	\N	36.00
194	7	138	2025-09-17	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:01:29.788919	2025-11-04 09:01:29.788919	\N	3.60
195	7	624	2025-11-04	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:01:53.647282	2025-11-04 09:01:53.647282	\N	3.60
196	7	1488	2025-07-08	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:02:07.923914	2025-11-04 09:02:07.923914	\N	3.60
198	7	354	2025-04-23	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:02:48.394386	2025-11-04 09:02:48.394386	\N	3.60
191	5	84	2025-10-31	\N	2025-06-25	f	\N	175.20	t	2025-10-31 12:09:08.380425	2025-11-11 08:42:49.542422	\N	0.48
126	90	1984	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:37:26.90569	2025-11-11 12:30:52.356297	\N	0.08
125	90	725	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:37:06.368898	2025-11-11 12:30:55.792354	\N	0.08
124	90	1260	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:37:00.881277	2025-11-11 12:30:58.097064	\N	0.08
123	90	1748	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:55.185472	2025-11-11 12:31:00.675977	\N	0.08
121	90	751	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:41.838224	2025-11-11 12:31:04.552757	\N	0.08
120	90	433	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:34.682897	2025-11-11 12:31:07.169342	\N	0.08
119	90	99	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:27.84394	2025-11-11 12:31:09.26312	\N	0.08
118	90	324	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:18.3669	2025-11-11 12:31:11.527582	\N	0.08
197	7	1471	2025-02-18	\N	2025-11-04	f	\N	1314.00	f	2025-11-04 09:02:24.751977	2025-11-20 09:50:21.344375	\N	3.60
199	7	1821	2025-05-21	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:03:15.447467	2025-11-04 09:03:15.447467	\N	3.60
200	7	1756	2025-05-28	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:03:34.202596	2025-11-04 09:03:34.202596	\N	3.60
201	7	1903	2025-10-22	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:03:43.676388	2025-11-04 09:03:43.676388	\N	3.60
202	7	625	2025-09-29	\N	2025-11-04	f	\N	1314.00	t	2025-11-04 09:03:55.487401	2025-11-04 09:03:55.487401	\N	3.60
274	25	1955	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:54:49.89334	2025-11-10 12:54:49.89334	\N	0.14
204	24	1750	2024-03-19	\N	2025-01-07	f	DAPAT KPK APPROVAL @20.2.24 S/T MR NAZRI (210mg/2 pfs per month)	34456.00	t	2025-11-04 16:21:00.013791	2025-11-04 16:23:08.278632	210mg monthly	94.40
205	72	252	2025-11-04	\N	2025-10-29	f	\N	2847.00	t	2025-11-04 16:32:08.063731	2025-11-04 16:32:08.063731	50mg on	7.80
206	23	1987	2025-10-21	\N	2025-11-05	f	\N	365.00	t	2025-11-05 11:53:08.143844	2025-11-05 11:53:08.143844	\N	1.00
207	61	1988	2025-10-13	\N	2025-11-05	f	\N	219.00	t	2025-11-05 11:55:01.065358	2025-11-05 11:55:33.341179	\N	0.60
208	54	1567	2025-11-05	\N	2025-08-08	f	\N	1470.95	t	2025-11-05 11:56:44.357168	2025-11-05 11:56:44.357168	600mg on	4.03
209	100	1305	2024-02-09	\N	2025-11-10	f	\N	124.10	t	2025-11-10 11:05:22.752913	2025-11-10 11:05:22.752913	\N	0.34
210	100	27	2025-11-10	\N	2025-03-05	f	\N	124.10	t	2025-11-10 11:05:49.711371	2025-11-10 11:05:49.711371	1000 iu od	0.34
211	100	330	2025-11-10	\N	2025-12-08	f	\N	124.10	t	2025-11-10 11:06:17.0064	2025-11-10 11:06:17.0064	1000 iu od	0.34
212	100	1042	2025-11-10	\N	2025-11-24	f	\N	124.10	t	2025-11-10 11:06:47.374577	2025-11-10 11:06:47.374577	1000 iu od	0.34
213	100	988	2025-11-10	\N	2025-11-10	f	\N	124.10	t	2025-11-10 11:07:15.941959	2025-11-10 11:07:15.941959	\N	0.34
214	100	822	2025-11-10	\N	2025-10-04	f	\N	248.20	t	2025-11-10 11:24:03.316111	2025-11-10 11:24:03.316111	2000iu od	0.68
215	100	1989	2025-11-10	\N	2025-11-03	f	\N	124.10	t	2025-11-10 11:24:39.808585	2025-11-10 11:24:39.808585	1000iu od	0.34
216	100	1990	2025-11-10	\N	2025-11-10	f	\N	124.10	t	2025-11-10 11:25:50.606225	2025-11-10 11:25:50.606225	1000iu od	0.34
217	100	1991	2025-11-10	\N	2025-11-10	f	\N	124.10	t	2025-11-10 11:26:10.148719	2025-11-10 11:26:10.148719	400iu od	0.34
218	100	1992	2025-11-10	\N	2025-11-10	f	\N	124.10	t	2025-11-10 11:26:31.158443	2025-11-10 11:26:31.158443	400iu od	0.34
219	101	1003	2025-11-10	\N	2025-07-09	f	\N	233.60	t	2025-11-10 11:46:05.634037	2025-11-10 11:46:05.634037	\N	0.64
220	101	826	2025-11-10	\N	2025-08-07	f	\N	233.60	t	2025-11-10 11:46:19.356425	2025-11-10 11:46:19.356425	\N	0.64
221	101	211	2025-11-10	\N	2025-07-06	f	\N	233.60	t	2025-11-10 11:46:34.480976	2025-11-10 11:46:34.480976	\N	0.64
222	101	1253	2025-11-10	\N	2025-10-14	f	\N	233.60	t	2025-11-10 11:46:44.655306	2025-11-10 11:46:44.655306	\N	0.64
223	101	241	2025-11-10	\N	2025-11-06	f	\N	233.60	t	2025-11-10 11:47:07.30549	2025-11-10 11:47:07.30549	\N	0.64
224	101	1034	2025-11-10	\N	2025-06-04	f	\N	233.60	t	2025-11-10 11:48:14.50019	2025-11-10 11:48:14.50019	\N	0.64
225	101	226	2025-11-10	\N	2025-06-04	f	\N	233.60	t	2025-11-10 11:50:34.859863	2025-11-10 11:50:34.859863	\N	0.64
226	101	991	2025-11-10	\N	2025-10-22	f	\N	233.60	t	2025-11-10 11:50:49.900781	2025-11-10 11:50:49.900781	\N	0.64
227	101	1014	2025-11-10	\N	2025-09-11	f	\N	233.60	t	2025-11-10 11:51:04.98775	2025-11-10 11:51:04.98775	\N	0.64
228	101	1392	2025-11-10	2026-01-12	2026-01-12	f	\N	233.60	t	2025-11-10 11:52:01.312124	2025-11-10 11:52:01.312124	\N	0.64
229	101	214	2025-11-10	\N	2025-07-14	f	\N	233.60	t	2025-11-10 11:52:34.288059	2025-11-10 11:52:34.288059	\N	0.64
230	101	1993	2025-11-10	\N	2025-06-16	f	\N	233.60	t	2025-11-10 11:52:55.772003	2025-11-10 11:52:55.772003	\N	0.64
231	101	217	2025-11-10	\N	2025-07-18	f	\N	233.60	t	2025-11-10 11:53:19.708829	2025-11-10 11:53:19.708829	\N	0.64
232	101	242	2025-11-10	\N	2025-11-04	f	\N	233.60	t	2025-11-10 11:53:31.994076	2025-11-10 11:53:31.994076	\N	0.64
233	101	1994	2025-11-10	\N	2025-10-01	f	\N	233.60	t	2025-11-10 11:53:49.792278	2025-11-10 11:53:49.792278	\N	0.64
234	101	239	2025-11-10	\N	2025-11-03	f	\N	233.60	t	2025-11-10 11:53:59.286328	2025-11-10 11:53:59.286328	\N	0.64
235	101	1995	2025-11-10	\N	2025-11-04	f	\N	233.60	t	2025-11-10 11:54:20.793102	2025-11-10 11:54:20.793102	\N	0.64
236	101	216	2025-11-10	\N	2025-10-02	f	\N	233.60	t	2025-11-10 11:54:32.279054	2025-11-10 11:54:32.279054	\N	0.64
237	101	999	2025-11-10	\N	2025-09-17	f	\N	233.60	t	2025-11-10 11:54:42.111995	2025-11-10 11:54:42.111995	\N	0.64
238	23	270	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:12.765458	2025-11-10 12:38:12.765458	\N	1.00
239	23	340	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:21.090197	2025-11-10 12:38:21.090197	\N	1.00
240	23	376	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:27.371356	2025-11-10 12:38:27.371356	\N	1.00
241	23	384	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:32.877	2025-11-10 12:38:32.877	\N	1.00
242	23	532	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:40.19172	2025-11-10 12:38:40.19172	\N	1.00
243	23	655	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:51.374498	2025-11-10 12:38:51.374498	\N	1.00
244	23	654	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:38:59.572946	2025-11-10 12:38:59.572946	\N	1.00
245	23	659	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:12.43416	2025-11-10 12:39:12.43416	\N	1.00
246	23	703	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:21.612523	2025-11-10 12:39:21.612523	\N	1.00
247	23	757	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:31.186099	2025-11-10 12:39:31.186099	\N	1.00
248	23	884	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:39.084076	2025-11-10 12:39:39.084076	\N	1.00
249	23	1000	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:44.387587	2025-11-10 12:39:44.387587	\N	1.00
250	23	1041	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:50.316197	2025-11-10 12:39:50.316197	\N	1.00
251	23	1099	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:39:56.002382	2025-11-10 12:39:56.002382	\N	1.00
252	23	1107	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:01.485644	2025-11-10 12:40:01.485644	\N	1.00
253	23	1112	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:07.23427	2025-11-10 12:40:07.23427	\N	1.00
254	23	1227	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:15.957647	2025-11-10 12:40:15.957647		1.00
255	23	1331	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:21.578851	2025-11-10 12:40:21.578851	\N	1.00
256	23	1370	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:27.861904	2025-11-10 12:40:27.861904	\N	1.00
257	23	1475	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:33.375403	2025-11-10 12:40:33.375403	\N	1.00
258	23	1551	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:38.868098	2025-11-10 12:40:38.868098	\N	1.00
259	23	1797	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:44.590947	2025-11-10 12:40:44.590947	\N	1.00
260	23	1891	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:49.754363	2025-11-10 12:40:49.754363	\N	1.00
261	23	1908	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:40:55.403642	2025-11-10 12:40:55.403642	\N	1.00
262	23	332	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:41:00.401905	2025-11-10 12:41:00.401905	\N	1.00
264	23	1997	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:41:23.309184	2025-11-10 12:41:23.309184	\N	1.00
265	23	1998	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:41:35.769866	2025-11-10 12:41:35.769866	\N	1.00
266	23	1999	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:41:53.849154	2025-11-10 12:41:53.849154	\N	1.00
267	25	134	2025-11-10	\N	2025-04-29	f	\N	51.10	t	2025-11-10 12:53:14.940142	2025-11-10 12:53:14.940142	\N	0.14
268	25	1859	2025-11-10	\N	2025-07-27	f	\N	51.10	t	2025-11-10 12:53:31.020614	2025-11-10 12:53:31.020614	\N	0.14
269	25	1329	2025-11-10	\N	2025-10-15	f	\N	51.10	t	2025-11-10 12:53:41.767995	2025-11-10 12:53:41.767995	\N	0.14
270	25	1779	2025-11-10	\N	2025-08-12	f	\N	51.10	t	2025-11-10 12:53:53.268069	2025-11-10 12:53:53.268069	\N	0.14
271	25	664	2025-11-10	\N	2025-10-07	f	\N	51.10	t	2025-11-10 12:54:11.019609	2025-11-10 12:54:11.019609	\N	0.14
272	25	1614	2025-11-10	\N	2025-09-03	f	\N	51.10	t	2025-11-10 12:54:25.682588	2025-11-10 12:54:25.682588	\N	0.14
273	25	580	2025-11-10	\N	2025-08-27	f	\N	51.10	t	2025-11-10 12:54:37.160404	2025-11-10 12:54:37.160404	\N	0.14
275	25	932	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:06.572954	2025-11-10 12:55:06.572954	\N	0.14
276	25	1949	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:17.390381	2025-11-10 12:55:17.390381	\N	0.14
277	25	637	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:23.591499	2025-11-10 12:55:23.591499	\N	0.14
278	25	696	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:29.944302	2025-11-10 12:55:29.944302	\N	0.14
279	25	1819	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:36.735035	2025-11-10 12:55:36.735035	\N	0.14
280	25	2000	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:55:49.29278	2025-11-10 12:55:49.29278	\N	0.14
282	25	2002	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:56:36.901176	2025-11-10 12:56:36.901176	\N	0.14
283	25	2003	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:56:54.04004	2025-11-10 12:56:54.04004	\N	0.14
284	25	2004	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:57:23.451938	2025-11-10 12:57:23.451938	\N	0.14
281	25	2001	2025-11-10	\N	2025-11-11	f	\N	51.10	t	2025-11-10 12:56:11.082278	2025-11-11 15:55:01.311693	\N	0.14
263	23	1996	2025-11-10	\N	2025-11-10	f	\N	365.00	t	2025-11-10 12:41:13.760558	2025-11-23 16:03:38.770482	\N	1.00
285	25	2005	2025-11-10	\N	2025-11-10	f	\N	51.10	t	2025-11-10 12:57:36.220895	2025-11-10 12:57:36.220895	\N	0.14
203	7	1101	2025-11-04	\N	2025-11-04	f	Reserved Slot - Currently In Waiting List	1314.00	t	2025-11-04 09:04:44.548745	2025-11-11 12:30:35.40826	\N	3.60
340	73	1369	2025-11-24	\N	2025-11-24	f	STARTED BY DR TAN JIN KIAT\n	2923.65	t	2025-11-24 15:25:14.064797	2025-11-24 15:25:14.064797	200MG/400MG BD	8.01
122	90	1554	2025-10-27	\N	2025-10-27	f	\N	29.20	t	2025-10-27 10:36:48.864589	2025-11-11 12:31:02.537338	\N	0.08
91	93	1319	2025-01-01	\N	2025-08-15	f	\N	43621.15	t	2025-10-27 09:10:31.852427	2025-11-11 12:36:08.506018	3.75mg od	119.51
45	105	549	2025-10-07	\N	2025-08-01	\N	\N	219.00	t	2025-10-07 12:54:35.90419	2025-11-11 12:39:21.639367	\N	0.60
341	73	1503	2025-11-24	\N	2025-11-24	f	\n	2923.65	t	2025-11-24 15:25:35.516929	2025-11-24 15:25:35.516929	200mg / 600mg BD	8.01
342	73	1546	2025-11-24	\N	2025-11-24	f	spub kk batu6\n	1901.65	t	2025-11-24 15:25:57.136304	2025-11-24 15:25:57.136304	400MG ON	5.21
192	5	98	2025-10-31	\N	2026-02-12	f	\N	175.20	t	2025-10-31 12:09:49.456956	2025-11-11 15:56:42.476102	\N	0.48
289	72	687	2025-11-24	\N	2025-02-28	f	\N	2847.00	t	2025-11-24 09:41:33.582801	2025-11-24 09:41:33.582801	50mg on	7.80
290	72	1361	2025-11-24	\N	2025-08-04	f	\N	2847.00	t	2025-11-24 09:42:15.910824	2025-11-24 09:42:15.910824	50mg on	7.80
291	72	1380	2025-11-24	\N	2025-03-04	f	\N	1423.50	t	2025-11-24 09:42:37.226411	2025-11-24 09:42:37.226411	25mg on	3.90
292	72	1385	2025-11-24	\N	2026-02-04	f	\N	2847.00	t	2025-11-24 09:42:59.874291	2025-11-24 09:42:59.874291	50MG ON	7.80
293	72	1876	2025-11-24	\N	2025-11-24	f	\N	2847.00	t	2025-11-24 09:51:04.288311	2025-11-24 09:51:04.288311	50mg on	7.80
294	72	1882	2025-11-24	\N	2025-11-03	f	\N	2847.00	t	2025-11-24 09:51:22.118447	2025-11-24 09:51:22.118447	50mg on	7.80
295	72	1898	2025-11-24	\N	2025-09-02	f	\N	1423.50	t	2025-11-24 09:51:36.298995	2025-11-24 09:51:36.298995	25mg on	3.90
296	72	1902	2025-11-24	\N	2025-05-05	f	\N	2847.00	t	2025-11-24 09:51:51.476893	2025-11-24 09:51:51.476893	50mg on	7.80
297	72	1433	2025-11-24	\N	2025-11-21	f	\N	2847.00	t	2025-11-24 09:52:28.585317	2025-11-24 09:52:28.585317	50mg on	7.80
298	72	1624	2025-11-24	\N	2025-11-27	f	\N	2847.00	t	2025-11-24 09:52:47.23198	2025-11-24 09:52:47.23198	50mg on	7.80
299	72	255	2025-11-24	\N	2025-10-02	f	\N	2847.00	t	2025-11-24 09:53:49.180798	2025-11-24 09:53:49.180798	50mg on	7.80
300	72	1683	2025-11-24	\N	2025-11-19	f	\N	2847.00	t	2025-11-24 09:54:02.060456	2025-11-24 09:54:02.060456	50mg on	7.80
301	72	1125	2025-11-24	\N	2025-09-03	f	\N	2847.00	t	2025-11-24 09:54:18.067224	2025-11-24 09:54:18.067224	50mg on	7.80
302	72	546	2025-11-24	\N	2025-08-21	f	\N	2847.00	t	2025-11-24 09:54:31.319943	2025-11-24 09:54:31.319943	50mg on	7.80
303	72	1763	2025-11-24	\N	2025-11-13	f	\N	2847.00	t	2025-11-24 09:54:47.567697	2025-11-24 09:54:47.567697	50mg on	7.80
304	72	1149	2025-11-24	\N	2025-11-13	f	\N	2847.00	t	2025-11-24 09:55:40.873599	2025-11-24 09:55:40.873599	50mg on	7.80
305	72	714	2025-11-24	\N	2025-11-13	f	\N	1423.50	t	2025-11-24 09:55:54.246575	2025-11-24 09:55:54.246575	25mg on	3.90
306	72	769	2025-11-24	\N	2025-11-24	f	\N	1423.50	t	2025-11-24 09:56:06.516704	2025-11-24 09:56:06.516704	25mg on	3.90
307	72	254	2025-11-24	\N	2025-10-29	f	\N	2847.00	t	2025-11-24 09:56:50.82474	2025-11-24 09:56:50.82474	50mg on	7.80
308	72	436	2025-11-24	\N	2025-05-30	f	\N	2847.00	t	2025-11-24 09:57:20.675984	2025-11-24 09:57:20.675984	50mg on	7.80
309	72	489	2025-11-24	\N	2025-09-04	f	\N	2847.00	t	2025-11-24 09:57:43.166607	2025-11-24 09:57:43.166607	50mg on	7.80
310	72	206	2025-11-24	\N	2025-09-22	f	\N	2847.00	t	2025-11-24 09:57:55.148961	2025-11-24 09:57:55.148961	50mg on	7.80
311	72	321	2025-11-24	\N	2025-09-08	f	\N	1423.50	t	2025-11-24 09:58:11.498978	2025-11-24 09:58:11.498978	25mg on	3.90
312	72	1074	2025-11-24	\N	2025-11-05	f	\N	2847.00	t	2025-11-24 09:58:32.877888	2025-11-24 09:58:32.877888	50mg on	7.80
313	72	1219	2025-11-24	\N	2025-07-30	f	\N	1423.50	t	2025-11-24 09:58:46.143717	2025-11-24 09:58:46.143717	25mg on	3.90
314	72	1262	2025-11-24	\N	2025-09-18	f	\N	1423.50	t	2025-11-24 09:58:58.087712	2025-11-24 09:58:58.087712	25mg on	3.90
315	72	1183	2025-11-24	\N	2025-11-24	f	\N	1423.50	t	2025-11-24 09:59:11.875631	2025-11-24 09:59:11.875631	25mg on	3.90
316	72	322	2025-11-24	\N	2025-09-22	f	\N	2847.00	t	2025-11-24 09:59:22.488997	2025-11-24 09:59:22.488997	50mg on	7.80
317	73	338	2025-11-24	\N	2025-10-27	t	SPUB KK JEMENTAH (MENTARI)\n	4314.30	t	2025-11-24 15:00:53.503298	2025-11-24 15:00:53.503298	400MG OM/800MG ON	11.82
318	73	507	2025-11-24	\N	2025-10-27	t	spub kk perwira jaya\n	3803.30	t	2025-11-24 15:01:17.127776	2025-11-24 15:01:17.127776	400 MG BD	10.42
319	73	566	2025-11-24	\N	2026-01-21	t	SPUB KK PERWIRA JAYA\n	1022.00	t	2025-11-24 15:01:56.791089	2025-11-24 15:01:56.791089	200 MG ON	2.80
320	73	599	2025-11-24	\N	2025-10-01	f	Mentari\n	5704.95	t	2025-11-24 15:02:12.527784	2025-11-24 15:02:12.527784	400/800 MG BD	15.63
321	73	303	2025-11-24	\N	2025-12-29	f	\N	3803.30	t	2025-11-24 15:03:05.28199	2025-11-24 15:03:05.28199	400mg BD	10.42
322	73	471	2025-11-24	\N	2025-11-13	f	STARTED BY DR AIMI, SPOKEN TO	1022.00	t	2025-11-24 15:03:29.145416	2025-11-24 15:03:29.145416	100MG BD	2.80
323	73	534	2025-11-24	\N	2025-10-15	f	STARTED BY DR. TAN JIN KIAT\n	2044.00	t	2025-11-24 15:03:52.597877	2025-11-24 15:03:52.597877	200MG BD	5.60
324	73	632	2025-11-24	\N	2025-11-10	f	DRIVE TRU PT\n	2923.65	t	2025-11-24 15:04:15.241515	2025-11-24 15:04:15.241515	200MG OM, 400MG ON	8.01
325	73	651	2025-11-24	\N	2025-11-12	f	start by dr aimi st dr shakir	3803.30	t	2025-11-24 15:04:55.299732	2025-11-24 15:04:55.299732	400MG BD	10.42
326	73	677	2025-11-24	\N	2025-11-10	f	\N	3803.30	t	2025-11-24 15:05:24.11544	2025-11-24 15:05:24.11544	400MG bd	10.42
327	73	708	2025-11-24	\N	2025-11-24	f	STARTED BY DR SELVA ST DR SHARON	1901.65	t	2025-11-24 15:07:16.836862	2025-11-24 15:07:16.836862	400 MG ON	5.21
328	73	722	2025-11-24	\N	2025-11-24	f	SPUB BATU ANAM S/T DR TAN JK\n	511.00	t	2025-11-24 15:07:45.339729	2025-11-24 15:07:45.339729	100MG ON	1.40
329	73	730	2025-11-24	\N	2025-11-24	f	STARTED BY DR WILLIAM HMR & spub kk chaah\n	5847.30	t	2025-11-24 15:09:52.077092	2025-11-24 15:09:52.077092	600MG BD	16.02
330	73	862	2025-11-24	\N	2025-11-24	f	RESTARTED BY DR HANIFF CASE D/W DR SHARON\n	4825.30	t	2025-11-24 15:10:44.907693	2025-11-24 15:10:44.907693	400/600MG BD	13.22
331	73	870	2025-11-24	\N	2025-11-24	f	STARTED BY DR LIYANA ZAINAL ABIDIN S/T DR SHARON\n	1533.00	t	2025-11-24 15:12:51.919173	2025-11-24 15:12:51.919173	300MG ON	4.20
332	73	881	2025-11-24	\N	2025-11-24	t	SPUB KK BANDAR TUN RAZAK\n	1533.00	t	2025-11-24 15:13:44.869469	2025-11-24 15:13:44.869469	300MG ON	4.20
333	73	944	2025-11-24	\N	2025-11-24	f	START BY DR RADHIAH. IPD SUPPLIED\n	2923.65	t	2025-11-24 15:14:40.388636	2025-11-24 15:14:40.388636	600MG ON	8.01
334	73	2006	2025-11-24	\N	2025-11-24	f	STARTED BY DR PAVALA S/W DR TAN\n	3803.30	t	2025-11-24 15:16:26.864289	2025-11-24 15:16:26.864289	400MG BD	10.42
335	73	1012	2025-11-24	\N	2025-11-24	f	started by Dr. Nurul Fitri, S/T to Dr Tan\n	511.00	t	2025-11-24 15:17:06.348333	2025-11-24 15:17:06.348333	100MG ON	1.40
336	73	1013	2025-11-24	\N	2025-11-24	f	DR SULAIMAN REFERRAL LETTER FROM HSAJB\n	1022.00	t	2025-11-24 15:21:24.587504	2025-11-24 15:21:24.587504	200MG ON	2.80
337	73	1089	2025-11-24	\N	2025-11-24	f	started by dr selva, s/t Dr Yus\n	1022.00	t	2025-11-24 15:21:46.023157	2025-11-24 15:21:46.023157	200mg on	2.80
338	73	1106	2025-11-24	\N	2025-11-24	f	STARTED DR YUSADILLAH\n	3803.30	t	2025-11-24 15:22:07.909631	2025-11-24 15:22:07.909631	400 mg BD	10.42
339	73	1282	2025-11-24	\N	2025-11-24	f	started by dr radhiah\n	511.00	t	2025-11-24 15:22:29.029251	2025-11-24 15:22:29.029251	100 mg ON	1.40
343	73	1680	2025-11-24	\N	2025-11-24	f	STARTED BY DR AIMI ST DR YUSADILAH\n	1022.00	t	2025-11-24 15:26:18.47987	2025-11-24 15:26:18.47987	200 MG ON	2.80
344	73	1705	2025-11-24	\N	2025-11-24	f	started by dr selva st dr shakir\n	5847.30	t	2025-11-24 15:26:40.390751	2025-11-24 15:26:40.390751	600MG BD	16.02
345	73	1725	2025-11-24	\N	2025-11-24	f	STARTED BY DR YUSADILAH\n	1022.00	t	2025-11-24 15:27:01.510499	2025-11-24 15:27:01.510499	200MG ON	2.80
346	73	1761	2025-11-24	\N	2025-11-24	f	START BY DR PAVALA S/W DR SYAKIR\n	4825.30	t	2025-11-24 15:27:23.093039	2025-11-24 15:27:23.093039	600mg bd	13.22
347	73	1776	2025-11-24	\N	2025-11-24	f	STARTED IN WARD 5. SPUB\n	2044.00	t	2025-11-24 15:27:44.26757	2025-11-24 15:27:44.26757	200MG BD	5.60
348	73	1831	2025-11-24	\N	2025-11-24	f	STARTED BY DR ANAS HASSAN, D/W DR WILLIAM\n	3803.30	t	2025-11-24 15:28:05.94202	2025-11-24 15:28:05.94202	400MG BD	10.42
349	73	1838	2025-11-24	\N	2025-11-24	f	START DR AIMI ST DR RADHIATUL\n	511.00	t	2025-11-24 15:28:27.151717	2025-11-24 15:28:27.151717	50MG ON	1.40
350	73	1883	2025-11-24	\N	2025-11-24	f	RK\n	2412.65	t	2025-11-24 15:28:48.818208	2025-11-24 15:28:48.818208	100 MG /400 MG	6.61
351	73	1894	2025-11-24	\N	2025-11-24	t	spub kk batu6\n	2412.65	t	2025-11-24 15:29:21.367432	2025-11-24 15:29:21.367432	100MG OM / 400MG ON	6.61
352	74	1664	2025-11-24	\N	2025-11-10	f	HMR	8358.50	t	2025-11-24 15:33:40.617575	2025-11-24 15:34:39.412762	400MG MONTHLY	22.90
353	74	873	2025-11-24	\N	2025-04-30	f	\N	8358.50	t	2025-11-24 15:35:03.104738	2025-11-24 15:35:03.104738	400MG MONTHLY	22.90
354	75	307	2025-11-24	\N	2025-11-10	f	RK	3233.90	t	2025-11-24 15:37:39.056923	2025-11-24 15:37:50.271182	15MG ON	8.86
355	75	905	2025-11-24	\N	2025-11-24	f	STARTED IN WARD BY DR TAN AND D/W DR RADHIATUL	6467.80	t	2025-11-24 15:38:11.71458	2025-11-24 15:38:11.71458	10 mg bd	17.72
357	75	1855	2025-11-24	\N	2025-11-10	f	RK	6467.80	t	2025-11-24 15:38:43.887919	2025-11-24 15:38:43.887919	10 mg bd	17.72
358	75	964	2025-11-24	\N	2025-09-05	f	STARTED BY DR YUSADILAH	6467.80	t	2025-11-24 15:39:05.835434	2025-11-24 15:39:05.835434	20MG ON	17.72
356	75	1716	2025-11-24	\N	2025-11-24	t	SPUB KK Bekok	3233.90	t	2025-11-24 15:38:24.312009	2025-11-24 15:39:16.588903	10 mg ON	8.86
359	76	1022	2025-11-24	\N	2025-10-15	f	STARTED BY DR SHARON 	155.13	t	2025-11-24 15:39:51.070969	2025-11-24 15:40:57.194799	20MG OD	0.43
360	77	1275	2025-11-24	\N	2025-12-17	f	STARTED BY DR SHARON TAN -- IN WAITING LIST ??	2949.20	f	2025-11-24 15:43:32.242081	2025-11-24 15:43:58.817364	2mg ON	8.08
361	77	1228	2025-11-24	\N	2025-07-16	f	KPK APPROVED	1474.60	t	2025-11-24 15:44:37.593168	2025-11-24 15:44:37.593168	1mg OD	4.04
362	78	200	2025-11-24	\N	2025-11-24	f	BY DR MOHD NUR SHAKIR\n\n	313.90	t	2025-11-24 15:53:30.986592	2025-11-24 15:54:28.098253	60MG ON	0.86
363	78	314	2025-11-24	\N	2025-11-24	f	90mg ON\n	667.95	t	2025-11-24 15:53:52.890402	2025-11-24 15:55:02.720788	90MG ON	1.83
364	78	2007	2025-11-24	\N	2025-11-24	f	STARTED BY DR JEVITHA. D/W DR TAN JIN KIAT\n	354.05	t	2025-11-24 15:55:58.276023	2025-11-24 15:55:58.276023	30 MG ON	0.97
365	78	2009	2025-11-24	\N	2025-11-24	f	STARTED BY DR TAN JIN KIAT\n	708.10	t	2025-11-24 15:56:19.663897	2025-11-24 15:56:19.663897	30MG BD	1.94
366	78	465	2025-11-24	\N	2025-11-24	f	DR PAVALA S/T DR TAN JK\n	627.80	t	2025-11-24 15:56:41.363459	2025-11-24 15:56:41.363459	120MG ON	1.72
367	78	657	2025-11-24	\N	2025-11-24	f	120mg ON\n	627.80	t	2025-11-24 15:57:02.652346	2025-11-24 15:57:02.652346	120MG ON	1.72
368	78	1006	2025-11-24	\N	2025-11-24	f	DR HANIFF ZIKRI S/T DR YUSADILAH\n	313.90	t	2025-11-24 15:57:24.843163	2025-11-24 15:57:24.843163	60MG ON	0.86
369	78	1125	2025-11-24	\N	2025-11-24	f	FROM 30->60MG ON 2.1.25\n	313.90	t	2025-11-24 15:57:46.012293	2025-11-24 15:57:46.012293	60MG ON	0.86
370	78	1311	2025-11-24	\N	2025-11-24	f	STARTED BY BY DR JEVITHA\n	313.90	t	2025-11-24 15:58:07.787588	2025-11-24 15:58:07.787588	60MG ON	0.86
371	78	1356	2025-11-24	\N	2025-11-24	f	STARTED BY DR SHAKIR\n	354.05	t	2025-11-24 15:58:29.161323	2025-11-24 15:58:29.161323	30 MG ON	0.97
372	78	1450	2025-11-24	\N	2025-11-24	f	STARTED BY DR AIMI S/T DR SHARON\n	354.05	t	2025-11-24 15:58:50.822493	2025-11-24 15:58:50.822493	30 MG ON	0.97
373	78	2008	2025-11-24	\N	2025-11-24	f	STARTED BY DR TAN JIN KIAT\n	354.05	t	2025-11-24 15:59:45.632062	2025-11-24 15:59:45.632062	30 MG OD	0.97
374	78	1727	2025-11-24	\N	2025-11-24	f	DR HANIFF ZIKRI S/T DR YUSADILAH\n	354.05	t	2025-11-24 16:00:07.14159	2025-11-24 16:00:07.14159	30MG ON	0.97
375	78	1755	2025-11-24	\N	2025-11-24	f	FROM 60> 30 DR SHARON TAN\n	313.90	t	2025-11-24 16:00:28.781778	2025-11-24 16:00:28.781778	60MG OD	0.86
376	78	1839	2025-11-24	\N	2025-11-24	f	DR PAVALA S/T DR SHAKIR\n	313.90	t	2025-11-24 16:00:49.841086	2025-11-24 16:00:49.841086	60MG ON	0.86
377	79	1047	2025-11-24	\N	2025-02-19	t	SPUB KK PERWIRA JAYA	4259.55	t	2025-11-24 16:04:14.789867	2025-11-24 16:04:14.789867	36MG OM	11.67
378	79	1837	2025-11-24	\N	2025-06-25	f	STARTED BY DR YUS	6989.75	t	2025-11-24 16:04:46.106404	2025-11-24 16:04:46.106404	54MG OM	19.15
379	79	841	2025-11-24	\N	2025-11-05	f	STARTED BY DR NUR FAIZZAH	2730.20	t	2025-11-24 16:05:16.025864	2025-11-24 16:05:16.025864	18MG OM 	7.48
380	79	161	2025-11-24	\N	2025-11-24	f	DR HANIFF D/W DR SHARON TAN 	2730.20	t	2025-11-24 16:05:32.106949	2025-11-24 16:05:32.106949	18mg OM	7.48
381	79	1662	2025-11-24	\N	2025-11-24	f	DR AIMI S/T DR YUS CHANGE FROM 18MG TO 36 MG BY DR HANIFF	4259.55	t	2025-11-24 16:05:44.32053	2025-11-24 16:05:44.32053	36MG OM	11.67
382	79	1241	2025-11-24	\N	2025-11-24	f	DR SELVA S/T DR YUS	2730.20	t	2025-11-24 16:05:55.671575	2025-11-24 16:05:55.671575	18MG OM	7.48
383	79	997	2025-11-24	\N	2025-11-24	f	DR HANIFF ST DR SHAKIR	2730.20	t	2025-11-24 16:06:11.549737	2025-11-24 16:06:11.549737	18MG OM	7.48
384	79	488	2025-11-24	\N	2025-11-24	f	DR SHARON	2730.20	t	2025-11-24 16:06:33.178907	2025-11-24 16:06:33.178907	18MG OM	7.48
385	81	669	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:08:40.332511	2025-11-24 16:08:40.332511	100mg	30.60
386	81	1389	2025-11-24	\N	2025-11-07	f	\N	11169.00	t	2025-11-24 16:09:26.620813	2025-11-24 16:09:26.620813	150mg	30.60
387	81	1694	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:10:38.782139	2025-11-24 16:10:38.782139	100mg	30.60
388	81	1747	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:10:45.658147	2025-11-24 16:10:45.658147	150mg	30.60
389	81	1918	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:10:52.950795	2025-11-24 16:10:52.950795	100mg	30.60
390	81	1031	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:11:00.080952	2025-11-24 16:11:00.080952	100mg	30.60
391	81	1438	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:11:06.669724	2025-11-24 16:11:06.669724	150mg	30.60
392	81	1116	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:11:13.473731	2025-11-24 16:11:13.473731	100mg	30.60
393	81	1308	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:11:20.623746	2025-11-24 16:11:20.623746	150mg	30.60
394	81	1377	2025-11-24	\N	2025-11-24	f	\N	11169.00	t	2025-11-24 16:11:32.572924	2025-11-24 16:11:32.572924	150mg	30.60
395	82	746	2025-11-24	\N	2025-11-24	f	\N	4934.80	t	2025-11-24 16:20:58.289679	2025-11-24 16:20:58.289679	6MG ON	13.52
396	82	1377	2025-11-24	\N	2025-11-24	f	\N	4934.80	t	2025-11-24 16:21:53.938927	2025-11-24 16:21:53.938927	6MG ON	13.52
397	82	317	2025-11-24	\N	2025-11-24	f	\N	4934.80	t	2025-11-24 16:22:17.076012	2025-11-24 16:22:17.076012	3MG ON	13.52
398	82	1116	2025-11-24	\N	2025-11-24	f	\N	4934.80	t	2025-11-24 16:22:29.277313	2025-11-24 16:22:29.277313	6MG ON	13.52
399	82	111	2025-11-24	\N	2025-11-24	f	\N	5923.95	t	2025-11-24 16:22:42.356201	2025-11-24 16:22:42.356201	9MG ON	16.23
400	82	1169	2025-11-24	\N	2025-11-24	f	REDUCED DOSE FROM 6MG OD ON 2.5.17 (DRIVE THROUGH)	4934.80	t	2025-11-24 16:23:29.96952	2025-11-24 16:23:29.96952	3MG ON	13.52
401	82	828	2025-11-24	\N	2025-11-24	f	\N	4934.80	t	2025-11-24 16:23:40.397369	2025-11-24 16:23:40.397369	3MG OD	13.52
402	82	1254	2025-11-24	\N	2025-11-24	f	START BY DR TAN JIN KIAT,W5, increased to 12mg ON by Dr. jevitha	9869.60	t	2025-11-24 16:24:33.109232	2025-11-24 16:24:33.109232	12MG ON	27.04
403	82	677	2025-11-24	\N	2025-11-24	f	\N	9869.60	t	2025-11-24 16:25:07.226224	2025-11-24 16:25:07.226224	12mg ON	27.04
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, name, ic_number, created_at, updated_at) FROM stdin;
24	A SAHAK BIN RAHMAT	590503016227	2025-09-10 10:26:00	2025-09-10 10:26:00
25	A.RAHMAN BIN M.DIMAN	460728015529	2025-09-10 10:26:00	2025-09-10 10:26:00
26	AARA DAHLIA BINTI MUHAMMAD AL-MUQSIT	240811011014	2025-09-10 10:26:00	2025-09-10 10:26:00
27	AARIZ AYDAN BIN MOHD AZALI	220720011061	2025-09-10 10:26:00	2025-09-10 10:26:00
28	AARON LIM KHAI ZHE	031020020175	2025-09-10 10:26:00	2025-09-10 10:26:00
29	AB AHMID BIN ZAKARIA	570609016729	2025-09-10 10:26:00	2025-09-10 10:26:00
30	AB LATIP BIN MAMAT 	610425065431	2025-09-10 10:26:00	2025-09-10 10:26:00
31	AB MANAF BIN BUJANG	361208015409	2025-09-10 10:26:00	2025-09-10 10:26:00
32	AB MUTALIB BIN AB SAMAD	480501015549	2025-09-10 10:26:00	2025-09-10 10:26:00
33	ABAS BIN AWANG	470218015245	2025-09-10 10:26:00	2025-09-10 10:26:00
34	ABD ARIF B ABD KARIM	470611085047	2025-09-10 10:26:00	2025-09-10 10:26:00
35	ABD AZIZ BIN RANI 	800228015803	2025-09-10 10:26:00	2025-09-10 10:26:00
36	ABD AZIZ PAIMEN	620618016475	2025-09-10 10:26:00	2025-09-10 10:26:00
37	ABD GHANI BIN KASNAWI	531026015829	2025-09-10 10:26:00	2025-09-10 10:26:00
38	ABD GHANI BIN MOHD ELAH 	600101015455	2025-09-10 10:26:00	2025-09-10 10:26:00
39	ABD JALIL BIN SAMSUDIN	680706016007	2025-09-10 10:26:00	2025-09-10 10:26:00
40	ABD LATIF BIN SAAT 	640314016095	2025-09-10 10:26:00	2025-09-10 10:26:00
41	ABD LATIF BIN SABTU	570419017181	2025-09-10 10:26:00	2025-09-10 10:26:00
42	ABD MALEK BIN SANAT	640102015859	2025-09-10 10:26:00	2025-09-10 10:26:00
43	ABD RAHMAN NASIR 	430313115133	2025-09-10 10:26:00	2025-09-10 10:26:00
44	ABD RAZAK BIN ABD MANA	641207015745	2025-09-10 10:26:00	2025-09-10 10:26:00
45	ABD RAZAK BIN MOHD DOM	620421015591	2025-09-10 10:26:00	2025-09-10 10:26:00
46	ABD RAZAK BIN RAMLI	560817016177	2025-09-10 10:26:00	2025-09-10 10:26:00
47	ABD RAZAK BIN USSOF	640522025869	2025-09-10 10:26:00	2025-09-10 10:26:00
48	ABD WAHAB BIN MD ASON	480906015125	2025-09-10 10:26:00	2025-09-10 10:26:00
49	ABD.RAZAK BIN ABD HAMID	530504015483	2025-09-10 10:26:00	2025-09-10 10:26:00
50	ABDUL ALIP BIN MOHD HAJI	411202105481	2025-09-10 10:26:00	2025-09-10 10:26:00
51	ABDUL GHANI BIN RAHMAT	540221015845	2025-09-10 10:26:00	2025-09-10 10:26:00
52	ABDUL HAMID B SHAARI	440927085329	2025-09-10 10:26:00	2025-09-10 10:26:00
53	ABDUL HAMID BIN DAHLAN	511220015031	2025-09-10 10:26:00	2025-09-10 10:26:00
54	ABDUL HAMID BIN KASIM	880809236033	2025-09-10 10:26:00	2025-09-10 10:26:00
55	ABDUL HARIS	701107016179	2025-09-10 10:26:00	2025-09-10 10:26:00
56	ABDUL JALIL B MD SALLEH	580629015693	2025-09-10 10:26:00	2025-09-10 10:26:00
57	ABDUL KAHAR BIN SATIH	660410715951	2025-09-10 10:26:00	2025-09-10 10:26:00
58	ABDUL KARIM BIN MD TAHIR 	480125055327	2025-09-10 10:26:00	2025-09-10 10:26:00
59	ABDUL LATIFF BIN ABDUL KADIR	550903016043	2025-09-10 10:26:00	2025-09-10 10:26:00
60	ABDUL MAJID BIN MD YUSOF	541107015547	2025-09-10 10:26:00	2025-09-10 10:26:00
61	ABDUL MALEK BIN PA ACHOK	660826015115	2025-09-10 10:26:00	2025-09-10 10:26:00
62	ABDUL QUYYUM BIN ISMAIL	940310025765	2025-09-10 10:26:00	2025-09-10 10:26:00
63	ABDUL RAHMAN BIN LAN	501112015625	2025-09-10 10:26:00	2025-09-10 10:26:00
64	ABDUL RAHMAN BIN MANSOR	521115105819	2025-09-10 10:26:00	2025-09-10 10:26:00
65	ABDUL RAHMAN BIN MUSA	470115115243	2025-09-10 10:26:00	2025-09-10 10:26:00
66	ABDUL RANI	550401106583	2025-09-10 10:26:00	2025-09-10 10:26:00
67	ABDUL SAHAK BIN MOHD JALI	600124016071	2025-09-10 10:26:00	2025-09-10 10:26:00
68	ABDUL SAMAD DELU	590105016117	2025-09-10 10:26:00	2025-09-10 10:26:00
69	ABDUL WAHAB BIN ABDUL GHANI	570920016377	2025-09-10 10:26:00	2025-09-10 10:26:00
70	ABDUL WAHAB BIN ISMAIL	500802085511	2025-09-10 10:26:00	2025-09-10 10:26:00
71	ABDUL WAHAB BIN MD ZAIN	491220016151	2025-09-10 10:26:00	2025-09-10 10:26:00
72	ABDUL WAHAB OTHMAN 	450809015265	2025-09-10 10:26:00	2025-09-10 10:26:00
73	ABDULLAH APIT	500414055169	2025-09-10 10:26:00	2025-09-10 10:26:00
74	ABDULLAH BIN ABDUL MAJID 	440326015333	2025-09-10 10:26:00	2025-09-10 10:26:00
75	ABDULLAH BIN ADAM	390918015297	2025-09-10 10:26:00	2025-09-10 10:26:00
76	ABDULLAH BIN CHANDI (15MG)	410620015687	2025-09-10 10:26:00	2025-09-10 10:26:00
77	ABDULLAH BIN MOHD DON@ADON	520107015085	2025-09-10 10:26:00	2025-09-10 10:26:00
78	ABDULLAH BIN MUKTI	541011015665	2025-09-10 10:26:00	2025-09-10 10:26:00
79	ABDULLAH BIN OTHMAN	391226015143	2025-09-10 10:26:00	2025-09-10 10:26:00
80	ABDULLAH SHAARI	581020025765	2025-09-10 10:26:00	2025-09-10 10:26:00
82	ABU BAKAR B KAMAT	650801015881	2025-09-10 10:26:00	2025-09-10 10:26:00
83	ABU BAKAR BIN AHMAD 	660526015383	2025-09-10 10:26:00	2025-09-10 10:26:00
84	ABU BAKAR BIN AMAN	331020015119	2025-09-10 10:26:00	2025-09-10 10:26:00
85	ABU BAKAR BIN IBRAHIM 	520130015219	2025-09-10 10:26:00	2025-09-10 10:26:00
86	ABU BAKAR BIN SURADIN	630619015457	2025-09-10 10:26:00	2025-09-10 10:26:00
87	ABU BAKAR BIN WAHAB	521210055581	2025-09-10 10:26:00	2025-09-10 10:26:00
88	ADAM BAKAR BASAR	680505105265	2025-09-10 10:26:00	2025-09-10 10:26:00
89	ADAM BIN MOHAMAD	551117015697	2025-09-10 10:26:00	2025-09-10 10:26:00
90	ADEEB KHALISH BIN MOHD NASRULLAH 	210201010287	2025-09-10 10:26:00	2025-09-10 10:26:00
91	ADIL SHAHRUL	800711015475	2025-09-10 10:26:00	2025-09-10 10:26:00
92	ADNAN BIN MURAH	491011015443	2025-09-10 10:26:00	2025-09-10 10:26:00
93	ADNAN BIN PARIJO 	530726015809	2025-09-10 10:26:00	2025-09-10 10:26:00
94	AFIF NORAZAM BIN MOHD SALLEH	771105016697	2025-09-10 10:26:00	2025-09-10 10:26:00
95	AFIQ HAFIZUDDIN	210224011493	2025-09-10 10:26:00	2025-09-10 10:26:00
96	AGIL BIN JA'AIN	420616015261	2025-09-10 10:26:00	2025-09-10 10:26:00
97	AHALYA SREE	041002011442	2025-09-10 10:26:00	2025-09-10 10:26:00
98	AHMAD ABDULLAH MOHD DIAH	700618016141	2025-09-10 10:26:00	2025-09-10 10:26:00
99	AHMAD AZHARI BIN BAHARUDDIN	830619025459	2025-09-10 10:26:00	2025-09-10 10:26:00
100	AHMAD BAHTIAR BIN ABDULLAH 	650512016845	2025-09-10 10:26:00	2025-09-10 10:26:00
101	AHMAD BIN KAMIS	580217025641	2025-09-10 10:26:00	2025-09-10 10:26:00
102	AHMAD BIN KASIMON	561101016555	2025-09-10 10:26:00	2025-09-10 10:26:00
103	AHMAD BIN RAMLI	500912086179	2025-09-10 10:26:00	2025-09-10 10:26:00
104	AHMAD BIN TALIF	690616015069	2025-09-10 10:26:00	2025-09-10 10:26:00
105	AHMAD BUANG BIN MOHAMAD	510201015859	2025-09-10 10:26:00	2025-09-10 10:26:00
106	AHMAD FUAD BIN ZAKARI 	870319235899	2025-09-10 10:26:00	2025-09-10 10:26:00
107	AHMAD KAMAL BIN MORMAN	681229015689	2025-09-10 10:26:00	2025-09-10 10:26:00
108	AHMAD KHAIRUL ISKANDAR BIN ABD JALIL 	930904065757	2025-09-10 10:26:00	2025-09-10 10:26:00
109	AHMAD KHALIL BIN ISMAIL	600702065423	2025-09-10 10:26:00	2025-09-10 10:26:00
110	AHMAD LOKMAN BIN A.ZAIDI 	960203015885	2025-09-10 10:26:00	2025-09-10 10:26:00
111	AHMAD NAZRI BIN YAHAYA	840524105439	2025-09-10 10:26:00	2025-09-10 10:26:00
112	AHMAD RAMADHAN 	210503011197	2025-09-10 10:26:00	2025-09-10 10:26:00
113	AHMAD SALEHAN BIN  HISBULLAH	800122015901	2025-09-10 10:26:00	2025-09-10 10:26:00
114	AHMAD YUSOF    	570325076025	2025-09-10 10:26:00	2025-09-10 10:26:00
115	AHMADI B AMAT KARIM	530825715237	2025-09-10 10:26:00	2025-09-10 10:26:00
81	ABU BIN ISMAIL	590121015683	2025-09-10 10:26:00	2025-10-27 10:05:34.452984
21	NUR NADIAH BINTI ZAINAL ABIDIN	940627015266	2025-09-18 14:49:54.158522	2025-10-27 10:06:03.56372
116	AHMAT BIN MAJID	470707015019	2025-09-10 10:26:00	2025-09-10 10:26:00
117	AHNAF RAZIN	170521010821	2025-09-10 10:26:00	2025-09-10 10:26:00
118	AIDA BINTI BARKAWI	880403565072	2025-09-10 10:26:00	2025-09-10 10:26:00
119	AIDIL MUZAFFAR BIN AMIRUL AKMAL	231005012333	2025-09-10 10:26:00	2025-09-10 10:26:00
120	AIEDA SYAKINNA BINTI NORLIZAM 	951027015346	2025-09-10 10:26:00	2025-09-10 10:26:00
121	AINATULMARDHIYAH BINTI IZHAR 	970821045132	2025-09-10 10:26:00	2025-09-10 10:26:00
122	AINI NADHIRAH BINTI AHMAD ROSDI	040609010222	2025-09-10 10:26:00	2025-09-10 10:26:00
123	AINUL KAMILA	011115100938	2025-09-10 10:26:00	2025-09-10 10:26:00
124	ALEEYA NUR IMAN MOHD RAZIF	180114010348	2025-09-10 10:26:00	2025-09-10 10:26:00
125	ALENA ANASTASHA	130129060078	2025-09-10 10:26:00	2025-09-10 10:26:00
126	ALI BIN AHMAD 	590510016225	2025-09-10 10:26:00	2025-09-10 10:26:00
127	ALI BIN MOHD YUSUF	460908015657	2025-09-10 10:26:00	2025-09-10 10:26:00
128	ALIA QISTINA A/P MOHD HARIZAL	170911060672	2025-09-10 10:26:00	2025-09-10 10:26:00
129	ALIZA BT MOHD ALI	700224055236	2025-09-10 10:26:00	2025-09-10 10:26:00
130	ALLIF BIN AHMAD	921125015297	2025-09-10 10:26:00	2025-09-10 10:26:00
131	ALOHA BINTI ITHNIN	601222015114	2025-09-10 10:26:00	2025-09-10 10:26:00
132	ALYA NURHIDAYAH BT MOHD AZRI	110221010630	2025-09-10 10:26:00	2025-09-10 10:26:00
133	AMBUAR BIN ANOR	560409105963	2025-09-10 10:26:00	2025-09-10 10:26:00
134	AMIN NOR JALIL BIN JAMI'EN 	711105015913	2025-09-10 10:26:00	2025-09-10 10:26:00
135	AMINAH ABIDIN 	500507015764	2025-09-10 10:26:00	2025-09-10 10:26:00
136	AMINAH ARISAN	550302015838	2025-09-10 10:26:00	2025-09-10 10:26:00
137	AMINAH BINTI BABA	500821015682	2025-09-10 10:26:00	2025-09-10 10:26:00
138	AMINAH BINTI KOJING	381130015238	2025-09-10 10:26:00	2025-09-10 10:26:00
139	AMINAH BINTI PAZALI KHAN (15MG)	480812015810	2025-09-10 10:26:00	2025-09-10 10:26:00
140	AMINAH BINTI RAZAK	810731085146	2025-09-10 10:26:00	2025-09-10 10:26:00
141	AMINUDDIN BIN YUSUF	650421015601	2025-09-10 10:26:00	2025-09-10 10:26:00
142	AMIR BT OMAR	530304015550	2025-09-10 10:26:00	2025-09-10 10:26:00
143	AMIRA BINTI MOHAMAD	930615015366	2025-09-10 10:26:00	2025-09-10 10:26:00
144	AMIRUDDIN B HASHIM 	441122105155	2025-09-10 10:26:00	2025-09-10 10:26:00
145	AMIRUDDIN BIN RAMLI	831214105711	2025-09-10 10:26:00	2025-09-10 10:26:00
146	AMMAVASSI	480613015041	2025-09-10 10:26:00	2025-09-10 10:26:00
147	AMRAN KUCHIT 	620928016091	2025-09-10 10:26:00	2025-09-10 10:26:00
148	ANAS DANIYAL BIN SALEHUDDIN	220923040233	2025-09-10 10:26:00	2025-09-10 10:26:00
149	ANIDA BINTI ABD RAHIM	670102017114	2025-09-10 10:26:00	2025-09-10 10:26:00
150	ANINDARAJA A/L SINNAGOLANGAI	670906016061	2025-09-10 10:26:00	2025-09-10 10:26:00
151	ANISMARNI BINTI AFRIDUL	900225016358	2025-09-10 10:26:00	2025-09-10 10:26:00
152	ANITA AZURA BINTI IDRIS	840721065608	2025-09-10 10:26:00	2025-09-10 10:26:00
153	ANITA BINTI RABIKAT	740507016428	2025-09-10 10:26:00	2025-09-10 10:26:00
154	ANITA MUSTAFFA	610905016110	2025-09-10 10:26:00	2025-09-10 10:26:00
155	ANIZA BINTI MOKLAS	820413015504	2025-09-10 10:26:00	2025-09-10 10:26:00
156	ANJALAI A/P PNNIAH	690309015886	2025-09-10 10:26:00	2025-09-10 10:26:00
157	ANUAR BIN BUSARI (15MG)	550611015663	2025-09-10 10:26:00	2025-09-10 10:26:00
158	ANUAR BIN ISMAIL	650515015661	2025-09-10 10:26:00	2025-09-10 10:26:00
159	ANUAR BIN MOHAMED 	460812015783	2025-09-10 10:26:00	2025-09-10 10:26:00
160	AQIL DARWISH BIN AZRIN	040217011365	2025-09-10 10:26:00	2025-09-10 10:26:00
161	AQIL NAUFAL BIN AHMAD AZAM 	130811101813	2025-09-10 10:26:00	2025-09-10 10:26:00
162	ARBAIN BIN ABDULLAH	670820086165	2025-09-10 10:26:00	2025-09-10 10:26:00
163	ARCHANA A/P SIVAKUMAR	030531011196	2025-09-10 10:26:00	2025-09-10 10:26:00
164	ARIF BIN ANUAR	600406015915	2025-09-10 10:26:00	2025-09-10 10:26:00
165	ARIFIN BIN ABDULLAH	540122085055	2025-09-10 10:26:00	2025-09-10 10:26:00
166	ARIS BIN TAHIR	620925015763	2025-09-10 10:26:00	2025-09-10 10:26:00
167	ARPAN BIN DIRON 	560404016523	2025-09-10 10:26:00	2025-09-10 10:26:00
168	ARSHAD BIN YUNUS 	650606015851	2025-09-10 10:26:00	2025-09-10 10:26:00
169	ARUMUGAM A/L SHAMUGAM	650126015385	2025-09-10 10:26:00	2025-09-10 10:26:00
170	ARUMUGAM A/L SUPPIAH	610516015085	2025-09-10 10:26:00	2025-09-10 10:26:00
171	AS'ARI BIN SHAMSUDDIN 	590308115203	2025-09-10 10:26:00	2025-09-10 10:26:00
172	ASHRUL AZIM BIN MD TAP	070523070587	2025-09-10 10:26:00	2025-09-10 10:26:00
173	ASHWINEE A/P SIVANANDAN 	960614065190	2025-09-10 10:26:00	2025-09-10 10:26:00
174	ASIAH BT MARSIDI	530619016056	2025-09-10 10:26:00	2025-09-10 10:26:00
175	ASMAH BT ABD HAMID	550620715290	2025-09-10 10:26:00	2025-09-10 10:26:00
176	ASMAH BT HJ OTHMAN	550803015350	2025-09-10 10:26:00	2025-09-10 10:26:00
177	ASMAH BT SAMAH 	531224015694	2025-09-10 10:26:00	2025-09-10 10:26:00
178	ASMAHAN BT ABD HALIM	710828095086	2025-09-10 10:26:00	2025-09-10 10:26:00
179	ASNAH BINTI HAJI HASSAN       	530131045136	2025-09-10 10:26:00	2025-09-10 10:26:00
180	ASYRANI BIN ZAINAL	811022105133	2025-09-10 10:26:00	2025-09-10 10:26:00
181	ATA BIN AJIS	520724065109	2025-09-10 10:26:00	2025-09-10 10:26:00
182	AW PEI JUN	000920101278	2025-09-10 10:26:00	2025-09-10 10:26:00
183	AWAL @ AWA BINTI OTHMAN	540608015962	2025-09-10 10:26:00	2025-09-10 10:26:00
184	AWAL LUDIN MOHD SOM 	610723106991	2025-09-10 10:26:00	2025-09-10 10:26:00
185	AWANG BIN ATAN	610727015077	2025-09-10 10:26:00	2025-09-10 10:26:00
186	AYDAN NAEL BIN MUHAMMAD AFHAM	240407010845	2025-09-10 10:26:00	2025-09-10 10:26:00
187	AYRA NATASHA BT MUHAMMAD AFHAM	211029010190	2025-09-10 10:26:00	2025-09-10 10:26:00
188	AYUSSRIAWATI BINTI RAMLI	880310055428	2025-09-10 10:26:00	2025-09-10 10:26:00
189	AYYTTAN CHAMBRAN JAYALAKSHMI	411207715000	2025-09-10 10:26:00	2025-09-10 10:26:00
190	AZAMRI BIN 	651225015107	2025-09-10 10:26:00	2025-09-10 10:26:00
191	AZILA BINTI JASMAN	900319015962	2025-09-10 10:26:00	2025-09-10 10:26:00
192	AZIZAH BINTI AHMAD	591018015428	2025-09-10 10:26:00	2025-09-10 10:26:00
193	AZIZAH BINTI DAUD 	540314106076	2025-09-10 10:26:00	2025-09-10 10:26:00
194	AZIZAH BINTI JIRON	720817015350	2025-09-10 10:26:00	2025-09-10 10:26:00
195	AZIZAH BINTI SULOMG	730729016344	2025-09-10 10:26:00	2025-09-10 10:26:00
196	AZIZAH BT IBRAHIM	610928015444	2025-09-10 10:26:00	2025-09-10 10:26:00
197	AZIZAH BT ROSNAN 	690406015730	2025-09-10 10:26:00	2025-09-10 10:26:00
198	AZIZAH MOHD ZAIN	580202106422	2025-09-10 10:26:00	2025-09-10 10:26:00
199	AZLEN BIN ISMAIL	730726016285	2025-09-10 10:26:00	2025-09-10 10:26:00
200	AZLEYA BINTI MD SANI 	870124015554	2025-09-10 10:26:00	2025-09-10 10:26:00
201	AZLINA ABD GHANI 	710425115118	2025-09-10 10:26:00	2025-09-10 10:26:00
202	AZMAN BIN ABD JAMAL	810930015589	2025-09-10 10:26:00	2025-09-10 10:26:00
203	AZMAN BIN AHMAD	880510235343	2025-09-10 10:26:00	2025-09-10 10:26:00
204	AZMI BIN JAMIAN	750627016413	2025-09-10 10:26:00	2025-09-10 10:26:00
205	AZMI BIN KHAMIS 	820916016197	2025-09-10 10:26:00	2025-09-10 10:26:00
206	AZMIL BIN ISMAIL  	870710055567	2025-09-10 10:26:00	2025-09-10 10:26:00
207	AZRAHANNAH	100127010598	2025-09-10 10:26:00	2025-09-10 10:26:00
208	AZRI BIN MANAP	770220016049	2025-09-10 10:26:00	2025-09-10 10:26:00
209	AZUA BT ALI	660911015478	2025-09-10 10:26:00	2025-09-10 10:26:00
210	B/O  ONG MEI ZHEN	001128010908I1	2025-09-10 10:26:00	2025-09-10 10:26:00
211	B/O AZURA BINTI JOHAN	971203016064i2	2025-09-10 10:26:00	2025-09-10 10:26:00
212	B/O ELLY LIANA	C7744263I2	2025-09-10 10:26:00	2025-09-10 10:26:00
213	B/O ERNIE SOFIA IZZANIE	000507010444I1	2025-09-10 10:26:00	2025-09-10 10:26:00
214	B/O JASTINA AIDA BINTI ABDUL AZIZ 	811112105296I2	2025-09-10 10:26:00	2025-09-10 10:26:00
215	B/O KHARIYATUN BINTI SUKIMI	860304435864I4	2025-09-10 10:26:00	2025-09-10 10:26:00
216	B/O LILIN HARIANI	950522015954I2	2025-09-10 10:26:00	2025-09-10 10:26:00
217	B/O NOOR FATIHAH BINTI SHAHRUM	980514065028I2	2025-09-10 10:26:00	2025-09-10 10:26:00
218	B/O NOR SAZLIN BT ZAINOL MAJID 	A880120065430	2025-09-10 10:26:00	2025-09-10 10:26:00
219	B/O NORAMIRAH (FIRST TWIN)	940118015030I2	2025-09-10 10:26:00	2025-09-10 10:26:00
220	B/O NORAMIRAH (SECOND TWIN)	940118015030I3	2025-09-10 10:26:00	2025-09-10 10:26:00
221	B/O NORLELA A/P KAMAL	960419065662I2	2025-09-10 10:26:00	2025-09-10 10:26:00
222	B/O NUR AISYAH IZZATI BINTI KAMAR	000925011992I1	2025-09-10 10:26:00	2025-09-10 10:26:00
223	B/O NUR FATIHAH BINTI JASAHRADI	020502140846I3	2025-09-10 10:26:00	2025-09-10 10:26:00
224	B/O NUR HASNAH BINTI NOFIAN HADI	970802015616	2025-09-10 10:26:00	2025-09-10 10:26:00
225	B/O NUR HASNIZA BINTI HASHIM	C900915015838	2025-09-10 10:26:00	2025-09-10 10:26:00
226	B/O NUR HIJRAH BINTI JALAUDDIN 	890511045196I3	2025-09-10 10:26:00	2025-09-10 10:26:00
227	B/O NUR IZAYATUL SUHADA BINTI ZALIMIN	950406145154I2	2025-09-10 10:26:00	2025-09-10 10:26:00
228	B/O NUR SYAHIRA	981217016822i1	2025-09-10 10:26:00	2025-09-10 10:26:00
229	B/O NUR ZAKIAH BINTI HAMDAN	A911108016520	2025-09-10 10:26:00	2025-09-10 10:26:00
230	B/O NURAINATUL ASMINDA BINTI SAHARUDIN	910807065722I3	2025-09-10 10:26:00	2025-09-10 10:26:00
231	B/O NURIDATULAKMAR BINTI MOHAMAD	930320015342I6	2025-09-10 10:26:00	2025-09-10 10:26:00
232	B/O NURIN AIDAYANIE	050714101344I1	2025-09-10 10:26:00	2025-09-10 10:26:00
233	B/O NUR'IZZATI BINTI SENGUDI	011106010404I1	2025-09-10 10:26:00	2025-09-10 10:26:00
234	B/O NURUL AIDA EYANIS BINTI ROSLAN	E861211025924	2025-09-10 10:26:00	2025-09-10 10:26:00
235	B/O NURUL AIZA BINTI ISHAK 	C850627065782 	2025-09-10 10:26:00	2025-09-10 10:26:00
236	B/O NURUL FATIN 	910730065183I3	2025-09-10 10:26:00	2025-09-10 10:26:00
237	B/O NURUL LIYANA FAQIHAH	981023016218I1	2025-09-10 10:26:00	2025-09-10 10:26:00
238	B/O PUVANESVARI	990521017920i2	2025-09-10 10:26:00	2025-09-10 10:26:00
239	B/O ROSHAIDA BINTI JABBAR	870817015944i2	2025-09-10 10:26:00	2025-09-10 10:26:00
240	B/O SHAZLIN BT SUHAIMI	961123015054I2	2025-09-10 10:26:00	2025-09-10 10:26:00
241	B/O SITI KHATIJAH NUR MD ISA	040810011858I1	2025-09-10 10:26:00	2025-09-10 10:26:00
242	B/O SITI NAZIRA BINTI MUSTAFFA 	871111235608I2	2025-09-10 10:26:00	2025-09-10 10:26:00
243	B/O SITI RAUDHAH BINTI ABDULLAH	941203065416I2	2025-09-10 10:26:00	2025-09-10 10:26:00
244	B/O VEMALA A/P VAJAN	870611235036I2	2025-09-10 10:26:00	2025-09-10 10:26:00
245	B/O WAN SALADIWIYANA	B830120065734	2025-09-10 10:26:00	2025-09-10 10:26:00
246	BADARIAH BINTI YOUSOF	540628015572	2025-09-10 10:26:00	2025-09-10 10:26:00
247	BADRULHISAM BIN BADARUDIN	620310065609	2025-09-10 10:26:00	2025-09-10 10:26:00
248	BAHROM BIN TAMEN	561114015949	2025-09-10 10:26:00	2025-09-10 10:26:00
249	BAJRI BIN SULAIMAN	530820065319	2025-09-10 10:26:00	2025-09-10 10:26:00
250	BALAKRISHNAN	590607015827	2025-09-10 10:26:00	2025-09-10 10:26:00
251	BALAN A/L SUPRAMANIAM	521109015745	2025-09-10 10:26:00	2025-09-10 10:26:00
253	BARKAWI MAT RANI	490807015401	2025-09-10 10:26:00	2025-09-10 10:26:00
254	BASRI BIN DIN KAMAR	790605085633	2025-09-10 10:26:00	2025-09-10 10:26:00
255	BEDAH BINTI BATONG 	580501016072	2025-09-10 10:26:00	2025-09-10 10:26:00
256	BIBI BT MUKIN KUTTY	500619105430	2025-09-10 10:26:00	2025-09-10 10:26:00
257	BIDIN BIN RENGAH	611223015633	2025-09-10 10:26:00	2025-09-10 10:26:00
258	BO NORLIANA BT MOHAMAD PERLIS	930203055468I6	2025-09-10 10:26:00	2025-09-10 10:26:00
259	BO ZABEDAH 	870507016300I4	2025-09-10 10:26:00	2025-09-10 10:26:00
260	BORHAN BIN IBRAHIM 	491120015397	2025-09-10 10:26:00	2025-09-10 10:26:00
261	BUJANG BIN NORANI	580906715373	2025-09-10 10:26:00	2025-09-10 10:26:00
262	CECILYMARY A/P SOOSAI	690625015490	2025-09-10 10:26:00	2025-09-10 10:26:00
263	CHAI CHING CHUAN@KU CHIANG CHUA	410924015037	2025-09-10 10:26:00	2025-09-10 10:26:00
264	CHAI JI	430107015043	2025-09-10 10:26:00	2025-09-10 10:26:00
265	CHAN BIN KIAN	590307016035	2025-09-10 10:26:00	2025-09-10 10:26:00
266	CHAN NYUK KHENG	610228055488	2025-09-10 10:26:00	2025-09-10 10:26:00
267	CHAN OI KUAN	400515015256	2025-09-10 10:26:00	2025-09-10 10:26:00
268	CHAN SHU SHIN	830725015932	2025-09-10 10:26:00	2025-09-10 10:26:00
269	CHAN SZEE WEE	870623015030	2025-09-10 10:26:00	2025-09-10 10:26:00
270	CHANDRALEHKAH	900907146168	2025-09-10 10:26:00	2025-09-10 10:26:00
271	CHANDRAN A/L RAMANNA	770907015931	2025-09-10 10:26:00	2025-09-10 10:26:00
272	CHANDRASEGARAN A/L MANICAN	750515016451	2025-09-10 10:26:00	2025-09-10 10:26:00
273	CHANDRASEKARAN A/L VEDAN	660530055433	2025-09-10 10:26:00	2025-09-10 10:26:00
274	CHANG CHEE TYUG	630426015362	2025-09-10 10:26:00	2025-09-10 10:26:00
275	CHANG TIAN HO	670520016229	2025-09-10 10:26:00	2025-09-10 10:26:00
276	CHAU TAH SOOU	521003015237	2025-09-10 10:26:00	2025-09-10 10:26:00
277	CHE SARIAH BINTI JUNOH 	570904035746	2025-09-10 10:26:00	2025-09-10 10:26:00
278	CHE SUM BT BAHARI	460406025214	2025-09-10 10:26:00	2025-09-10 10:26:00
279	CHE ZAIN BIN ABU OSMAN	610721025717	2025-09-10 10:26:00	2025-09-10 10:26:00
280	CHEA GUI JIN	020603140538	2025-09-10 10:26:00	2025-09-10 10:26:00
281	CHEAH CHEE KWANG	691222015351	2025-09-10 10:26:00	2025-09-10 10:26:00
282	CHEE KEE HONG	471206015349	2025-09-10 10:26:00	2025-09-10 10:26:00
283	CHEE KIM CHAI	561125016015	2025-09-10 10:26:00	2025-09-10 10:26:00
284	CHEK MAT BIN PUTEH	570403045639	2025-09-10 10:26:00	2025-09-10 10:26:00
285	CHEMANGIN BIN MOHAMED	601204015647	2025-09-10 10:26:00	2025-09-10 10:26:00
286	CHEN SWEE ONN	570728065347	2025-09-10 10:26:00	2025-09-10 10:26:00
287	CHENG NYOK LIN 	731117055064	2025-09-10 10:26:00	2025-09-10 10:26:00
288	CHEU GI CHAI 	511111015921	2025-09-10 10:26:00	2025-09-10 10:26:00
289	CHEW AH LEK	521218015189	2025-09-10 10:26:00	2025-09-10 10:26:00
290	CHEW BONG SENG	310526015041	2025-09-10 10:26:00	2025-09-10 10:26:00
291	CHEW CHENG KEONG	690306015119	2025-09-10 10:26:00	2025-09-10 10:26:00
292	CHEW HOOK LIONG 	551111015813	2025-09-10 10:26:00	2025-09-10 10:26:00
293	CHEW JEKI	500606015145	2025-09-10 10:26:00	2025-09-10 10:26:00
294	CHEW JIT PAO	030618011383	2025-09-10 10:26:00	2025-09-10 10:26:00
295	CHEW SIEW CHENG	550622015538	2025-09-10 10:26:00	2025-09-10 10:26:00
296	CHI SIAW WAH	681107016392	2025-09-10 10:26:00	2025-09-10 10:26:00
297	CHIA CHIEW KHIM	371117015429	2025-09-10 10:26:00	2025-09-10 10:26:00
298	CHIEW CHUNG FUANG	371205045011	2025-09-10 10:26:00	2025-09-10 10:26:00
299	CHIN KONG CHAI	520424105201	2025-09-10 10:26:00	2025-09-10 10:26:00
300	CHIN TECK LAN	580921135156	2025-09-10 10:26:00	2025-09-10 10:26:00
301	CHING MEI FEUNG	050415011592	2025-09-10 10:26:00	2025-09-10 10:26:00
302	CHINNA KAVENDAR	520625015157	2025-09-10 10:26:00	2025-09-10 10:26:00
303	CHONG KOK FAH	631206015605	2025-09-10 10:26:00	2025-09-10 10:26:00
304	CHONG LOI @CHOONG FOOK LOI	460629035313	2025-09-10 10:26:00	2025-09-10 10:26:00
305	CHONG PAK YONG	620602015291	2025-09-10 10:26:00	2025-09-10 10:26:00
306	CHONG TSA CHAN	370116015027	2025-09-10 10:26:00	2025-09-10 10:26:00
307	CHOONG CHAN KIM	741012086015	2025-09-10 10:26:00	2025-09-10 10:26:00
308	CHOW SIEW MEI	560627015106	2025-09-10 10:26:00	2025-09-10 10:26:00
309	CHRISTOPHER ABRAHAM	500723085345	2025-09-10 10:26:00	2025-09-10 10:26:00
310	CHU KEH @ TONG CHEE KONG 	440310015195	2025-09-10 10:26:00	2025-09-10 10:26:00
311	CHUA BOK NGAN	390702015079	2025-09-10 10:26:00	2025-09-10 10:26:00
312	CHUA BOON HOW	790222016243	2025-09-10 10:26:00	2025-09-10 10:26:00
313	CHUA ENG NEO	570311016224	2025-09-10 10:26:00	2025-09-10 10:26:00
314	CHUA JUI HOON	580604015208	2025-09-10 10:26:00	2025-09-10 10:26:00
315	CHUA KENG TECK	580902015345	2025-09-10 10:26:00	2025-09-10 10:26:00
316	CHUNG CHAW @ CHONG SOW KUAK	430110085341	2025-09-10 10:26:00	2025-09-10 10:26:00
317	CRYSTAL TEY MEI LI	071213011116	2025-09-10 10:26:00	2025-09-10 10:26:00
318	DAHARIN BIN IBRAHIM	580618065003	2025-09-10 10:26:00	2025-09-10 10:26:00
319	DAHLAN BIN A. MAJID 	361106015045	2025-09-10 10:26:00	2025-09-10 10:26:00
320	DALILI NUR BALQIS BINTI NORDIN	01116141222'	2025-09-10 10:26:00	2025-09-10 10:26:00
321	DAMIA NUR BALQISH	060816060984	2025-09-10 10:26:00	2025-09-10 10:26:00
322	DANIEL HAIQAL	040405102045	2025-09-10 10:26:00	2025-09-10 10:26:00
323	DARISUL BIN HJ SAMSUDIN	471018015237	2025-09-10 10:26:00	2025-09-10 10:26:00
325	DAUD BIN ISHAK 	570726017325	2025-09-10 10:26:00	2025-09-10 10:26:00
326	DEK A/L LIMA	560823015955	2025-09-10 10:26:00	2025-09-10 10:26:00
327	DEVANI A/P PARMASIVAM 	770622017204	2025-09-10 10:26:00	2025-09-10 10:26:00
328	DEVI A/P ARUMUGAN	511201015634	2025-09-10 10:26:00	2025-09-10 10:26:00
329	DEVIKI A/P SUPPIAH	540626045014	2025-09-10 10:26:00	2025-09-10 10:26:00
330	DINUSH A/L KESAVAN	220216011249	2025-09-10 10:26:00	2025-09-10 10:26:00
331	DOROTHY ANAK MANKAA 	770424135971	2025-09-10 10:26:00	2025-09-10 10:26:00
332	DR IVY CHENG YEE FEN 	880401235088	2025-09-10 10:26:00	2025-09-10 10:26:00
333	DR LIEW KWEE LING	861126465060	2025-09-10 10:26:00	2025-09-10 10:26:00
334	DR NUR ADLINA BINTI TAJUL ARIFIN	870319875036	2025-09-10 10:26:00	2025-09-10 10:26:00
335	DR NUR RASYIDAH	910413055062	2025-09-10 10:26:00	2025-09-10 10:26:00
336	DR TAN NIN ERN	880331235022	2025-09-10 10:26:00	2025-09-10 10:26:00
337	DR YEE CHAU YEN	860702235630	2025-09-10 10:26:00	2025-09-10 10:26:00
338	DURATUL NASIHAH BTE ZAMZURI	901117015088	2025-09-10 10:26:00	2025-09-10 10:26:00
339	DURIAT BIN SARKAWI	620925015093	2025-09-10 10:26:00	2025-09-10 10:26:00
340	DYLAN AW LI SIEN	200722011745	2025-09-10 10:26:00	2025-09-10 10:26:00
341	EDAYAH IBRAHUM 	910102016824	2025-09-10 10:26:00	2025-09-10 10:26:00
342	EE SU FENG 	800114016082	2025-09-10 10:26:00	2025-09-10 10:26:00
343	ENDUN BINTI HUSSAIN	440504065086	2025-09-10 10:26:00	2025-09-10 10:26:00
344	ER CHEW LIAN	750111016180	2025-09-10 10:26:00	2025-09-10 10:26:00
345	ERHAM BIN JAHAN	920107016021	2025-09-10 10:26:00	2025-09-10 10:26:00
346	ESRI HARMAN	690420015665	2025-09-10 10:26:00	2025-09-10 10:26:00
347	ESVARAN A/L MANICKAM 	960805015655	2025-09-10 10:26:00	2025-09-10 10:26:00
349	FADHILAH BINTI JUSDI	911103125998	2025-09-10 10:26:00	2025-09-10 10:26:00
350	FADLY FANDY BIN ABU ZAINI	760103016753	2025-09-10 10:26:00	2025-09-10 10:26:00
351	FAEZAH YUSOF 	030228011118	2025-09-10 10:26:00	2025-09-10 10:26:00
352	FAHMIE BIN SAMSI	880225235053	2025-09-10 10:26:00	2025-09-10 10:26:00
353	FAHMY BI ABDULLAH MUTTALLIB	840426146501	2025-09-10 10:26:00	2025-09-10 10:26:00
354	FAINON BINTI MARSUM 	600515015500	2025-09-10 10:26:00	2025-09-10 10:26:00
355	FAIZAH BINTI HASHIM 	811023045076	2025-09-10 10:26:00	2025-09-10 10:26:00
356	FAIZATUL AMIRA BINTI ROSLI	970608595004	2025-09-10 10:26:00	2025-09-10 10:26:00
357	FAM HOW THUANG	701014015513	2025-09-10 10:26:00	2025-09-10 10:26:00
358	FARAH AHMAD	950114145304	2025-09-10 10:26:00	2025-09-10 10:26:00
359	FARAH NATASHA BINTI NORAZMAR	990108105054	2025-09-10 10:26:00	2025-09-10 10:26:00
360	FARASYASYA IZZATI BT MOHD ISHAM	010904010076	2025-09-10 10:26:00	2025-09-10 10:26:00
361	FARHANAH AYU BINTI ISMAIL	861230236006	2025-09-10 10:26:00	2025-09-10 10:26:00
362	FARIDAH BINTI OMAR	650308015650	2025-09-10 10:26:00	2025-09-10 10:26:00
363	FARIDAH BT SAID 	660215065658	2025-09-10 10:26:00	2025-09-10 10:26:00
364	FATAMAH BINTI SALAM	570506045690	2025-09-10 10:26:00	2025-09-10 10:26:00
365	FATHEIN UMAIRA BINTI SURIANI (OFF. CHANGE TO ARIPRIPAZOLE)	960815565458	2025-09-10 10:26:00	2025-09-10 10:26:00
366	FATIMAH ADNAN	580725015204	2025-09-10 10:26:00	2025-09-10 10:26:00
367	FATIMAH BINTI GHANI 	460520015140	2025-09-10 10:26:00	2025-09-10 10:26:00
368	FATIMAH BINTI MINAL	500817015604	2025-09-10 10:26:00	2025-09-10 10:26:00
369	FATIMAH BINTI SAID	581231015698	2025-09-10 10:26:00	2025-09-10 10:26:00
370	FATIMAH BINTI YUSOF	550926715082	2025-09-10 10:26:00	2025-09-10 10:26:00
371	FATIMAH BT ABU BAKAR	450102015130	2025-09-10 10:26:00	2025-09-10 10:26:00
372	FATIMAH BT AYOB	541031015494	2025-09-10 10:26:00	2025-09-10 10:26:00
373	FATIMAH BT AYUB	621223015878	2025-09-10 10:26:00	2025-09-10 10:26:00
374	FATIMATUZAHRA BT SHARI	891019015352	2025-09-10 10:26:00	2025-09-10 10:26:00
375	FAUZIAH BT ABU HASSAN	650508715272	2025-09-10 10:26:00	2025-09-10 10:26:00
376	FAUZIANA BT ABD JABAR	881116015064	2025-09-10 10:26:00	2025-09-10 10:26:00
377	FERRO FERRINGTON ALLAN	970209135289	2025-09-10 10:26:00	2025-09-10 10:26:00
378	FEZERLON @ FADZELON BINTI ABDUL WAHAB	510415015838	2025-09-10 10:26:00	2025-09-10 10:26:00
379	FIRDAUS BIN NAFIAH	670101018975	2025-09-10 10:26:00	2025-09-10 10:26:00
380	FIRUS BINTI MAZLAN 	861030236220	2025-09-10 10:26:00	2025-09-10 10:26:00
381	FOM FUT SEN	500910015115	2025-09-10 10:26:00	2025-09-10 10:26:00
382	FOM LI YEE	801023045528	2025-09-10 10:26:00	2025-09-10 10:26:00
383	FONG JEW @ PANG YEW	451125015429	2025-09-10 10:26:00	2025-09-10 10:26:00
384	FONG KIM @ TONG BOOK	391118015277	2025-09-10 10:26:00	2025-09-10 10:26:00
385	FOO WAH CHUN	550419015065	2025-09-10 10:26:00	2025-09-10 10:26:00
386	FOO WEE NEE	930903045498	2025-09-10 10:26:00	2025-09-10 10:26:00
387	FU'AD BIN MOHD JUMON	621124015549	2025-09-10 10:26:00	2025-09-10 10:26:00
388	FUZIAH @ FAUZIAH BINTI MUHAMAD	520314015344	2025-09-10 10:26:00	2025-09-10 10:26:00
389	GAN CHA	370614015433	2025-09-10 10:26:00	2025-09-10 10:26:00
390	GAN CHAI KENG 	550717015194	2025-09-10 10:26:00	2025-09-10 10:26:00
391	GAN LEONG CHYE 	620402055221	2025-09-10 10:26:00	2025-09-10 10:26:00
392	GAN SHIN YE	071116011042	2025-09-10 10:26:00	2025-09-10 10:26:00
393	GAN WEI BIN	001123010593	2025-09-10 10:26:00	2025-09-10 10:26:00
394	GANAGA SANTHY A/P RAMACHANDRAN	840823025308	2025-09-10 10:26:00	2025-09-10 10:26:00
395	GANESAN A/L VEMBLI 	581024015919	2025-09-10 10:26:00	2025-09-10 10:26:00
396	GAYATHIRI A/P SUBRAMANIAM	861120235504	2025-09-10 10:26:00	2025-09-10 10:26:00
397	GER BOON HWEE	510515015093	2025-09-10 10:26:00	2025-09-10 10:26:00
398	GERI BIN BIDIN	810806016445	2025-09-10 10:26:00	2025-09-10 10:26:00
399	GEYOK MOY @ TONG GEYOK MOY	510826015154	2025-09-10 10:26:00	2025-09-10 10:26:00
400	GNAPRAKASAM A/L JOSEPH	500731105369	2025-09-10 10:26:00	2025-09-10 10:26:00
401	GO CHENG HOK	670807016189	2025-09-10 10:26:00	2025-09-10 10:26:00
402	GOH BOON KEY	570209016869	2025-09-10 10:26:00	2025-09-10 10:26:00
403	GOH CHOON WAH	490831045205	2025-09-10 10:26:00	2025-09-10 10:26:00
404	HABIBAH BINTI MD TAHIR	500323015524	2025-09-10 10:26:00	2025-09-10 10:26:00
405	HADIJAH BINTI TAUHID	550111015536	2025-09-10 10:26:00	2025-09-10 10:26:00
406	HAFID BIN HASSAN	551203015503	2025-09-10 10:26:00	2025-09-10 10:26:00
407	HAFIDZAH BINTI AWANG	500201015542	2025-09-10 10:26:00	2025-09-10 10:26:00
408	HAFIZAH BINTI KAMARUDDIN	850412065558	2025-09-10 10:26:00	2025-09-10 10:26:00
409	HAIRI MAGANUN 	670307126293	2025-09-10 10:26:00	2025-09-10 10:26:00
410	HAJI ISMAIL BIN MOHD BAHARI 	530602015663	2025-09-10 10:26:00	2025-09-10 10:26:00
411	HALEEQ ADWA BIN MOHD HAFIFY	230921011331	2025-09-10 10:26:00	2025-09-10 10:26:00
412	HALIJAH BT ISMAIL 	620411016224	2025-09-10 10:26:00	2025-09-10 10:26:00
413	HALIMAH BINTI MOHD HAMBALI	811109085642	2025-09-10 10:26:00	2025-09-10 10:26:00
414	HALIMAH JAAMAT	510606015574	2025-09-10 10:26:00	2025-09-10 10:26:00
415	HALIMAH LAJIS 	691020015660	2025-09-10 10:26:00	2025-09-10 10:26:00
416	HALIPAH BINTI MAHAMAD	511030025140	2025-09-10 10:26:00	2025-09-10 10:26:00
417	HAMDAN BIN AMIR	590927016255	2025-09-10 10:26:00	2025-09-10 10:26:00
418	HAMDIAH @ HAMIDAH BINTI MOHAMED	511108015306	2025-09-10 10:26:00	2025-09-10 10:26:00
419	HAMID BIN KATIK	560226055123	2025-09-10 10:26:00	2025-09-10 10:26:00
420	HAMIDAH BINTI ABDUL AZIZ	620224105264	2025-09-10 10:26:00	2025-09-10 10:26:00
421	HAMIDAH BINTI KASIM	590109015568	2025-09-10 10:26:00	2025-09-10 10:26:00
422	HAMIDAH BINTI RAHMAT	661219015054	2025-09-10 10:26:00	2025-09-10 10:26:00
423	HAMIDON BIN ABU 	640225015955	2025-09-10 10:26:00	2025-09-10 10:26:00
424	HAMIDUN BIN ABU BAKAR	500605015055	2025-09-10 10:26:00	2025-09-10 10:26:00
425	HAMIR RIZAL JAMIL	811109065457	2025-09-10 10:26:00	2025-09-10 10:26:00
426	HAMSIAH BINTI AB GHANI	420221015144	2025-09-10 10:26:00	2025-09-10 10:26:00
427	HAMZAH BIN ABU BAKAR	710507015241	2025-09-10 10:26:00	2025-09-10 10:26:00
428	HAMZAH BIN ISHAK	520201065409	2025-09-10 10:26:00	2025-09-10 10:26:00
429	HAMZAH BIN KONG CHONG 	571003016091	2025-09-10 10:26:00	2025-09-10 10:26:00
430	HAMZAH BIN NAZIR	590410015911	2025-09-10 10:26:00	2025-09-10 10:26:00
431	HAMZAH BIN SA'ABAN	560323015043	2025-09-10 10:26:00	2025-09-10 10:26:00
432	HAMZAH BIN TALIB	570228016725	2025-09-10 10:26:00	2025-09-10 10:26:00
433	HANA BINTI IBRAHIM 	910611065018	2025-09-10 10:26:00	2025-09-10 10:26:00
434	HANAFI BIN ARSHAD	861203235219	2025-09-10 10:26:00	2025-09-10 10:26:00
435	HANAFI BIN KAMSAN	570926015295	2025-09-10 10:26:00	2025-09-10 10:26:00
436	HANAM BINTI ATAN 	480619015202	2025-09-10 10:26:00	2025-09-10 10:26:00
437	HANAPI BIN ABAS 	630325715415	2025-09-10 10:26:00	2025-09-10 10:26:00
438	HANIFF BIN HASSAN	501207075217	2025-09-10 10:26:00	2025-09-10 10:26:00
439	HANIZA BINTI MOHAMED HAMBALI 	811015015766	2025-09-10 10:26:00	2025-09-10 10:26:00
440	HARAZA BINTI ABDUL AZIZ	900919065744	2025-09-10 10:26:00	2025-09-10 10:26:00
441	HARRICHANDRAN A/L KRISHNAN	840920016577	2025-09-10 10:26:00	2025-09-10 10:26:00
442	HARTINI BINTI NAHAR	810419125940	2025-09-10 10:26:00	2025-09-10 10:26:00
443	HARUN BIN MANAP	550330015341	2025-09-10 10:26:00	2025-09-10 10:26:00
444	HARUN BIN SAFFAR	611007016199	2025-09-10 10:26:00	2025-09-10 10:26:00
445	HARUN BIN SULIMAN	540524016087	2025-09-10 10:26:00	2025-09-10 10:26:00
446	HASBOLLAH BIN MALIK	690319015097	2025-09-10 10:26:00	2025-09-10 10:26:00
447	HASBULLAH BIN ABD RAZAK	590602055547	2025-09-10 10:26:00	2025-09-10 10:26:00
448	HASBULLAH BIN MAT ESA	750115016647	2025-09-10 10:26:00	2025-09-10 10:26:00
449	HASFANY CHYMAT (MARRIED TO MALAYSIAN)	N01091587	2025-09-10 10:26:00	2025-09-10 10:26:00
450	HASHIM BIN ABU BAKAR	511015015075	2025-09-10 10:26:00	2025-09-10 10:26:00
451	HASHIM BIN ALI 	500726015289	2025-09-10 10:26:00	2025-09-10 10:26:00
452	HASHIM BIN ISMAIL	500729015401	2025-09-10 10:26:00	2025-09-10 10:26:00
453	HASHIM SAPAR	461113015439	2025-09-10 10:26:00	2025-09-10 10:26:00
454	HASNAH JUMARI	640323086132	2025-09-10 10:26:00	2025-09-10 10:26:00
455	HASNAN BIN HASSAN	570705015099	2025-09-10 10:26:00	2025-09-10 10:26:00
456	HASRIN BINTI OTHMAN	710127105106	2025-09-10 10:26:00	2025-09-10 10:26:00
457	HASSAN BIN YAHAYA	630505015715	2025-09-10 10:26:00	2025-09-10 10:26:00
458	HAU CHYE HSIA	800715045372	2025-09-10 10:26:00	2025-09-10 10:26:00
459	HAYATI BINTI JAMIL 	531124015048	2025-09-10 10:26:00	2025-09-10 10:26:00
460	HAZLINNA HON	781106055304	2025-09-10 10:26:00	2025-09-10 10:26:00
461	HELMI BIN MOHAMAD 	811011015427	2025-09-10 10:26:00	2025-09-10 10:26:00
462	HENG JIA YI	960105045028	2025-09-10 10:26:00	2025-09-10 10:26:00
463	HENG SIEW BOON	570712016989	2025-09-10 10:26:00	2025-09-10 10:26:00
464	HIDAYAT B. SAMSURI	560803715049	2025-09-10 10:26:00	2025-09-10 10:26:00
465	HIEW LEE FONG	860226525804	2025-09-10 10:26:00	2025-09-10 10:26:00
466	HISAM BIN HARON	510702015283	2025-09-10 10:26:00	2025-09-10 10:26:00
467	HISHAMUDIN BIN MOHAMAD	671011016153	2025-09-10 10:26:00	2025-09-10 10:26:00
468	HJH LAMINAH BINTI SALLEH	580818016054	2025-09-10 10:26:00	2025-09-10 10:26:00
469	HO CUK HIN	880621015183	2025-09-10 10:26:00	2025-09-10 10:26:00
470	HONG LEE HONG 	480122015346	2025-09-10 10:26:00	2025-09-10 10:26:00
471	HOW KIM PEH	760421045082	2025-09-10 10:26:00	2025-09-10 10:26:00
472	HUANG CHIN LEE @ ENG KAU	430728015185	2025-09-10 10:26:00	2025-09-10 10:26:00
473	HUSIN BIN AB GHANI	450516045313	2025-09-10 10:26:00	2025-09-10 10:26:00
474	HUSNI BIN TAHIR 	530915015453	2025-09-10 10:26:00	2025-09-10 10:26:00
475	HUSSEIN BIN A GAFAR 	540523015461	2025-09-10 10:26:00	2025-09-10 10:26:00
476	HUSSIN BIN SHARIF 	530714015991	2025-09-10 10:26:00	2025-09-10 10:26:00
477	HUZAIDA HUSSEIN	700128015920	2025-09-10 10:26:00	2025-09-10 10:26:00
478	IBRAHIM BIN ABD RAHMAN	580712016259	2025-09-10 10:26:00	2025-09-10 10:26:00
479	IBRAHIM BIN MOHAMED	380522015013	2025-09-10 10:26:00	2025-09-10 10:26:00
480	IBRAHIM BIN SALEH	601031095043	2025-09-10 10:26:00	2025-09-10 10:26:00
481	IBRAHIM BIN SALLEH	490629015571	2025-09-10 10:26:00	2025-09-10 10:26:00
482	IBRAHIM MOHAMED	460110016669	2025-09-10 10:26:00	2025-09-10 10:26:00
483	IDRIS BIN ELIAS	630502016579	2025-09-10 10:26:00	2025-09-10 10:26:00
484	IKHWAN NASIR	781122015783	2025-09-10 10:26:00	2025-09-10 10:26:00
485	ISA BIN AHMAD	571127015277	2025-09-10 10:26:00	2025-09-10 10:26:00
486	ISHAK BIN ABDUL HAMID	560702016249	2025-09-10 10:26:00	2025-09-10 10:26:00
487	ISKANDAR BIN JAMIL	690911016603	2025-09-10 10:26:00	2025-09-10 10:26:00
488	ISMA DANIEL BIN ABDULLAH	050330011577	2025-09-10 10:26:00	2025-09-10 10:26:00
489	ISMAIL B ISHAK	561204015459	2025-09-10 10:26:00	2025-09-10 10:26:00
490	ISMAIL BIN BAHRIN	570821015985	2025-09-10 10:26:00	2025-09-10 10:26:00
491	ISMAIL BIN HASHIM	431211015275	2025-09-10 10:26:00	2025-09-10 10:26:00
492	ISMAIL BIN IBRAHIM	540517045197	2025-09-10 10:26:00	2025-09-10 10:26:00
493	ISMAIL BIN ISHAK	561204015159	2025-09-10 10:26:00	2025-09-10 10:26:00
494	ISMAIL BIN KONTING	560921105831	2025-09-10 10:26:00	2025-09-10 10:26:00
495	ISMAIL BIN MD NOH	570916016163	2025-09-10 10:26:00	2025-09-10 10:26:00
496	ISMAIL BIN MD NOR	681216016033	2025-09-10 10:26:00	2025-09-10 10:26:00
497	ISMAIL BIN MOHAMED 	510903035123	2025-09-10 10:26:00	2025-09-10 10:26:00
498	ISMAIL BIN MOHD	540131015681	2025-09-10 10:26:00	2025-09-10 10:26:00
499	ISMAIL BIN OSMAN	440413305005	2025-09-10 10:26:00	2025-09-10 10:26:00
500	ISMAIL BIN OSMAN (15MG)	440416305005	2025-09-10 10:26:00	2025-09-10 10:26:00
501	ISMAIL BIN RAHIM 	731128016167	2025-09-10 10:26:00	2025-09-10 10:26:00
502	ISMAIL BIN SHARIF	631028015361	2025-09-10 10:26:00	2025-09-10 10:26:00
503	ISMAIL BIN UTOH RACHIK 	530427105759	2025-09-10 10:26:00	2025-09-10 10:26:00
504	ISRAMIRNA BINTI ISMAIL	930120015962	2025-09-10 10:26:00	2025-09-10 10:26:00
505	ITA BINTI ALI	820203715182	2025-09-10 10:26:00	2025-09-10 10:26:00
506	ITHNIN BIN ABDUL GHANI	431024015421	2025-09-10 10:26:00	2025-09-10 10:26:00
507	IZATI FARAHANI BINTI NOH	851203335026	2025-09-10 10:26:00	2025-09-10 10:26:00
508	IZZAR BIN ZAINAL	810412016661	2025-09-10 10:26:00	2025-09-10 10:26:00
509	IZZATIE NAJWA BINTI MOHD IBRAHIM AZHAR	050309010764	2025-09-10 10:26:00	2025-09-10 10:26:00
510	JAAFAR B IDRIS	410228045195	2025-09-10 10:26:00	2025-09-10 10:26:00
511	JAAFAR BIN ABDUL HAMID	460331015467	2025-09-10 10:26:00	2025-09-10 10:26:00
512	JAAFAR BIN ALI	521020085595	2025-09-10 10:26:00	2025-09-10 10:26:00
513	JAANU NAIR A/P KANAKESUARAN	051205010780	2025-09-10 10:26:00	2025-09-10 10:26:00
514	JALAL BIN LEPOD 	720118015829	2025-09-10 10:26:00	2025-09-10 10:26:00
515	JALIL BIN AWANG	571205015193	2025-09-10 10:26:00	2025-09-10 10:26:00
516	JAMAL BIN IDRIS	510703015509	2025-09-10 10:26:00	2025-09-10 10:26:00
517	JAMAL BIN MOHD ISA	620328015909	2025-09-10 10:26:00	2025-09-10 10:26:00
518	JAMALIAH BINTI AB JAMAK	470122015056	2025-09-10 10:26:00	2025-09-10 10:26:00
519	JAMALIAH BT MISKON	620907015612	2025-09-10 10:26:00	2025-09-10 10:26:00
520	JAMALUDIN BIN ADAM	560108055501	2025-09-10 10:26:00	2025-09-10 10:26:00
521	JAMALUDIN BIN HAMBERIN	561107015879	2025-09-10 10:26:00	2025-09-10 10:26:00
522	JAMELAH BT SAWAL	541212015346	2025-09-10 10:26:00	2025-09-10 10:26:00
523	JAMES TAWANG	640628125243	2025-09-10 10:26:00	2025-09-10 10:26:00
524	JAMHARI BIN RAMLI	440523015439	2025-09-10 10:26:00	2025-09-10 10:26:00
525	JAMIL BIN ABDUL SAMAD	551217015977	2025-09-10 10:26:00	2025-09-10 10:26:00
526	JAMIL BIN LAWANG	590717015043	2025-09-10 10:26:00	2025-09-10 10:26:00
527	JAMIL BIN SALLEH	591015016089	2025-09-10 10:26:00	2025-09-10 10:26:00
528	JAMIL BIN SENIM	870511235207	2025-09-10 10:26:00	2025-09-10 10:26:00
529	JAMILAH BINTI IBRAHIM 	591017016592	2025-09-10 10:26:00	2025-09-10 10:26:00
530	JAMILAH BINTI ITHIN	571219015872	2025-09-10 10:26:00	2025-09-10 10:26:00
531	JAMILAH BT AHMAD	710511015658	2025-09-10 10:26:00	2025-09-10 10:26:00
532	JAMILAH BT NINGAL	460215045298	2025-09-10 10:26:00	2025-09-10 10:26:00
533	JAMILLUDDIN NORDIN	601018045455	2025-09-10 10:26:00	2025-09-10 10:26:00
534	JANANI A/P SUBRAMANIAM	041214011006	2025-09-10 10:26:00	2025-09-10 10:26:00
535	JANANKY A/P SINGARAM	540205015570	2025-09-10 10:26:00	2025-09-10 10:26:00
536	JARIAH BT IBRAHIM	570524016746	2025-09-10 10:26:00	2025-09-10 10:26:00
537	JASMAN BIN KALIL	581109105083	2025-09-10 10:26:00	2025-09-10 10:26:00
538	JEE HUA @ WONG JEE HUA	520429015184	2025-09-10 10:26:00	2025-09-10 10:26:00
539	JEE NYUK FONG	750329016626	2025-09-10 10:26:00	2025-09-10 10:26:00
540	JERIAH BINTI AFENDI	530905055232	2025-09-10 10:26:00	2025-09-10 10:26:00
541	JIMAT BIN WAHID 	600212015415	2025-09-10 10:26:00	2025-09-10 10:26:00
542	JOANNE LING JIA ENG	050502080350	2025-09-10 10:26:00	2025-09-10 10:26:00
543	JOCELYN JOSEPH	990403015254	2025-09-10 10:26:00	2025-09-10 10:26:00
544	JOFFRI HUSSEN	540423015659	2025-09-10 10:26:00	2025-09-10 10:26:00
545	JOHARI BIN MD YUSOFF	521001016367	2025-09-10 10:26:00	2025-09-10 10:26:00
546	JOPRI BIN AYOB	560630015473	2025-09-10 10:26:00	2025-09-10 10:26:00
547	JOSEPHINE NG WEN NING	010117010202	2025-09-10 10:26:00	2025-09-10 10:26:00
548	JUHAINUN BINTI JOHAN	711019045382	2025-09-10 10:26:00	2025-09-10 10:26:00
549	JUMILAH JEMAIN	790604045170	2025-09-10 10:26:00	2025-09-10 10:26:00
550	JUNI @ JUMIAH BINTI OTHMAN	440710015266	2025-09-10 10:26:00	2025-09-10 10:26:00
551	JURAIDA BINTI MOHD AZIZ	821107015156	2025-09-10 10:26:00	2025-09-10 10:26:00
552	JURJANI BIN ALI BADROL	760524017199	2025-09-10 10:26:00	2025-09-10 10:26:00
553	K BALASINGAM R KRISHNAN	510903085675	2025-09-10 10:26:00	2025-09-10 10:26:00
554	K NAEHYADEVI A/P KUNASEGARAN	811225015852	2025-09-10 10:26:00	2025-09-10 10:26:00
555	KALA A/P GOVANDAN	840109055526	2025-09-10 10:26:00	2025-09-10 10:26:00
556	KALIAPPAN A/L ANNAMALAI	520730065113	2025-09-10 10:26:00	2025-09-10 10:26:00
557	KALSOM BT IDROS	520414015456	2025-09-10 10:26:00	2025-09-10 10:26:00
558	KALTHUM BINTI SULAIMAN	570928016224	2025-09-10 10:26:00	2025-09-10 10:26:00
559	KAMALIAH BINTI SAEDIN 	890219065712	2025-09-10 10:26:00	2025-09-10 10:26:00
560	KAMALRUZAMAN BIN MOHD YAMAN	771116065945	2025-09-10 10:26:00	2025-09-10 10:26:00
561	KAMARUDDIN BIN OTHMAN	560816065233	2025-09-10 10:26:00	2025-09-10 10:26:00
562	KAMARUDIN DAUD	560217055471	2025-09-10 10:26:00	2025-09-10 10:26:00
563	KAMARULHIZAM BIN IDRIS	741204015043	2025-09-10 10:26:00	2025-09-10 10:26:00
564	KAMARULZAMAN BIN SULAIMAN	610817035469	2025-09-10 10:26:00	2025-09-10 10:26:00
565	KAMIS BIN KADIR 	550113015783	2025-09-10 10:26:00	2025-09-10 10:26:00
566	KAMISAH BINTI PALIL	600204106026	2025-09-10 10:26:00	2025-09-10 10:26:00
567	KAMISAN BIN AWI 	551013015895	2025-09-10 10:26:00	2025-09-10 10:26:00
568	KANAMAH A/P M RAMAN	570930016530	2025-09-10 10:26:00	2025-09-10 10:26:00
569	KANAPATHI A/L RAMIAH 	731225085455	2025-09-10 10:26:00	2025-09-10 10:26:00
570	KANG HANG JIE	110111010605	2025-09-10 10:26:00	2025-09-10 10:26:00
571	KANNA A/L GOMARIAN	840531016637	2025-09-10 10:26:00	2025-09-10 10:26:00
572	KANNAN	800617015081	2025-09-10 10:26:00	2025-09-10 10:26:00
573	KANRANI A/P BATU MALAI	790812015398	2025-09-10 10:26:00	2025-09-10 10:26:00
574	KAREN OOI LEE CHING	830813075556	2025-09-10 10:26:00	2025-09-10 10:26:00
575	KARIM BIN MOHD SAID	710603015145	2025-09-10 10:26:00	2025-09-10 10:26:00
576	KARNAN A/L CHANDRAN	811203015261	2025-09-10 10:26:00	2025-09-10 10:26:00
577	KARNAN A/L MUNIAPPAN 	860701235321	2025-09-10 10:26:00	2025-09-10 10:26:00
578	KARTINI BINTI ABDUL WAHAB 	690123015992	2025-09-10 10:26:00	2025-09-10 10:26:00
579	KASIM ABDULLAH	520315105341	2025-09-10 10:26:00	2025-09-10 10:26:00
580	KASSIM BIN SALLEH	510510015609	2025-09-10 10:26:00	2025-09-10 10:26:00
581	KATIJAH BINTI MASIMON	521214015632	2025-09-10 10:26:00	2025-09-10 10:26:00
582	KATMAH BINTI SA'ANGAT	550302065376	2025-09-10 10:26:00	2025-09-10 10:26:00
583	KATMON B KARIO 	440403015573	2025-09-10 10:26:00	2025-09-10 10:26:00
584	KAVIDAH A/P MACHAP	851226016394	2025-09-10 10:26:00	2025-09-10 10:26:00
585	KAVITHA A/P GANAPATHY	880102235272	2025-09-10 10:26:00	2025-09-10 10:26:00
586	KEAN HONG @ LEE KEAN HONG)	560116015593	2025-09-10 10:26:00	2025-09-10 10:26:00
587	KHADIJAH BINTI JUMAN	680605015574	2025-09-10 10:26:00	2025-09-10 10:26:00
588	KHADIJAH KASIM	520410055266	2025-09-10 10:26:00	2025-09-10 10:26:00
589	KHAIRA NATASYA       	210920010128	2025-09-10 10:26:00	2025-09-10 10:26:00
590	KHAIRI BIN ABD HAMID	720222015079	2025-09-10 10:26:00	2025-09-10 10:26:00
591	KHAIRUDDIN B KASIM	480410015199	2025-09-10 10:26:00	2025-09-10 10:26:00
592	KHALID B ABU BAKAR	650808015809	2025-09-10 10:26:00	2025-09-10 10:26:00
593	KHALID BIN IBRAHIM	530409085467	2025-09-10 10:26:00	2025-09-10 10:26:00
594	KHALID BIN ZAMRI 	650105016629	2025-09-10 10:26:00	2025-09-10 10:26:00
595	KHALID SHAM BIN SHAFEE	620408055855	2025-09-10 10:26:00	2025-09-10 10:26:00
596	KHAMILIA ARINA BT KHAIDI EMI 	020204100758	2025-09-10 10:26:00	2025-09-10 10:26:00
597	KHAMIS BIN YATIM	610323016559	2025-09-10 10:26:00	2025-09-10 10:26:00
598	KHATIJAH BINTI YUSOFF	621122015326	2025-09-10 10:26:00	2025-09-10 10:26:00
599	KHO YING YING	010816010500	2025-09-10 10:26:00	2025-09-10 10:26:00
600	KHOO AH NEO	400219055042	2025-09-10 10:26:00	2025-09-10 10:26:00
601	KHOO AH YONG	620303015419	2025-09-10 10:26:00	2025-09-10 10:26:00
602	KHOO CHAI	311123015148	2025-09-10 10:26:00	2025-09-10 10:26:00
603	KHOO CHOON HUAT	521014015443	2025-09-10 10:26:00	2025-09-10 10:26:00
604	KHOO HUI MIN	870918235524	2025-09-10 10:26:00	2025-09-10 10:26:00
605	KHOO SEK NEE	690928015834	2025-09-10 10:26:00	2025-09-10 10:26:00
606	KHOO WENG TAT	761005016359	2025-09-10 10:26:00	2025-09-10 10:26:00
607	KHOO YEE KHOON	771031015965	2025-09-10 10:26:00	2025-09-10 10:26:00
608	KHU SAY HENG	621025015383	2025-09-10 10:26:00	2025-09-10 10:26:00
610	KING LIT	430731015135	2025-09-10 10:26:00	2025-09-10 10:26:00
611	KISHEN A/L RAVINDRAN 	971117055403	2025-09-10 10:26:00	2025-09-10 10:26:00
612	K'NG YOW HOW	830502015441	2025-09-10 10:26:00	2025-09-10 10:26:00
613	KOH BENG CHOO	550823015593	2025-09-10 10:26:00	2025-09-10 10:26:00
614	KOH MEI LAN 	940815017146	2025-09-10 10:26:00	2025-09-10 10:26:00
615	KOH SIN GEK	560817015449	2025-09-10 10:26:00	2025-09-10 10:26:00
616	KONG SAW MOI	360305015262	2025-09-10 10:26:00	2025-09-10 10:26:00
617	KOTHANDAPANI A/L PAKIRI 	510218015257	2025-09-10 10:26:00	2025-09-10 10:26:00
618	KRISHNAN A/L KANJAPPA	481002015389	2025-09-10 10:26:00	2025-09-10 10:26:00
619	KUA KIAN HAN 	800619015915	2025-09-10 10:26:00	2025-09-10 10:26:00
620	KUH AI TING	581118016162	2025-09-10 10:26:00	2025-09-10 10:26:00
621	KUNSIAN BINTI ATAK	691215125202	2025-09-10 10:26:00	2025-09-10 10:26:00
622	L.PATHMINI 	820705015776	2025-09-10 10:26:00	2025-09-10 10:26:00
623	LAI KOK HONG	330825015365	2025-09-10 10:26:00	2025-09-10 10:26:00
624	LAI KONG CHIN 	560413015071	2025-09-10 10:26:00	2025-09-10 10:26:00
625	LAI MUN LAN	490731105602	2025-09-10 10:26:00	2025-09-10 10:26:00
626	LAILAH BINTI SHARIP 	580613016392	2025-09-10 10:26:00	2025-09-10 10:26:00
627	LAILEE BIN LAJIS	631011015867	2025-09-10 10:26:00	2025-09-10 10:26:00
628	LALITHA A/P N PONNAN 	580416015278	2025-09-10 10:26:00	2025-09-10 10:26:00
629	LAM BENG YOK	561217045366	2025-09-10 10:26:00	2025-09-10 10:26:00
630	LAM CHUAN TIEN@ LAM AH KAU	370510015105	2025-09-10 10:26:00	2025-09-10 10:26:00
631	LAU AH TEY	471019015431	2025-09-10 10:26:00	2025-09-10 10:26:00
632	LAU CHEOK YIN	800608145212	2025-09-10 10:26:00	2025-09-10 10:26:00
633	LAU LEH KIA 	481001075451	2025-09-10 10:26:00	2025-09-10 10:26:00
634	LAU POY YOK	530331015249	2025-09-10 10:26:00	2025-09-10 10:26:00
635	LAU SOON TECK	821112045077	2025-09-10 10:26:00	2025-09-10 10:26:00
636	LAU YEW LIN	661110106729	2025-09-10 10:26:00	2025-09-10 10:26:00
637	LAW BEE LING	640630015000	2025-09-10 10:26:00	2025-09-10 10:26:00
638	LAW SOO ENG SENG	610702015943	2025-09-10 10:26:00	2025-09-10 10:26:00
639	LEE BEE LIAN	670803135236	2025-09-10 10:26:00	2025-09-10 10:26:00
640	LEE BOOI LAN	560503016692	2025-09-10 10:26:00	2025-09-10 10:26:00
641	LEE BOON PING	870516235249	2025-09-10 10:26:00	2025-09-10 10:26:00
642	LEE BOON SING	710416015385	2025-09-10 10:26:00	2025-09-10 10:26:00
643	LEE CHEE MING 	790529015923	2025-09-10 10:26:00	2025-09-10 10:26:00
644	LEE CHENG HON	600518016111	2025-09-10 10:26:00	2025-09-10 10:26:00
645	LEE CHIOK TEONG @ LEE SING	411220015121	2025-09-10 10:26:00	2025-09-10 10:26:00
646	LEE GUAT BEE	660616015758	2025-09-10 10:26:00	2025-09-10 10:26:00
647	LEE HOI CHUAN	350808015353	2025-09-10 10:26:00	2025-09-10 10:26:00
648	LEE KAW 	361105015369	2025-09-10 10:26:00	2025-09-10 10:26:00
649	LEE KIM ENG	581018015226	2025-09-10 10:26:00	2025-09-10 10:26:00
650	LEE KIM HONG 	771208016139	2025-09-10 10:26:00	2025-09-10 10:26:00
651	LEE KIM QIN	010624010856	2025-09-10 10:26:00	2025-09-10 10:26:00
652	LEE KIM QUAN 	110508010275	2025-09-10 10:26:00	2025-09-10 10:26:00
653	LEE KOK HUAT 	620721015673	2025-09-10 10:26:00	2025-09-10 10:26:00
654	LEE LI FANG	011016010486	2025-09-10 10:26:00	2025-09-10 10:26:00
655	LEE LI PING	721025016018	2025-09-10 10:26:00	2025-09-10 10:26:00
656	LEE LIM SOO YING	140527011158	2025-09-10 10:26:00	2025-09-10 10:26:00
657	LEE MEI HWA	640710015588	2025-09-10 10:26:00	2025-09-10 10:26:00
658	LEE MUI @ LAI HON ENG	391230015162	2025-09-10 10:26:00	2025-09-10 10:26:00
659	LEE NG	510629015411	2025-09-10 10:26:00	2025-09-10 10:26:00
660	LEE PEE YING 	681001015658	2025-09-10 10:26:00	2025-09-10 10:26:00
661	LEE POH TOH	621107015280	2025-09-10 10:26:00	2025-09-10 10:26:00
662	LEE SAK	371027105244	2025-09-10 10:26:00	2025-09-10 10:26:00
663	LEE SING LIONG	460806015197	2025-09-10 10:26:00	2025-09-10 10:26:00
664	LEE SIO KUAN	550928015194	2025-09-10 10:26:00	2025-09-10 10:26:00
665	LEE SWEE HAR 	561209015458	2025-09-10 10:26:00	2025-09-10 10:26:00
666	LEE TIEN SHIN	610610055331	2025-09-10 10:26:00	2025-09-10 10:26:00
667	LEE WAH SANG	580517055201	2025-09-10 10:26:00	2025-09-10 10:26:00
668	LEE XIAO QING 	220821011108	2025-09-10 10:26:00	2025-09-10 10:26:00
669	LEE YOKE TENG	590911055364	2025-09-10 10:26:00	2025-09-10 10:26:00
670	LEO CHONG YOU	130112011093	2025-09-10 10:26:00	2025-09-10 10:26:00
671	LEONG KAM YIN	460105015311	2025-09-10 10:26:00	2025-09-10 10:26:00
672	LEONG KIOW	410810015274	2025-09-10 10:26:00	2025-09-10 10:26:00
673	LEONG MEE KHOON	620914085264	2025-09-10 10:26:00	2025-09-10 10:26:00
674	LEONG TUNG CHOY 	531205015007	2025-09-10 10:26:00	2025-09-10 10:26:00
675	LER XIN YI	100721660040	2025-09-10 10:26:00	2025-09-10 10:26:00
676	LETCHIMY A/P PELIASAMY	720729045090	2025-09-10 10:26:00	2025-09-10 10:26:00
677	LEW SEONG YOON 	730105025517	2025-09-10 10:26:00	2025-09-10 10:26:00
678	LEZ DIANA BT OMAR 	931011015490	2025-09-10 10:26:00	2025-09-10 10:26:00
679	LIAU TAN JIN	760321016954	2025-09-10 10:26:00	2025-09-10 10:26:00
680	LIAU YUK FAH	530801015535	2025-09-10 10:26:00	2025-09-10 10:26:00
681	LIEW CHOI YOKE	590801106888	2025-09-10 10:26:00	2025-09-10 10:26:00
682	LIEW PAK WAH	411002015561	2025-09-10 10:26:00	2025-09-10 10:26:00
683	LIEW POH FONG	570210016874	2025-09-10 10:26:00	2025-09-10 10:26:00
684	LIEW SOON YUIN	560924015241	2025-09-10 10:26:00	2025-09-10 10:26:00
685	LIM AH LIAN	590608015239	2025-09-10 10:26:00	2025-09-10 10:26:00
686	LIM BEE CHAN	820524015806	2025-09-10 10:26:00	2025-09-10 10:26:00
687	LIM CHEE HUAT	630930055769	2025-09-10 10:26:00	2025-09-10 10:26:00
688	LIM CHIN KIAN	650825015755	2025-09-10 10:26:00	2025-09-10 10:26:00
689	LIM CHIN PENG	730309015804	2025-09-10 10:26:00	2025-09-10 10:26:00
690	LIM GUAT BEE 	790415016098	2025-09-10 10:26:00	2025-09-10 10:26:00
691	LIM HEE YONG	570616015839	2025-09-10 10:26:00	2025-09-10 10:26:00
692	LIM HUA TENG	501125015501	2025-09-10 10:26:00	2025-09-10 10:26:00
693	LIM HWI NGOH	500323015866	2025-09-10 10:26:00	2025-09-10 10:26:00
694	LIM KANG YI	100712040309	2025-09-10 10:26:00	2025-09-10 10:26:00
695	LIM KAU	560812015511	2025-09-10 10:26:00	2025-09-10 10:26:00
696	LIM KIM GUAT	570604016658	2025-09-10 10:26:00	2025-09-10 10:26:00
697	LIM KIM LAN	650603106774	2025-09-10 10:26:00	2025-09-10 10:26:00
698	LIM KIM WAN	480824105143	2025-09-10 10:26:00	2025-09-10 10:26:00
699	LIM KOA VUN	460616125029	2025-09-10 10:26:00	2025-09-10 10:26:00
700	LIM KWEE LIAN 	670707015146	2025-09-10 10:26:00	2025-09-10 10:26:00
701	LIM LEU LAN	630328055344	2025-09-10 10:26:00	2025-09-10 10:26:00
702	LIM LIAN POOH	520609015165	2025-09-10 10:26:00	2025-09-10 10:26:00
703	LIM MAY CHIAN	790718015930	2025-09-10 10:26:00	2025-09-10 10:26:00
704	LIM MAY YIN 	630830015348	2025-09-10 10:26:00	2025-09-10 10:26:00
705	LIM MENG CHAP SHET 	540306015211	2025-09-10 10:26:00	2025-09-10 10:26:00
706	LIM MENG HOON	440329015099	2025-09-10 10:26:00	2025-09-10 10:26:00
707	LIM MING HER	621013015335	2025-09-10 10:26:00	2025-09-10 10:26:00
708	LIM PEI YIN	861021235824	2025-09-10 10:26:00	2025-09-10 10:26:00
709	LIM SIEW WAN	780723085758	2025-09-10 10:26:00	2025-09-10 10:26:00
710	LIM SIEW YOKE	530322105998	2025-09-10 10:26:00	2025-09-10 10:26:00
711	LIM SONG LE	030708010579	2025-09-10 10:26:00	2025-09-10 10:26:00
712	LIM TENG 	650912015243	2025-09-10 10:26:00	2025-09-10 10:26:00
713	LIM TIAN CHOY	610827015277	2025-09-10 10:26:00	2025-09-10 10:26:00
714	LIM TOW YONG	830119015545	2025-09-10 10:26:00	2025-09-10 10:26:00
715	LIM WAH KIM	530325015015	2025-09-10 10:26:00	2025-09-10 10:26:00
716	LIM WAH TIAN	550103015261	2025-09-10 10:26:00	2025-09-10 10:26:00
717	LIM WEI SIANG	980820016259	2025-09-10 10:26:00	2025-09-10 10:26:00
718	LIM YEE LIAN	861028236205	2025-09-10 10:26:00	2025-09-10 10:26:00
719	LIM YEN PING	811104015514	2025-09-10 10:26:00	2025-09-10 10:26:00
720	LIM YET GOH	620623015928	2025-09-10 10:26:00	2025-09-10 10:26:00
721	LIM YI YING	060723011278	2025-09-10 10:26:00	2025-09-10 10:26:00
722	LIM YOK LAN	490303015440	2025-09-10 10:26:00	2025-09-10 10:26:00
723	LIM ZEN YANG	891121045179	2025-09-10 10:26:00	2025-09-10 10:26:00
724	LINGESWARAN A/L PUBALAN	910707075157	2025-09-10 10:26:00	2025-09-10 10:26:00
725	LIONG AH HUAT	591229015233	2025-09-10 10:26:00	2025-09-10 10:26:00
726	LIONG SONG LAY	470503015631	2025-09-10 10:26:00	2025-09-10 10:26:00
727	LIOW SIOW HENG @ LIAW CHAU HUAN	520117015839	2025-09-10 10:26:00	2025-09-10 10:26:00
728	LO CHOO	370603715012	2025-09-10 10:26:00	2025-09-10 10:26:00
729	LOH HOON CHONG	591105015987	2025-09-10 10:26:00	2025-09-10 10:26:00
730	LOH SIOW CHUI	681109115764	2025-09-10 10:26:00	2025-09-10 10:26:00
731	LOI POH SAI	540201016031	2025-09-10 10:26:00	2025-09-10 10:26:00
732	LOK KIM HONG	360516105559	2025-09-10 10:26:00	2025-09-10 10:26:00
733	LOKE SENG CHEONG	610423065251	2025-09-10 10:26:00	2025-09-10 10:26:00
734	LOO HAN CHIN	650130075698	2025-09-10 10:26:00	2025-09-10 10:26:00
735	LOO MOI @ LOO BEI NIEN 	460825015475	2025-09-10 10:26:00	2025-09-10 10:26:00
736	LOOI KIANG PANG	510718015245	2025-09-10 10:26:00	2025-09-10 10:26:00
737	LOR LEI SIAH	790227015856	2025-09-10 10:26:00	2025-09-10 10:26:00
738	LOUISE A/L R VINCENT 	610202015605	2025-09-10 10:26:00	2025-09-10 10:26:00
739	LOW CHIN HENG 	511013015231	2025-09-10 10:26:00	2025-09-10 10:26:00
740	LOW KIM KEE 	540809015731	2025-09-10 10:26:00	2025-09-10 10:26:00
741	LOY POH MOY	470830015268	2025-09-10 10:26:00	2025-09-10 10:26:00
742	M. AMIRUDDIN	76717	2025-09-10 10:26:00	2025-09-10 10:26:00
743	MAGANTHERN A/L BOOPATHI 	640905015609	2025-09-10 10:26:00	2025-09-10 10:26:00
744	MAHADI BIN SANGIDI	650414015267	2025-09-10 10:26:00	2025-09-10 10:26:00
745	MAHADZIR MAT YUSUF	771004066281	2025-09-10 10:26:00	2025-09-10 10:26:00
746	MAHAFIZ BIN HAMIDON	700616015479	2025-09-10 10:26:00	2025-09-10 10:26:00
747	MAHAMAD NAJIB	590309086201	2025-09-10 10:26:00	2025-09-10 10:26:00
748	MAHANI BT MOHD MAT	670730015048	2025-09-10 10:26:00	2025-09-10 10:26:00
749	MAHAT BIN SAADON	450508015421	2025-09-10 10:26:00	2025-09-10 10:26:00
750	MAHFAR B ARSHAD	510802015379	2025-09-10 10:26:00	2025-09-10 10:26:00
751	MAHMOD BIN AHMAD	440215015509	2025-09-10 10:26:00	2025-09-10 10:26:00
752	MAHMOOD BIN PALI	470329015387	2025-09-10 10:26:00	2025-09-10 10:26:00
753	MAHMUD BIN AHMAD	520318105531	2025-09-10 10:26:00	2025-09-10 10:26:00
754	MAIMUNAH BINTI ATAN	620420015012	2025-09-10 10:26:00	2025-09-10 10:26:00
755	MAIZURA BINTI MOHAMAD	910814015088	2025-09-10 10:26:00	2025-09-10 10:26:00
756	MAK PEE KWANG XIN	900225105625	2025-09-10 10:26:00	2025-09-10 10:26:00
757	MAN JOK YAI	710928015549	2025-09-10 10:26:00	2025-09-10 10:26:00
758	MANAN BIN ABU BAKAR 	560811015819	2025-09-10 10:26:00	2025-09-10 10:26:00
759	MANAS BIN NAWI	381218015179	2025-09-10 10:26:00	2025-09-10 10:26:00
760	MANICAN A/L R PAIKERSAMY	530913015185	2025-09-10 10:26:00	2025-09-10 10:26:00
761	MANIMARAN A/L SUPPAN	661122055009	2025-09-10 10:26:00	2025-09-10 10:26:00
762	MANOGAR A/L PERUMAL	561204015379	2025-09-10 10:26:00	2025-09-10 10:26:00
763	MANSOR BIN IBRAHIM	500324016019	2025-09-10 10:26:00	2025-09-10 10:26:00
764	MANSOR BIN JANI	590704016119	2025-09-10 10:26:00	2025-09-10 10:26:00
765	MANSOR BIN MANAN	540825016195	2025-09-10 10:26:00	2025-09-10 10:26:00
766	MANSOR BIN MOHAMAD	540413015313	2025-09-10 10:26:00	2025-09-10 10:26:00
767	MANSOR BIN SALLEH	610228015179	2025-09-10 10:26:00	2025-09-10 10:26:00
768	MARIAH BINTI YUSOP 	470919015838	2025-09-10 10:26:00	2025-09-10 10:26:00
769	MARIANA BINTI SETU	880720235026	2025-09-10 10:26:00	2025-09-10 10:26:00
770	MARNIAH @ MEH BINTI MAT        	390724085502	2025-09-10 10:26:00	2025-09-10 10:26:00
771	MARSIAH BINTI SAKIMAN	651023015686	2025-09-10 10:26:00	2025-09-10 10:26:00
772	MARSIDAH BT SALIM	580118015472	2025-09-10 10:26:00	2025-09-10 10:26:00
773	MARTHANDY PERIYANAN	661026015963	2025-09-10 10:26:00	2025-09-10 10:26:00
774	MARWIYAH SIPIR	420309015368	2025-09-10 10:26:00	2025-09-10 10:26:00
775	MARYATULQIBTIYAH BT MD KASIM	840930016300	2025-09-10 10:26:00	2025-09-10 10:26:00
776	MASDAR BIN SANON	531116015515	2025-09-10 10:26:00	2025-09-10 10:26:00
777	MASIMI SEPERI A/P RATNAM	581203055246	2025-09-10 10:26:00	2025-09-10 10:26:00
778	MASLIZA BINTI MAHMOD	941205016474	2025-09-10 10:26:00	2025-09-10 10:26:00
779	MASNAH BINTI THOMEN	641107016054	2025-09-10 10:26:00	2025-09-10 10:26:00
780	MASNAN BIN SAHIT	510919015153	2025-09-10 10:26:00	2025-09-10 10:26:00
781	MASOREE BIN SAPIA	540416015079	2025-09-10 10:26:00	2025-09-10 10:26:00
782	MASPAN @ MISPAN BIN RASHID	510802015547	2025-09-10 10:26:00	2025-09-10 10:26:00
783	MASRAN BIN DERMAWATI	570207015045	2025-09-10 10:26:00	2025-09-10 10:26:00
784	MASTURA HASSAN	810718015768	2025-09-10 10:26:00	2025-09-10 10:26:00
785	MAT NAWAR BIN BUYONG @ HAMZAH	480629085837	2025-09-10 10:26:00	2025-09-10 10:26:00
786	MAT SA'AT BIN IBRAHIM	580718015839	2025-09-10 10:26:00	2025-09-10 10:26:00
787	MAT ZAIN BIN MAT DIA	690429085467	2025-09-10 10:26:00	2025-09-10 10:26:00
788	MATHIVANAN A/L SELLAMUTHU	760418016651	2025-09-10 10:26:00	2025-09-10 10:26:00
789	MAY KIA	400824015022	2025-09-10 10:26:00	2025-09-10 10:26:00
790	MAZALLENA BT HASHIM	790608015278	2025-09-10 10:26:00	2025-09-10 10:26:00
791	MAZLAN BIN SABRAH 	560402016247	2025-09-10 10:26:00	2025-09-10 10:26:00
792	MAZMAH BT MAHADI	610104015150	2025-09-10 10:26:00	2025-09-10 10:26:00
793	MAZNAH BINTI MANIN	570826016944	2025-09-10 10:26:00	2025-09-10 10:26:00
794	MAZRI BACHOK	820116015997	2025-09-10 10:26:00	2025-09-10 10:26:00
795	MAZUIN BINTI RAMLI	600103086732	2025-09-10 10:26:00	2025-09-10 10:26:00
796	MD AZHAR ISMAIL	650417055571	2025-09-10 10:26:00	2025-09-10 10:26:00
797	MD ESA BIN A WAHAB	550325015515	2025-09-10 10:26:00	2025-09-10 10:26:00
798	MD FARID BIN HJ A HAMID	531018015079	2025-09-10 10:26:00	2025-09-10 10:26:00
799	MD FARID BIN MOHAMED	620523016149	2025-09-10 10:26:00	2025-09-10 10:26:00
800	MD HANAPIAH @ OTHMAN BIN MD TAHIR 	531116015443	2025-09-10 10:26:00	2025-09-10 10:26:00
801	MD HAYAT BIN ABD RAZAK	600608015497	2025-09-10 10:26:00	2025-09-10 10:26:00
802	MD HISHAM BIN ISAP	820405016435	2025-09-10 10:26:00	2025-09-10 10:26:00
803	MD HISHAM BIN ISAP 	820405016436	2025-09-10 10:26:00	2025-09-10 10:26:00
804	MD HUSIN BIN SUKAMAR	550914015361	2025-09-10 10:26:00	2025-09-10 10:26:00
805	MD IBRAHIM BIN A KARIM	500527025089	2025-09-10 10:26:00	2025-09-10 10:26:00
806	MD JOHAN SILONG	560901055769	2025-09-10 10:26:00	2025-09-10 10:26:00
807	MD JOHAR	561001016611	2025-09-10 10:26:00	2025-09-10 10:26:00
808	MD SAID BIN MD TAIB        	560831015947	2025-09-10 10:26:00	2025-09-10 10:26:00
809	MD SHEH BIN SAHAT	551005015879	2025-09-10 10:26:00	2025-09-10 10:26:00
810	MD SOHOOD	550328016097	2025-09-10 10:26:00	2025-09-10 10:26:00
811	MD SUBOH BIN MD ALI\t	540607015469	2025-09-10 10:26:00	2025-09-10 10:26:00
812	MD TAHIR BIN MOHD SAID	491003015443	2025-09-10 10:26:00	2025-09-10 10:26:00
813	MD YASIN BIN KHAMIS	670423015275	2025-09-10 10:26:00	2025-09-10 10:26:00
814	MD YUSOF	541122015713	2025-09-10 10:26:00	2025-09-10 10:26:00
815	MD YUSOF BIN AB KADIR	570729016539	2025-09-10 10:26:00	2025-09-10 10:26:00
816	MD ZAIDI BIN MD ALI	710311025675	2025-09-10 10:26:00	2025-09-10 10:26:00
817	MD ZALI BIN DARLILAN 	591105016269	2025-09-10 10:26:00	2025-09-10 10:26:00
818	MD ZULKIFLI B ZAKARIA	601217015793	2025-09-10 10:26:00	2025-09-10 10:26:00
819	ME'AN BIN SARBAREE	660226015701	2025-09-10 10:26:00	2025-09-10 10:26:00
820	MEE BINTI AWANG	501229015004	2025-09-10 10:26:00	2025-09-10 10:26:00
821	MEENACHI 	560524015250	2025-09-10 10:26:00	2025-09-10 10:26:00
822	MEILIANA ARISHA MAZURANI	A911226016524	2025-09-10 10:26:00	2025-09-10 10:26:00
823	MELAN BIN JABAR 	620416016223	2025-09-10 10:26:00	2025-09-10 10:26:00
824	MERIAM A/P LANCHAN	530523825078	2025-09-10 10:26:00	2025-09-10 10:26:00
825	MESSICHA BT JANIMAN	521008015404	2025-09-10 10:26:00	2025-09-10 10:26:00
827	MIOR RASIP BIN MD SHARIF	870711015831	2025-09-10 10:26:00	2025-09-10 10:26:00
828	MIRA NATASYA BINTI KAMARUZAMAN	020614010288	2025-09-10 10:26:00	2025-09-10 10:26:00
829	MISKON B SALLEHAN	551125015531	2025-09-10 10:26:00	2025-09-10 10:26:00
830	MISLAN BIN AB SAMAD	350825085169	2025-09-10 10:26:00	2025-09-10 10:26:00
831	MISNAH BINTI MINTO	561214015778	2025-09-10 10:26:00	2025-09-10 10:26:00
832	MISNAN BIN HJ ELIAS 	470103015181	2025-09-10 10:26:00	2025-09-10 10:26:00
833	MISNAN BIN JASMI	861106235129	2025-09-10 10:26:00	2025-09-10 10:26:00
834	MISRAN	520621015619	2025-09-10 10:26:00	2025-09-10 10:26:00
835	MISRAN JAPAR	361113015297	2025-09-10 10:26:00	2025-09-10 10:26:00
836	MISRI BIN AHMAD	330207015173	2025-09-10 10:26:00	2025-09-10 10:26:00
837	MISWAN BIN ABD MAJID 	560329015343	2025-09-10 10:26:00	2025-09-10 10:26:00
838	MOBIL AHMAD (PESARA)	590210045083	2025-09-10 10:26:00	2025-09-10 10:26:00
839	MOH AI LENG	670228015026	2025-09-10 10:26:00	2025-09-10 10:26:00
840	MOH NOOR BIN GHANI	660518065217	2025-09-10 10:26:00	2025-09-10 10:26:00
841	MOHAMAD AIRI ADAHAM BIN AZIZAN	100521060091	2025-09-10 10:26:00	2025-09-10 10:26:00
842	MOHAMAD AMIRUL AIMAN BIN ABDULLAH	020111060881	2025-09-10 10:26:00	2025-09-10 10:26:00
843	MOHAMAD AZIIM BIN MOHD HASHIM	941229145705	2025-09-10 10:26:00	2025-09-10 10:26:00
844	MOHAMAD AZRIN 	760212017069	2025-09-10 10:26:00	2025-09-10 10:26:00
845	MOHAMAD BIN AB MAJID	471010015339	2025-09-10 10:26:00	2025-09-10 10:26:00
846	MOHAMAD BIN ABDULLAH	710103016969	2025-09-10 10:26:00	2025-09-10 10:26:00
847	MOHAMAD BIN BAKAR	641220015977	2025-09-10 10:26:00	2025-09-10 10:26:00
848	MOHAMAD BIN HANAFI	311030025275	2025-09-10 10:26:00	2025-09-10 10:26:00
849	MOHAMAD BIN JABAR 	630316045595	2025-09-10 10:26:00	2025-09-10 10:26:00
850	MOHAMAD BIN YAHYA	581124016273	2025-09-10 10:26:00	2025-09-10 10:26:00
851	MOHAMAD EYAMANI ADIL BIN ABD AZIZ	930903016179	2025-09-10 10:26:00	2025-09-10 10:26:00
852	MOHAMAD FADLY BIN MOHAMAD GAZALI       	820707016721	2025-09-10 10:26:00	2025-09-10 10:26:00
853	MOHAMAD FARHAN BIN SAMZAR	941009016071	2025-09-10 10:26:00	2025-09-10 10:26:00
854	MOHAMAD HAFIZ B IRWAN SHAH KRISHNAN	910728015321	2025-09-10 10:26:00	2025-09-10 10:26:00
855	MOHAMAD IDRIS BIN MOHD ISA	770122015923	2025-09-10 10:26:00	2025-09-10 10:26:00
856	MOHAMAD JASMI BIN NGANTIRAN	620622055071	2025-09-10 10:26:00	2025-09-10 10:26:00
857	MOHAMAD KHALID BIN MUSTAFFA	640624015215	2025-09-10 10:26:00	2025-09-10 10:26:00
858	MOHAMAD LAMSAH BIN PUTEH	411027055017	2025-09-10 10:26:00	2025-09-10 10:26:00
859	MOHAMAD NASIR BIN ABDUL JALIL 	580809016001	2025-09-10 10:26:00	2025-09-10 10:26:00
860	MOHAMAD NAZMAN RAMZAN B ABDULLAH	990105018377	2025-09-10 10:26:00	2025-09-10 10:26:00
861	MOHAMAD NOR AMIN BIN MUHALID 	870818235113	2025-09-10 10:26:00	2025-09-10 10:26:00
862	MOHAMAD RAFIQ BIN SULAIMAN	890331016179	2025-09-10 10:26:00	2025-09-10 10:26:00
863	MOHAMAD ROSLI	540318055579	2025-09-10 10:26:00	2025-09-10 10:26:00
864	MOHAMAD SADO AL AMIN BIN KAMARUDIN\t	161018010555	2025-09-10 10:26:00	2025-09-10 10:26:00
865	MOHAMAD SALLEH BIN SULAIMAN	560713055251	2025-09-10 10:26:00	2025-09-10 10:26:00
866	MOHAMAD SHAH BIN YASIN 	390413015355	2025-09-10 10:26:00	2025-09-10 10:26:00
867	MOHAMAD SYAFIQ BIN TUNGAL	971228015383	2025-09-10 10:26:00	2025-09-10 10:26:00
868	MOHAMAD SYARAFUDDIN BIN ABDUL AZIZ 	940620015693	2025-09-10 10:26:00	2025-09-10 10:26:00
869	MOHAMAD YUSOF	560413015901	2025-09-10 10:26:00	2025-09-10 10:26:00
870	MOHAMAD ZAKI BIN MOHD ZADI 	000530010303	2025-09-10 10:26:00	2025-09-10 10:26:00
871	MOHAMED BIN ABDULLAH	520207015007	2025-09-10 10:26:00	2025-09-10 10:26:00
872	MOHAMED SABILAN BIN SAIDON	400605015153	2025-09-10 10:26:00	2025-09-10 10:26:00
873	MOHAMMAD ABDILLAH 	850209115361	2025-09-10 10:26:00	2025-09-10 10:26:00
874	MOHAMMAD ALI BIN ABDULLAH	621016015533	2025-09-10 10:26:00	2025-09-10 10:26:00
875	MOHAMMAD ALIF BIN MOHD YATIM	070418160073	2025-09-10 10:26:00	2025-09-10 10:26:00
876	MOHAMMAD ALIFF NAJMI	010706011801	2025-09-10 10:26:00	2025-09-10 10:26:00
877	MOHAMMAD ASMOIN BIN HAMZAH 	730924035591	2025-09-10 10:26:00	2025-09-10 10:26:00
878	MOHAMMAD BIN SAMAD 	510815015263	2025-09-10 10:26:00	2025-09-10 10:26:00
879	MOHAMMAD DIN BIN YASIN	570712715421	2025-09-10 10:26:00	2025-09-10 10:26:00
880	MOHAMMAD NAJIB BIN MD ESA	770308017003	2025-09-10 10:26:00	2025-09-10 10:26:00
881	MOHAMMAD SABRI BIN SALLIH	940821015913	2025-09-10 10:26:00	2025-09-10 10:26:00
882	MOHAMMED  ZIN BIN YUSAK	700410016089	2025-09-10 10:26:00	2025-09-10 10:26:00
883	MOHAN A/L GUVENTEN	620204055415	2025-09-10 10:26:00	2025-09-10 10:26:00
884	MOHAN A/L KUNCHI RAMAN	630219015845	2025-09-10 10:26:00	2025-09-10 10:26:00
885	MOHD AKIB BIN SHUAIB	520711715133	2025-09-10 10:26:00	2025-09-10 10:26:00
886	MOHD ALI BIN ABD MANAN	580208016217	2025-09-10 10:26:00	2025-09-10 10:26:00
887	MOHD ALIF BIN MUSA	860409235551	2025-09-10 10:26:00	2025-09-10 10:26:00
888	MOHD AMEERUL FADZLI	880528015533	2025-09-10 10:26:00	2025-09-10 10:26:00
889	MOHD AMIN BIN TUNI 	560325085467	2025-09-10 10:26:00	2025-09-10 10:26:00
890	MOHD AMINUDDIN BIN GHAZALI	570830085061	2025-09-10 10:26:00	2025-09-10 10:26:00
891	MOHD ANUAR ISMAIL	890701235193	2025-09-10 10:26:00	2025-09-10 10:26:00
892	MOHD ARBAIEAN BIN YUSOS	800612105985	2025-09-10 10:26:00	2025-09-10 10:26:00
893	MOHD ARIF BIN JAMBARI @ ZAMBARI	911109016995	2025-09-10 10:26:00	2025-09-10 10:26:00
894	MOHD AYUB BIN IDRIS	720604065485	2025-09-10 10:26:00	2025-09-10 10:26:00
895	MOHD AZAN BIN MOHD NOH	570730016843	2025-09-10 10:26:00	2025-09-10 10:26:00
1981	SAMYANG	123456789	2025-10-27 10:03:45.353078	2025-10-27 10:03:45.353078
896	MOHD DZAHID BIN HAJI MANSOR	550401055333	2025-09-10 10:26:00	2025-09-10 10:26:00
897	MOHD ERWANDI BIN SALAMAN	800516015699	2025-09-10 10:26:00	2025-09-10 10:26:00
898	MOHD FAISOL BIN MOHD KHAIRUDDIN	910426065761	2025-09-10 10:26:00	2025-09-10 10:26:00
899	MOHD FAIZAL BIN SAID	760123065499	2025-09-10 10:26:00	2025-09-10 10:26:00
900	MOHD FAREZ BIN MOHD NOH 	871009236559	2025-09-10 10:26:00	2025-09-10 10:26:00
901	MOHD FARID BIN ABD MANSOR	010301060541	2025-09-10 10:26:00	2025-09-10 10:26:00
902	MOHD FAUZI	900706138671	2025-09-10 10:26:00	2025-09-10 10:26:00
903	MOHD FAUZI B RADZI	581127085645	2025-09-10 10:26:00	2025-09-10 10:26:00
904	MOHD FENDI BIN ABDULLAH 	890831235263	2025-09-10 10:26:00	2025-09-10 10:26:00
905	MOHD FIKRI ABDUL RAHMAN	880820235891	2025-09-10 10:26:00	2025-09-10 10:26:00
906	MOHD HAFIZZUDDIN BIN MOHD IDRIS	830530065083	2025-09-10 10:26:00	2025-09-10 10:26:00
907	MOHD HALIM B JIMAN	620624015823	2025-09-10 10:26:00	2025-09-10 10:26:00
908	MOHD HASHIM BIN ABU HASSAN	810501065799	2025-09-10 10:26:00	2025-09-10 10:26:00
909	MOHD HAZLAN BIN ZAKARIA 	810208075031	2025-09-10 10:26:00	2025-09-10 10:26:00
910	MOHD HELMY EZRIN BIN HUSSIN	850206145063	2025-09-10 10:26:00	2025-09-10 10:26:00
911	MOHD ISA BIN JAAFAR 	950913127073	2025-09-10 10:26:00	2025-09-10 10:26:00
912	MOHD IZWAN ABD RAHIM 	950215035059	2025-09-10 10:26:00	2025-09-10 10:26:00
913	MOHD KAMAL BIN ARIPPIN	670319055357	2025-09-10 10:26:00	2025-09-10 10:26:00
914	MOHD KAMARUL BIN MAZLAN	841031016563	2025-09-10 10:26:00	2025-09-10 10:26:00
915	MOHD MAZLEE BIN FADZIL ANUAR	941107015275	2025-09-10 10:26:00	2025-09-10 10:26:00
916	MOHD MOKHTAR BIN TAIB	500120015727	2025-09-10 10:26:00	2025-09-10 10:26:00
917	MOHD NASAH BIN SHAHAR	820917015583	2025-09-10 10:26:00	2025-09-10 10:26:00
918	MOHD NASIR MOHD SALLEH	520630016365	2025-09-10 10:26:00	2025-09-10 10:26:00
919	MOHD NAZRI BIN MOHD NASIR	780604016127	2025-09-10 10:26:00	2025-09-10 10:26:00
920	MOHD NIZAM KAMISAH	920303015261	2025-09-10 10:26:00	2025-09-10 10:26:00
921	MOHD NOH BIN HASSAN	440603015105	2025-09-10 10:26:00	2025-09-10 10:26:00
922	MOHD NOOH BIN JOHAR	600518015805	2025-09-10 10:26:00	2025-09-10 10:26:00
923	MOHD NOOR BIN ABDULLAH	551104016041	2025-09-10 10:26:00	2025-09-10 10:26:00
924	MOHD NOR AFDZAN	951211016605	2025-09-10 10:26:00	2025-09-10 10:26:00
925	MOHD NORARIF BIN ARIPIN	940214015145	2025-09-10 10:26:00	2025-09-10 10:26:00
926	MOHD QAYYUM	851027015241	2025-09-10 10:26:00	2025-09-10 10:26:00
927	MOHD RADZUAN BIN SHAMSUDIN 	570717086169	2025-09-10 10:26:00	2025-09-10 10:26:00
928	MOHD RAMLY SAMAD	390731065083	2025-09-10 10:26:00	2025-09-10 10:26:00
929	MOHD RAZALI IBRAHIM 	820305016139	2025-09-10 10:26:00	2025-09-10 10:26:00
930	MOHD RAZI BIN ARIFFIN	611020025217	2025-09-10 10:26:00	2025-09-10 10:26:00
931	MOHD REJAB B MOHD AKHIR	940109015127	2025-09-10 10:26:00	2025-09-10 10:26:00
932	MOHD REZUAN SAHAR 	810823015989	2025-09-10 10:26:00	2025-09-10 10:26:00
933	MOHD RIDZUAN	761205065307	2025-09-10 10:26:00	2025-09-10 10:26:00
934	MOHD RIDZUAN BIN MD ZAN	850608015341	2025-09-10 10:26:00	2025-09-10 10:26:00
935	MOHD RIZUAN BIN MOHD ARBAIN	861029235263	2025-09-10 10:26:00	2025-09-10 10:26:00
936	MOHD RODIN	500903025489	2025-09-10 10:26:00	2025-09-10 10:26:00
937	MOHD ROZAIDI	820724086107	2025-09-10 10:26:00	2025-09-10 10:26:00
938	MOHD SAFRI BIN MOHAMAD	660414035785	2025-09-10 10:26:00	2025-09-10 10:26:00
939	MOHD SALLEH BIN HARON	450713015201	2025-09-10 10:26:00	2025-09-10 10:26:00
940	MOHD SAUFI YAHYA	751031016433	2025-09-10 10:26:00	2025-09-10 10:26:00
941	MOHD SHAH BIN KARIM	620922015709	2025-09-10 10:26:00	2025-09-10 10:26:00
942	MOHD SHAH RAZEE BI  ABDULLAH	890429016513	2025-09-10 10:26:00	2025-09-10 10:26:00
943	MOHD SHAIEM BIN MUSTAFFA 	670629015019	2025-09-10 10:26:00	2025-09-10 10:26:00
944	MOHD SHAIFUL BIN ABD MALIK	810807055585	2025-09-10 10:26:00	2025-09-10 10:26:00
945	MOHD SHAKIZAL 	830925025991	2025-09-10 10:26:00	2025-09-10 10:26:00
946	MOHD SHEDEE HUZREN	980518016629	2025-09-10 10:26:00	2025-09-10 10:26:00
947	MOHD SHUKRI BIN MOHD NORDIN 	740919086705	2025-09-10 10:26:00	2025-09-10 10:26:00
948	MOHD SUHAIL ADLI BIN MOHD NOR SHAH	971009055203	2025-09-10 10:26:00	2025-09-10 10:26:00
949	MOHD SUHAIMI A.M. TALIB	680403016149	2025-09-10 10:26:00	2025-09-10 10:26:00
950	MOHD TAHIR BIN IBRAHIM	461219045441	2025-09-10 10:26:00	2025-09-10 10:26:00
951	MOHD TAHIR BIN KASSIM	530827015541	2025-09-10 10:26:00	2025-09-10 10:26:00
952	MOHD TAIP	581123015009	2025-09-10 10:26:00	2025-09-10 10:26:00
953	MOHD YASIN BIN DOLLAH 	540308106379	2025-09-10 10:26:00	2025-09-10 10:26:00
954	MOHD YASIN BIN MAHAD	621016045759	2025-09-10 10:26:00	2025-09-10 10:26:00
955	MOHD YATIM ADAM (15MG)	471113015673	2025-09-10 10:26:00	2025-09-10 10:26:00
956	MOHD YUSOF ABD AZIZ	600913015303	2025-09-10 10:26:00	2025-09-10 10:26:00
957	MOHD YUSOF BIN BADELI	691117015077	2025-09-10 10:26:00	2025-09-10 10:26:00
958	MOHD YUSOF BIN ISMAIL	580921015949	2025-09-10 10:26:00	2025-09-10 10:26:00
959	MOHD YUSOF BIN MOHD ALI	430513015241	2025-09-10 10:26:00	2025-09-10 10:26:00
960	MOHD YUSOF BIN MUDA	511122015417	2025-09-10 10:26:00	2025-09-10 10:26:00
961	MOHD YUSOF M. TAHIR	640226015607	2025-09-10 10:26:00	2025-09-10 10:26:00
962	MOHD YUSOFF 	620428105821	2025-09-10 10:26:00	2025-09-10 10:26:00
963	MOHD YUSOFF BIN OMAR	421110055287	2025-09-10 10:26:00	2025-09-10 10:26:00
964	MOHD YUSRI B MOHD YUSOF	870418015111	2025-09-10 10:26:00	2025-09-10 10:26:00
965	MOHD ZAIDI BIN ABDULLAH 	800821035709	2025-09-10 10:26:00	2025-09-10 10:26:00
966	MOHD ZAIDI BIN AMAT	870724065053	2025-09-10 10:26:00	2025-09-10 10:26:00
967	MOHD ZAIDI BIN MOHD OMAR ALI 	741213105497	2025-09-10 10:26:00	2025-09-10 10:26:00
968	MOHD ZAIN BIN AHMAD 	561014015095	2025-09-10 10:26:00	2025-09-10 10:26:00
969	MOHD ZAITUN BIN SULEIMAN	620215015961	2025-09-10 10:26:00	2025-09-10 10:26:00
970	MOIN BIN IBRAHIM	430319015109	2025-09-10 10:26:00	2025-09-10 10:26:00
971	MOK BOON HENG	700308015979	2025-09-10 10:26:00	2025-09-10 10:26:00
972	MOK CHIEW HYA 	530722015334	2025-09-10 10:26:00	2025-09-10 10:26:00
973	MOKNASING @JOHN A/L RATHNAM	490202055187	2025-09-10 10:26:00	2025-09-10 10:26:00
974	MOLLY KAY YOKE PENG	511115015152	2025-09-10 10:26:00	2025-09-10 10:26:00
975	MORAJI B MARJUKI	570802016595	2025-09-10 10:26:00	2025-09-10 10:26:00
976	MORNI BINTI JALIL	640423015550	2025-09-10 10:26:00	2025-09-10 10:26:00
977	MUHAMAD AMAN BIN MAKHZIN	770525037369	2025-09-10 10:26:00	2025-09-10 10:26:00
978	MUHAMAD B. ABD RAHMAN 	560711015715	2025-09-10 10:26:00	2025-09-10 10:26:00
979	MUHAMAD BIN KAMSAN	461205015495	2025-09-10 10:26:00	2025-09-10 10:26:00
980	MUHAMAD BIN RADIKIN	420708015289	2025-09-10 10:26:00	2025-09-10 10:26:00
981	MUHAMAD NAJIB BIN KAMARUDIN	901125015133	2025-09-10 10:26:00	2025-09-10 10:26:00
982	MUHAMAD NAZRISHAH BIN MOHD SAID 	740921016829	2025-09-10 10:26:00	2025-09-10 10:26:00
983	MUHAMAD SAIFUL AZHAR 	850626065625	2025-09-10 10:26:00	2025-09-10 10:26:00
984	MUHAMAD SHAHBUDIN BIN OSMAN	990714015921	2025-09-10 10:26:00	2025-09-10 10:26:00
985	MUHAMAD SYAKIR AKHARI  	061016010377	2025-09-10 10:26:00	2025-09-10 10:26:00
986	MUHAMAD SYAKIR BIN RAHMAT	980721016069	2025-09-10 10:26:00	2025-09-10 10:26:00
987	MUHAMAD SYAZWAN BIN SAMSUDDIN	890303065707	2025-09-10 10:26:00	2025-09-10 10:26:00
988	MUHAMAD YUSUF ALI BIN MUHAMMAD HISYAMUDDIN	230401010685	2025-09-10 10:26:00	2025-09-10 10:26:00
989	MUHAMAMD KASHFI FIQRISH 	110518011343	2025-09-10 10:26:00	2025-09-10 10:26:00
990	MUHAMAT SHAHRUDDIN BIN RASHID	821207105191	2025-09-10 10:26:00	2025-09-10 10:26:00
991	MUHAMMA RAYYAN SYHA	240903010879	2025-09-10 10:26:00	2025-09-10 10:26:00
992	MUHAMMAD A'ARIF RIFA'AT BIN MOHD RIZAL	110124140417	2025-09-10 10:26:00	2025-09-10 10:26:00
993	MUHAMMAD ABDULLAH BIN AMRAH 	890312235173	2025-09-10 10:26:00	2025-09-10 10:26:00
994	MUHAMMAD ADAM AQEEF BIN RONIHARYANTO	210815010417	2025-09-10 10:26:00	2025-09-10 10:26:00
995	MUHAMMAD ADAM DARWISH 	131026060475	2025-09-10 10:26:00	2025-09-10 10:26:00
996	MUHAMMAD AFIQ BIN ABD KARNAIN	030813100381	2025-09-10 10:26:00	2025-09-10 10:26:00
997	MUHAMMAD AL-MUBASHSYER	080221060035	2025-09-10 10:26:00	2025-09-10 10:26:00
998	MUHAMMAD AMMAR BIN MUHAMAD AMJAD	220710010591	2025-09-10 10:26:00	2025-09-10 10:26:00
999	MUHAMMAD AMMAR MICHAEL BIN NORAMIN	250813010479	2025-09-10 10:26:00	2025-09-10 10:26:00
1000	MUHAMMAD AMMAR RAYYAN	131125010545	2025-09-10 10:26:00	2025-09-10 10:26:00
1001	MUHAMMAD ANIS BIN BASIRUN	890319235387	2025-09-10 10:26:00	2025-09-10 10:26:00
1002	MUHAMMAD AQIL SUFYAN	080712011211	2025-09-10 10:26:00	2025-09-10 10:26:00
1003	MUHAMMAD ARIQ MATEEN	240904010977	2025-09-10 10:26:00	2025-09-10 10:26:00
1004	MUHAMMAD ASRAAF BIN RAHMAT	001031011269	2025-09-10 10:26:00	2025-09-10 10:26:00
1005	MUHAMMAD AZHAR BIN AZMAN	940520106381	2025-09-10 10:26:00	2025-09-10 10:26:00
1006	MUHAMMAD AZIF IZWAN 	050810011381	2025-09-10 10:26:00	2025-09-10 10:26:00
1007	MUHAMMAD AZIZ BIN MISMAN	900902015011	2025-09-10 10:26:00	2025-09-10 10:26:00
1008	MUHAMMAD AZROL IKMAL BIN KHAIRUL	080129010705	2025-09-10 10:26:00	2025-09-10 10:26:00
1009	MUHAMMAD BIN HARUN	780516016493	2025-09-10 10:26:00	2025-09-10 10:26:00
1010	MUHAMMAD BIN SHARIP	580613015701	2025-09-10 10:26:00	2025-09-10 10:26:00
1011	MUHAMMAD FAIZ 	850601016077	2025-09-10 10:26:00	2025-09-10 10:26:00
1012	MUHAMMAD FAIZ B ABD AZIZ	090102011723	2025-09-10 10:26:00	2025-09-10 10:26:00
1013	MUHAMMAD FAIZAL BIN AHMAD JOHA	830727016031	2025-09-10 10:26:00	2025-09-10 10:26:00
1014	MUHAMMAD FALIQ BIN MUHAMAD FARIS	240826010989	2025-09-10 10:26:00	2025-09-10 10:26:00
1015	MUHAMMAD FATTAHH FAHIM	190306011563	2025-09-10 10:26:00	2025-09-10 10:26:00
1016	MUHAMMAD FAWWAZ 	890105145941	2025-09-10 10:26:00	2025-09-10 10:26:00
1017	MUHAMMAD FITRI CHEN BIN ABDULLAH	600826016105	2025-09-10 10:26:00	2025-09-10 10:26:00
1018	MUHAMMAD FITRI FIRDAUS	090921011073	2025-09-10 10:26:00	2025-09-10 10:26:00
1019	MUHAMMAD FITRY SYAWAL 	170725011447	2025-09-10 10:26:00	2025-09-10 10:26:00
1020	MUHAMMAD HAIQAL BIN SYAHRIZAN 	040502140203	2025-09-10 10:26:00	2025-09-10 10:26:00
1021	MUHAMMAD HAIRUL AIMAN	011015050013	2025-09-10 10:26:00	2025-09-10 10:26:00
1022	MUHAMMAD HARIS IRFAN BIN ABDULLAH 	110702011327	2025-09-10 10:26:00	2025-09-10 10:26:00
1023	MUHAMMAD HAZIQ FARIHIN	050212010741	2025-09-10 10:26:00	2025-09-10 10:26:00
1024	MUHAMMAD HUMAM AL FATEH BIN MOHAMAD HAFIZUDDIN	240422030721	2025-09-10 10:26:00	2025-09-10 10:26:00
1025	MUHAMMAD IKHWAN AKMAL BIN GHAFFAR	050515010327	2025-09-10 10:26:00	2025-09-10 10:26:00
1026	MUHAMMAD IKMAL BIN MD SHAHROM	960911147029	2025-09-10 10:26:00	2025-09-10 10:26:00
1027	MUHAMMAD IZZAT AQWA SHAFIE	940330035733	2025-09-10 10:26:00	2025-09-10 10:26:00
1028	MUHAMMAD KHALIS BIN ABU HUSSIN	930406055281	2025-09-10 10:26:00	2025-09-10 10:26:00
1029	MUHAMMAD LUTH FATEH BIN MOHD FAZLI	241006010873	2025-09-10 10:26:00	2025-09-10 10:26:00
1030	MUHAMMAD LUTH MATEEN 	230422010713	2025-09-10 10:26:00	2025-09-10 10:26:00
1031	MUHAMMAD MUSTAQIM BIN MOHD TAJUDDIN 	970617015913	2025-09-10 10:26:00	2025-09-10 10:26:00
1032	MUHAMMAD NABIL BIN MOHD DRANIFF 	890720146081	2025-09-10 10:26:00	2025-09-10 10:26:00
1033	MUHAMMAD NOREZZUAN ABU BAKAR 	811123016491	2025-09-10 10:26:00	2025-09-10 10:26:00
1034	MUHAMMAD NUH ARYAN BIN LUKMAN HAKIM 	241024011095	2025-09-10 10:26:00	2025-09-10 10:26:00
1035	MUHAMMAD NUR IRFAN	090421010031	2025-09-10 10:26:00	2025-09-10 10:26:00
1036	MUHAMMAD NUR NAZZIM BIN IZZAR	110429011675	2025-09-10 10:26:00	2025-09-10 10:26:00
1037	MUHAMMAD QALIEFF QAIZER BIN SHAH RIZAL	121128010947	2025-09-10 10:26:00	2025-09-10 10:26:00
1038	MUHAMMAD QAYYUM QAID BIN MOHD NAZIROL	200423010021	2025-09-10 10:26:00	2025-09-10 10:26:00
1039	MUHAMMAD RAEEZ RAMADHAN 	090905011129	2025-09-10 10:26:00	2025-09-10 10:26:00
1040	MUHAMMAD RAIZ RIZQY	231007010251	2025-09-10 10:26:00	2025-09-10 10:26:00
1041	MUHAMMAD SAIFULLAH	130925011349	2025-09-10 10:26:00	2025-09-10 10:26:00
1042	MUHAMMAD SHAQIF	221009030345	2025-09-10 10:26:00	2025-09-10 10:26:00
1043	MUHAMMAD SRI BIN ABDULLAH	440430015157	2025-09-10 10:26:00	2025-09-10 10:26:00
1044	MUHAMMAD SUDER BUN SUBUR 	840118015591	2025-09-10 10:26:00	2025-09-10 10:26:00
1045	MUHAMMAD SYAFIQ BIN ABU BAKAR	861012465249	2025-09-10 10:26:00	2025-09-10 10:26:00
1046	MUHAMMAD SYAFIQ BIN SHAMSUL BAHARI	110118140285	2025-09-10 10:26:00	2025-09-10 10:26:00
1047	MUHAMMAD SYAFIQ RAYYAN	110727140563	2025-09-10 10:26:00	2025-09-10 10:26:00
1048	MUHAMMAD TURAH BIN CHULAN	660618016113	2025-09-10 10:26:00	2025-09-10 10:26:00
1049	MUHAMMAD UMAR ALI	231101011015	2025-09-10 10:26:00	2025-09-10 10:26:00
1050	MUHAMMAD UWAIS	160730040091	2025-09-10 10:26:00	2025-09-10 10:26:00
1051	MUHAMMAD ZAINUL ARIFFIN BIN NORDEN	960624045249	2025-09-10 10:26:00	2025-09-10 10:26:00
1052	MUHD SHARAFI BIN FAIDSAL ADLEE	980615875011	2025-09-10 10:26:00	2025-09-10 10:26:00
1053	MUHIZAM BIN MISKAM 	940413016757	2025-09-10 10:26:00	2025-09-10 10:26:00
1054	MUI HO CHEN	411020045203	2025-09-10 10:26:00	2025-09-10 10:26:00
1055	MULISARI BINTI ARSIL	810526715022	2025-09-10 10:26:00	2025-09-10 10:26:00
1056	MUNIAN A/L SUBRAMANIAM	590421015431	2025-09-10 10:26:00	2025-09-10 10:26:00
1057	MURAD BIN HASSAN	490504015391	2025-09-10 10:26:00	2025-09-10 10:26:00
1058	MURUGESU A/L MUNIANDY	770317055781	2025-09-10 10:26:00	2025-09-10 10:26:00
1059	MUSA BIN BULAT 	421223015169	2025-09-10 10:26:00	2025-09-10 10:26:00
1060	MUSA BIN GHAZALI	711220055603	2025-09-10 10:26:00	2025-09-10 10:26:00
1061	MUSA BIN HUSSIN	540713015673	2025-09-10 10:26:00	2025-09-10 10:26:00
1062	MUSA BIN JABI	581228016083	2025-09-10 10:26:00	2025-09-10 10:26:00
1063	MUSA BIN MAHMUD	460624015583	2025-09-10 10:26:00	2025-09-10 10:26:00
1064	MUSLIHA MOHAMAD	931215017068	2025-09-10 10:26:00	2025-09-10 10:26:00
1065	MUSTAFA BIN OTHMAN	500901015367	2025-09-10 10:26:00	2025-09-10 10:26:00
1066	MUSTAFFA BIN MOHD TA	421121015125	2025-09-10 10:26:00	2025-09-10 10:26:00
1067	MUSTAFFA MA'AROF BIN MESRAN	680420016503	2025-09-10 10:26:00	2025-09-10 10:26:00
1068	MUSTAFFA YEOP ISHAK	630110085437	2025-09-10 10:26:00	2025-09-10 10:26:00
1069	MUSTAPA BIN ABDULLAH	481120015451	2025-09-10 10:26:00	2025-09-10 10:26:00
1070	MUTHU A/L SOLAIMUTHU	631110015387	2025-09-10 10:26:00	2025-09-10 10:26:00
1071	MUZLIM B KONH	570622015761	2025-09-10 10:26:00	2025-09-10 10:26:00
1072	MUZLIM BIN KORIB	550622016565	2025-09-10 10:26:00	2025-09-10 10:26:00
1073	MYO MIN PAING	MF895977	2025-09-10 10:26:00	2025-09-10 10:26:00
1074	NABIHAH M. ABD SARI AALI HAD	900701915064	2025-09-10 10:26:00	2025-09-10 10:26:00
1075	NABILA HUDA BINTI SARUDDIN	890709235390	2025-09-10 10:26:00	2025-09-10 10:26:00
1076	NABILAH FARHANA BINTI MD HAYAT	921224015102	2025-09-10 10:26:00	2025-09-10 10:26:00
1077	NABILAH NAJIHAH	030706120686	2025-09-10 10:26:00	2025-09-10 10:26:00
1078	NADARAJAH A/L KUMARAN	551115015247	2025-09-10 10:26:00	2025-09-10 10:26:00
1079	NADZARUDDIN BIN MAHMOD	730831015989	2025-09-10 10:26:00	2025-09-10 10:26:00
1080	NAEMAH BAGONG	520205015484	2025-09-10 10:26:00	2025-09-10 10:26:00
1081	NAFISAH BINTI YAAKOB	570727017028	2025-09-10 10:26:00	2025-09-10 10:26:00
1082	NAFSIAH HASHIM	500317105662	2025-09-10 10:26:00	2025-09-10 10:26:00
1083	NAGAPPAN A/L RAMASAMY	760925016533	2025-09-10 10:26:00	2025-09-10 10:26:00
1084	NAIAMAH BT SALEH	590821015596	2025-09-10 10:26:00	2025-09-10 10:26:00
1085	NAJIHA BINTI ABU	080820011358	2025-09-10 10:26:00	2025-09-10 10:26:00
1086	NAJIHAH SYAZWANI 	960206146696	2025-09-10 10:26:00	2025-09-10 10:26:00
1087	NAJMUDIN ERBAKHAN BIN JAMIL  	941008026307	2025-09-10 10:26:00	2025-09-10 10:26:00
1088	NARAYANAN A/L MATHEW NAIR	450107015041	2025-09-10 10:26:00	2025-09-10 10:26:00
1089	NASHARUDIN BIN TAJUDIN 	921215015223	2025-09-10 10:26:00	2025-09-10 10:26:00
1090	NASIR BIN AMAT	570708017305	2025-09-10 10:26:00	2025-09-10 10:26:00
1091	NATRA BT MOHD TAHIR	660831145264	2025-09-10 10:26:00	2025-09-10 10:26:00
1092	NAVANEETAM A/P SINNASAMY 	490604015276	2025-09-10 10:26:00	2025-09-10 10:26:00
1093	NAVIN A/L ARUMUQIAM	941106016831	2025-09-10 10:26:00	2025-09-10 10:26:00
1094	NAZIPAH BT NOOR	790226035396	2025-09-10 10:26:00	2025-09-10 10:26:00
1095	NAZRIN BIN RAHMAT	961110015557	2025-09-10 10:26:00	2025-09-10 10:26:00
1096	NG AH MENG	530405016181	2025-09-10 10:26:00	2025-09-10 10:26:00
1097	NG CHEN PIOW 	670811015031	2025-09-10 10:26:00	2025-09-10 10:26:00
1098	NG CHENG PENG	690507015713	2025-09-10 10:26:00	2025-09-10 10:26:00
1099	NG CHIN CHAI	531010015103	2025-09-10 10:26:00	2025-09-10 10:26:00
1100	NG CHING TECK	571023016275	2025-09-10 10:26:00	2025-09-10 10:26:00
1101	NG ENG	480519015248	2025-09-10 10:26:00	2025-09-10 10:26:00
1102	NG KAM LAN	601123015012	2025-09-10 10:26:00	2025-09-10 10:26:00
1103	NG KIM ENG	471111015741	2025-09-10 10:26:00	2025-09-10 10:26:00
1104	NG KIM HENG	521002015737	2025-09-10 10:26:00	2025-09-10 10:26:00
1105	NG KONG	480116015323	2025-09-10 10:26:00	2025-09-10 10:26:00
1106	NG KUI FONG 	760807017316	2025-09-10 10:26:00	2025-09-10 10:26:00
1107	NG KWEE MOI	550315015706	2025-09-10 10:26:00	2025-09-10 10:26:00
1108	NG LOON BOON	550728015181	2025-09-10 10:26:00	2025-09-10 10:26:00
1109	NG MEI LI	840914016650	2025-09-10 10:26:00	2025-09-10 10:26:00
1110	NG SIEW TEE 	870720235158	2025-09-10 10:26:00	2025-09-10 10:26:00
1111	NG SING NGO	560505015618	2025-09-10 10:26:00	2025-09-10 10:26:00
1112	NG TIAN SOON	720326016557	2025-09-10 10:26:00	2025-09-10 10:26:00
1113	NG WEIJER	061118040171	2025-09-10 10:26:00	2025-09-10 10:26:00
1114	NG XI JING	911226145411	2025-09-10 10:26:00	2025-09-10 10:26:00
1115	NG YOK LIN 	480327015331	2025-09-10 10:26:00	2025-09-10 10:26:00
1116	NG ZHENG WAH	980322295013	2025-09-10 10:26:00	2025-09-10 10:26:00
1117	NGADINAH BINTI TOMIN	551127015068	2025-09-10 10:26:00	2025-09-10 10:26:00
1118	NICHOLAS THEE YEW HOCK	130830040489	2025-09-10 10:26:00	2025-09-10 10:26:00
1119	NIK FARAH HANA NIK ZAIMAN	910910035492	2025-09-10 10:26:00	2025-09-10 10:26:00
1120	NOIRMAN BIN IDRIS 	650515016381	2025-09-10 10:26:00	2025-09-10 10:26:00
1121	NOOR AIN BINTI ABD RAUF	910523065130	2025-09-10 10:26:00	2025-09-10 10:26:00
1122	NOOR AISHAH BINTI AB HAMID (20MG)	780913015400	2025-09-10 10:26:00	2025-09-10 10:26:00
1123	NOOR ATIQAH BINTI MAHMOOD	860621235620	2025-09-10 10:26:00	2025-09-10 10:26:00
1124	NOOR AZWANI BINTI MURAD	930915015296	2025-09-10 10:26:00	2025-09-10 10:26:00
1125	NOOR BAIZURA BT BORAHAN	840124015864	2025-09-10 10:26:00	2025-09-10 10:26:00
1126	NOOR FAIZAL BIN ABDUL RASHID	780208016969	2025-09-10 10:26:00	2025-09-10 10:26:00
1127	NOOR HAFEZA BINTI IBRAHIM	790418035956	2025-09-10 10:26:00	2025-09-10 10:26:00
1128	NOOR HANIZAH BT MOHD ALI	821026016384	2025-09-10 10:26:00	2025-09-10 10:26:00
1129	NOOR SIDAH BINTI YUSUF	590215085500	2025-09-10 10:26:00	2025-09-10 10:26:00
1130	NOORDIN BIN AHMAD 	611204016307	2025-09-10 10:26:00	2025-09-10 10:26:00
1131	NOORHAYATI BINTI MOHD SAHAT	811126015670	2025-09-10 10:26:00	2025-09-10 10:26:00
1132	NOORSABRINA BT M. SALBI	880204235062	2025-09-10 10:26:00	2025-09-10 10:26:00
1133	NOORSIAH BT MOHAMED	370707015678	2025-09-10 10:26:00	2025-09-10 10:26:00
1134	NOR AINIE A/P JANAH @ JAINAL	180515010226	2025-09-10 10:26:00	2025-09-10 10:26:00
1135	NOR AINUN WAHIDAH	790706065412	2025-09-10 10:26:00	2025-09-10 10:26:00
1136	NOR ANUAR BIN OBIT	710227015597	2025-09-10 10:26:00	2025-09-10 10:26:00
1137	NOR ATIQAH BINTI ABDUL RAFI	020430011278	2025-09-10 10:26:00	2025-09-10 10:26:00
1138	NOR AZLIN	840224105680	2025-09-10 10:26:00	2025-09-10 10:26:00
1139	NOR BASIRAH BT MOHD MARZUKI	911102015666	2025-09-10 10:26:00	2025-09-10 10:26:00
1140	NOR BIN MUHAMMAD 	530123015359	2025-09-10 10:26:00	2025-09-10 10:26:00
1141	NOR ELIAS BIN KAMAT	610402016485	2025-09-10 10:26:00	2025-09-10 10:26:00
1142	NOR EZRINA AIRIN (B/O ERDAWATI )	230628010110	2025-09-10 10:26:00	2025-09-10 10:26:00
1143	NOR FAZILAH BT KASMANI	880926015782	2025-09-10 10:26:00	2025-09-10 10:26:00
1144	NOR HASMAH BT MOHAMAD	880617235052	2025-09-10 10:26:00	2025-09-10 10:26:00
1145	NOR HIDAYAH BINTI SHUKOR @ ABD SYUKOR	890619015212	2025-09-10 10:26:00	2025-09-10 10:26:00
1146	NOR LIYANA BINTI AMRAN	910706016382	2025-09-10 10:26:00	2025-09-10 10:26:00
1147	NOR MARDUWATI MD YUSOFF	790812115006	2025-09-10 10:26:00	2025-09-10 10:26:00
1148	NOR NIKMAH BINTI HAMZAH	941106065668	2025-09-10 10:26:00	2025-09-10 10:26:00
1149	NOR RADILA AHMAD	920804015462	2025-09-10 10:26:00	2025-09-10 10:26:00
1150	NOR SAKILA BINTI KAPANDI	910219016588	2025-09-10 10:26:00	2025-09-10 10:26:00
1151	NOR SAKINAH BINTI RABUDIN	931015015690	2025-09-10 10:26:00	2025-09-10 10:26:00
1152	NOR SHARINA BINTI SLAMAT	920309085308	2025-09-10 10:26:00	2025-09-10 10:26:00
1153	NOR ZIANA BINTI HAMDAN	820707015972	2025-09-10 10:26:00	2025-09-10 10:26:00
1154	NORA BINTI A AZIZ	631120015604	2025-09-10 10:26:00	2025-09-10 10:26:00
1155	NORAFAERAH BINTI MAZLAN 	920406015010	2025-09-10 10:26:00	2025-09-10 10:26:00
1156	NORAIN BINTI NORIZAN	980708016662	2025-09-10 10:26:00	2025-09-10 10:26:00
1157	NORAINI BINTI SAMSUDIN	841031016440	2025-09-10 10:26:00	2025-09-10 10:26:00
1158	NORASHIDAH ABDULLAH	830703065656	2025-09-10 10:26:00	2025-09-10 10:26:00
1159	NORASIMAH BT BACIK	660722015452	2025-09-10 10:26:00	2025-09-10 10:26:00
1160	NORAZAH BINTI ABD AZIZ	791004016346	2025-09-10 10:26:00	2025-09-10 10:26:00
1161	NORAZAH ZAKARIA	950429015328	2025-09-10 10:26:00	2025-09-10 10:26:00
1162	NORAZHARIAH ABD JAMAL 	720621015690	2025-09-10 10:26:00	2025-09-10 10:26:00
1163	NORAZIDAH BT ABDUL AZIZ 	790605145392	2025-09-10 10:26:00	2025-09-10 10:26:00
1164	NORAZMINI BINTI RAMLIE	900721016226	2025-09-10 10:26:00	2025-09-10 10:26:00
1165	NORDAYANA BT MD SAN	890921235224	2025-09-10 10:26:00	2025-09-10 10:26:00
1166	NORDIANA BT SAAT	890815235108	2025-09-10 10:26:00	2025-09-10 10:26:00
1167	NORDIN BIN MAHFODZ	560216016091	2025-09-10 10:26:00	2025-09-10 10:26:00
1168	NORDIN BIN MOHD RAIS	570817055773	2025-09-10 10:26:00	2025-09-10 10:26:00
1169	NORENA KUZAI	700617015382	2025-09-10 10:26:00	2025-09-10 10:26:00
1170	NORFADZILA BINTI MOHAMAD AHSAN 	830324016088	2025-09-10 10:26:00	2025-09-10 10:26:00
1171	NORFAEZAH BINTI RUPIN	900709015888	2025-09-10 10:26:00	2025-09-10 10:26:00
1172	NORFAHMI BINTI MOHD ARIFFIN 	890409065414	2025-09-10 10:26:00	2025-09-10 10:26:00
1173	NORFAIZILA BINTI MOHAMED	870712015382	2025-09-10 10:26:00	2025-09-10 10:26:00
1174	NORFAZILAH BT AHMAD 	881231015764	2025-09-10 10:26:00	2025-09-10 10:26:00
1175	NORFERASYHIDA BINTI JASMAN	940526065678	2025-09-10 10:26:00	2025-09-10 10:26:00
1176	NORFISHAH ABDUL MAJID	690502015730	2025-09-10 10:26:00	2025-09-10 10:26:00
1177	NORHAFEZAH BINTI RAMAN	870315015856	2025-09-10 10:26:00	2025-09-10 10:26:00
1178	NORHAFIZAH BINTI RAMALI	880710015724	2025-09-10 10:26:00	2025-09-10 10:26:00
1179	NORHANANI BINTI BADROLHISHAM	861005355658	2025-09-10 10:26:00	2025-09-10 10:26:00
1180	NORHANIM BT AHMAD 	661101016668	2025-09-10 10:26:00	2025-09-10 10:26:00
1181	NORHARIRI BIN ABDULLAH OMAR	750213095043	2025-09-10 10:26:00	2025-09-10 10:26:00
1182	NORHASIKIN NORDIN	850901016108	2025-09-10 10:26:00	2025-09-10 10:26:00
1183	NORHAYATI BINTI AMBUAR	840309105938	2025-09-10 10:26:00	2025-09-10 10:26:00
1184	NORHAYATI BINTI JAAFAR	720523015064	2025-09-10 10:26:00	2025-09-10 10:26:00
1185	NORHIDAYAH BT MOHD	921114015160	2025-09-10 10:26:00	2025-09-10 10:26:00
1186	NORIAH @TNG NORIAH BINTI BACHIK	380803715286	2025-09-10 10:26:00	2025-09-10 10:26:00
1187	NORIAH BINTI ABD AZIZ	510522015462	2025-09-10 10:26:00	2025-09-10 10:26:00
1188	NORIAH BINTI IDRIS	470725015602	2025-09-10 10:26:00	2025-09-10 10:26:00
1189	NORIAH BT AHMAD 	520625015536	2025-09-10 10:26:00	2025-09-10 10:26:00
1190	NORIHAN JANTAN	641002065474	2025-09-10 10:26:00	2025-09-10 10:26:00
1191	NORISAH BINTI ABD AZIZ	581103015204	2025-09-10 10:26:00	2025-09-10 10:26:00
1192	NORISLAMILA BINTI MOHD ISMAIL	940328015266	2025-09-10 10:26:00	2025-09-10 10:26:00
1193	NORITA BINTI ABDUL MAJID	890224235050	2025-09-10 10:26:00	2025-09-10 10:26:00
1194	NORITA BINTI DAGOH	821019015690	2025-09-10 10:26:00	2025-09-10 10:26:00
1195	NORIZA BINTI AB RAHMAN	860520235170	2025-09-10 10:26:00	2025-09-10 10:26:00
1196	NORLELA BINTI MOHAMAD	781004015176	2025-09-10 10:26:00	2025-09-10 10:26:00
1197	NORLIDA BINTI ABD RAHMAN	720611016518	2025-09-10 10:26:00	2025-09-10 10:26:00
1198	NORLIYANA BINTI SAADNIN	910808065468	2025-09-10 10:26:00	2025-09-10 10:26:00
1199	NORLIZA BINTI MOHD DIN	641206015778	2025-09-10 10:26:00	2025-09-10 10:26:00
1200	NORLIZA BTE IDRIS	880623016120	2025-09-10 10:26:00	2025-09-10 10:26:00
1201	NORMAH	661209015894	2025-09-10 10:26:00	2025-09-10 10:26:00
1202	NORMAH BINTI MISLANI	590824015508	2025-09-10 10:26:00	2025-09-10 10:26:00
1203	NORMAH BINTI SANIP 	530225015472	2025-09-10 10:26:00	2025-09-10 10:26:00
1204	NORMALA BT MOHD DIN   	620501016316	2025-09-10 10:26:00	2025-09-10 10:26:00
1205	NORMAN BIN IBRAHIM	600215015701	2025-09-10 10:26:00	2025-09-10 10:26:00
1206	NORMAZIRA BINTI HASHIM MUSTAFA	810526035828	2025-09-10 10:26:00	2025-09-10 10:26:00
1207	NORNADIANA BINTI RUSLAN	960907126348	2025-09-10 10:26:00	2025-09-10 10:26:00
1208	NORPARAZILAH BINTI MD NOOR	790122045370	2025-09-10 10:26:00	2025-09-10 10:26:00
1209	NORSALWA BINTI ABU AMIN	920410065774	2025-09-10 10:26:00	2025-09-10 10:26:00
1210	NORSIAH BINTI KHALIL	610801015156	2025-09-10 10:26:00	2025-09-10 10:26:00
1211	NORSIDAH NOZARI	660925045002	2025-09-10 10:26:00	2025-09-10 10:26:00
1212	NORSURIANI BINTI OMAR	840511016226	2025-09-10 10:26:00	2025-09-10 10:26:00
1213	NORYATI BINTI AB MAJID	720804015554	2025-09-10 10:26:00	2025-09-10 10:26:00
1214	NORZAIDI BIN MD ANUAR	840623016001	2025-09-10 10:26:00	2025-09-10 10:26:00
1215	NORZAIFAH ABD RAHMAN	930226115080	2025-09-10 10:26:00	2025-09-10 10:26:00
1216	NORZAM ZAIDAR BINTI MOHD NOOR	561022055396	2025-09-10 10:26:00	2025-09-10 10:26:00
1217	NUR AAFIYAH BT IZHAN(B/O NOR HIDAYAH BINTI SAHAROM)	231120010464	2025-09-10 10:26:00	2025-09-10 10:26:00
1218	NUR AINA NATASHA	011206011340	2025-09-10 10:26:00	2025-09-10 10:26:00
1219	NUR AINAA MARSYA BINTI MUSTAFFA	050825021072	2025-09-10 10:26:00	2025-09-10 10:26:00
1220	NUR AINAA UMAIRAH	150924040090	2025-09-10 10:26:00	2025-09-10 10:26:00
1221	NUR AIRA ARISSA	131223050014	2025-09-10 10:26:00	2025-09-10 10:26:00
1222	NUR AISHAH ALYA	080423010028	2025-09-10 10:26:00	2025-09-10 10:26:00
1223	NUR AISHAH BT AHMAD KAMAL	920327045422	2025-09-10 10:26:00	2025-09-10 10:26:00
1224	NUR AISHATUL	830911016226	2025-09-10 10:26:00	2025-09-10 10:26:00
1225	NUR ALEEYA QAISARA KHAIRUL AZHAR	170423010684	2025-09-10 10:26:00	2025-09-10 10:26:00
1226	NUR ALIAA AMANI	110630010340	2025-09-10 10:26:00	2025-09-10 10:26:00
1227	NUR ALYA ADAWIYAH	190918011150	2025-09-10 10:26:00	2025-09-10 10:26:00
1228	NUR ALYA SYAKINAH 	950419017426	2025-09-10 10:26:00	2025-09-10 10:26:00
1229	NUR AMIRA NAJWAA	910530036434	2025-09-10 10:26:00	2025-09-10 10:26:00
1230	NUR ANISAH BINTI AYUB	920214025820	2025-09-10 10:26:00	2025-09-10 10:26:00
1231	NUR ASYIQIN NAJWA	100906011186	2025-09-10 10:26:00	2025-09-10 10:26:00
1232	NUR ATIKAH SENAN	991014015722	2025-09-10 10:26:00	2025-09-10 10:26:00
1233	NUR ATIQAH BINTI ABDULLAH	921226085454	2025-09-10 10:26:00	2025-09-10 10:26:00
1234	NUR ATIRAH 	000128040248	2025-09-10 10:26:00	2025-09-10 10:26:00
1235	NUR ATIRAH BT ROSHAN	011226040026	2025-09-10 10:26:00	2025-09-10 10:26:00
1236	NUR AYRAA JASMINE BINTI AHMAD AIDIL 	240701011398	2025-09-10 10:26:00	2025-09-10 10:26:00
1237	NUR AZLINI BINTI SEMAON	00621060330'	2025-09-10 10:26:00	2025-09-10 10:26:00
1238	NUR BALQIS NADZIRAH	090914010662	2025-09-10 10:26:00	2025-09-10 10:26:00
1239	NUR CAHAYA RAFANI BT FADLI	230808010556	2025-09-10 10:26:00	2025-09-10 10:26:00
1240	NUR DANIA ADLINA	040804100354	2025-09-10 10:26:00	2025-09-10 10:26:00
1241	NUR DIYANA HAZIQAH BT ABDUL HALIM	090618102204	2025-09-10 10:26:00	2025-09-10 10:26:00
1242	NUR EMINA QISTINA BINTI MOHD FAREQ	170811010256	2025-09-10 10:26:00	2025-09-10 10:26:00
1243	NUR FAIZAH BINTI ISHAK 	900223015562	2025-09-10 10:26:00	2025-09-10 10:26:00
1244	NUR FARAFISHA JANNAH	150715010362	2025-09-10 10:26:00	2025-09-10 10:26:00
1245	NUR FARAHIN BINTI ZULKAFLY	880913236244	2025-09-10 10:26:00	2025-09-10 10:26:00
1246	NUR FARESYA BINTI MOHD NADZRI	031101010534	2025-09-10 10:26:00	2025-09-10 10:26:00
1247	NUR FARZANA IZZATI BINTI AMIRRUDIN 	950813016886	2025-09-10 10:26:00	2025-09-10 10:26:00
1248	NUR FITRI AELIYANA BINTI MOHD ROSLI	061015080576	2025-09-10 10:26:00	2025-09-10 10:26:00
1249	NUR HAFIZI BIN KAMISAN	911023016089	2025-09-10 10:26:00	2025-09-10 10:26:00
1250	NUR HANIRINA ING ABDULLAH	640110015314	2025-09-10 10:26:00	2025-09-10 10:26:00
1251	NUR HANIS SHAREENA BINTI MOHAMAD ZAIRI	040802011454	2025-09-10 10:26:00	2025-09-10 10:26:00
1252	NUR HASNITA BINTI ABDUL SHUKOR 	950812015080	2025-09-10 10:26:00	2025-09-10 10:26:00
1253	NUR HAYFA RAIQAH BINTI MOHAMAD ROZAHAR	241221010550	2025-09-10 10:26:00	2025-09-10 10:26:00
1254	NUR HIDAYAH BINTI JOHARI	940307016702	2025-09-10 10:26:00	2025-09-10 10:26:00
1255	NUR LAILI BINTI MOHD KAMIL	850908015474	2025-09-10 10:26:00	2025-09-10 10:26:00
1256	NUR MARYAM BINTI MUHAMMAD FAHMI	220619011200	2025-09-10 10:26:00	2025-09-10 10:26:00
1257	NUR MIKAYLA BT ABDUL RASHID 	200720011952	2025-09-10 10:26:00	2025-09-10 10:26:00
1258	NUR NAJWA BINTI ABDULLAH	040701060716	2025-09-10 10:26:00	2025-09-10 10:26:00
1259	NUR NAZURAH MARYAM BT ROSLAN 	991106015420	2025-09-10 10:26:00	2025-09-10 10:26:00
1260	NUR RABIATUL ADAWIYAH BINTI RONAL	141120010828	2025-09-10 10:26:00	2025-09-10 10:26:00
1261	NUR SAILAH BINTI SAID	910425016474	2025-09-10 10:26:00	2025-09-10 10:26:00
1262	NUR SHAFIQAH BINTI ABDUL RASHID	040206010332	2025-09-10 10:26:00	2025-09-10 10:26:00
1263	NUR SHAZWANI BINTI ABDULLAH	060215130756	2025-09-10 10:26:00	2025-09-10 10:26:00
1264	NUR SHUHADAH BINTI SALIM	000201011364	2025-09-10 10:26:00	2025-09-10 10:26:00
1265	NUR SURFINA BINTI MOHD SHAFIQ	211230080748	2025-09-10 10:26:00	2025-09-10 10:26:00
1266	NUR SYAFIQAH BINTI BORHAN	940801145358	2025-09-10 10:26:00	2025-09-10 10:26:00
1267	NUR SYAFIQHA IZWA	900214016280	2025-09-10 10:26:00	2025-09-10 10:26:00
1268	NUR SYAHIDAH 	990706016342	2025-09-10 10:26:00	2025-09-10 10:26:00
1269	NUR ZAFFIRA BINTI NORIZAN	880707055186	2025-09-10 10:26:00	2025-09-10 10:26:00
1270	NUR ZAKIAH SUAIDAN	091008010868	2025-09-10 10:26:00	2025-09-10 10:26:00
1271	NUR ZALIHA BINTI ZAKARIA	050109030242	2025-09-10 10:26:00	2025-09-10 10:26:00
1272	NURADIBAH	890910235528	2025-09-10 10:26:00	2025-09-10 10:26:00
1273	NURAINI BINTI HASSAN 	571012016122	2025-09-10 10:26:00	2025-09-10 10:26:00
1274	NURASEKIN BINTI MOHD YUSOF	910110015768	2025-09-10 10:26:00	2025-09-10 10:26:00
1275	NURATIQAH AMIRA BINTI YUSRAN 	021208011466	2025-09-10 10:26:00	2025-09-10 10:26:00
1276	NURAZSHAHIDAH BINTI JAAFAR 	990114016576	2025-09-10 10:26:00	2025-09-10 10:26:00
1277	NURDIA QUHUMAIRAH	151222012022	2025-09-10 10:26:00	2025-09-10 10:26:00
1278	NURFARAH HANAN BINTI AHMAD SAIFUDDIN	890527086080	2025-09-10 10:26:00	2025-09-10 10:26:00
1279	NURFARAHANIS YUSOF	930208095100	2025-09-10 10:26:00	2025-09-10 10:26:00
1280	NURHABIBAH BR MOHD ZUKI	960527065782	2025-09-10 10:26:00	2025-09-10 10:26:00
1281	NURHAFIFAH BT MANISAH	990601016952	2025-09-10 10:26:00	2025-09-10 10:26:00
1282	NURHAFIQA HUSSIN 	981206016528	2025-09-10 10:26:00	2025-09-10 10:26:00
1283	NURHAZLINA BTE NORDIN	940724015970	2025-09-10 10:26:00	2025-09-10 10:26:00
1284	NURHIDAYAH ABDUL RAHMAN	990708015554	2025-09-10 10:26:00	2025-09-10 10:26:00
1285	NURHIDAYAH BT OTHMAN 	911104015942	2025-09-10 10:26:00	2025-09-10 10:26:00
1286	NURIN KAMILIA BINTI NAZIZULLAH	050926010428	2025-09-10 10:26:00	2025-09-10 10:26:00
1287	NURIZZATI MASTO	881214235204	2025-09-10 10:26:00	2025-09-10 10:26:00
1288	NURKEILYN SELINA BINTI MUDZIR	970706335054	2025-09-10 10:26:00	2025-09-10 10:26:00
1289	NURLIYANA BINTI ABD GHANI	890707146626	2025-09-10 10:26:00	2025-09-10 10:26:00
1290	NURLIYANA BINTI RAMLE	981116045026	2025-09-10 10:26:00	2025-09-10 10:26:00
1291	NURRADZIAH BINTI ABDUL RAHMAN 	860730235128	2025-09-10 10:26:00	2025-09-10 10:26:00
1292	NURSABBIHISMA BT ROSLAN	911111066084	2025-09-10 10:26:00	2025-09-10 10:26:00
1293	NURSAIMA MANIK	C0821066	2025-09-10 10:26:00	2025-09-10 10:26:00
1294	NURSHAZWANI SAMAN	010620011296	2025-09-10 10:26:00	2025-09-10 10:26:00
1295	NURSHIFA AIZURINSHAH IDHA BINTI HAMZAH	160806010818	2025-09-10 10:26:00	2025-09-10 10:26:00
1296	NURUL AIMI	960412015486	2025-09-10 10:26:00	2025-09-10 10:26:00
1297	NURUL AININ SOFIYA IBRAHIM	040902060472	2025-09-10 10:26:00	2025-09-10 10:26:00
1298	NURUL AMIRA FASHA BINTI JAMLI	240930011869	2025-09-10 10:26:00	2025-09-10 10:26:00
1299	NURUL AMIRAH NATASYA BINTI MOHD YAZID	090805010364	2025-09-10 10:26:00	2025-09-10 10:26:00
1300	NURUL ASHIKIN BINTI SAMADI	890226235118	2025-09-10 10:26:00	2025-09-10 10:26:00
1301	NURUL ATIQAH BINTI MUHAMMAD	950528015016	2025-09-10 10:26:00	2025-09-10 10:26:00
1302	NURUL ATIQAH BT ISMAIL	890627055142	2025-09-10 10:26:00	2025-09-10 10:26:00
1303	NURUL ATIRAH BT MUSA	940125015944	2025-09-10 10:26:00	2025-09-10 10:26:00
1304	NURUL FARHANA ABDULLAH 	890716065270	2025-09-10 10:26:00	2025-09-10 10:26:00
1305	NURUL FARISHA UMAIRAH	070127010614	2025-09-10 10:26:00	2025-09-10 10:26:00
1306	NURUL FARISHAH IDHA BT HAMZAH	051113010118	2025-09-10 10:26:00	2025-09-10 10:26:00
1307	NURUL HANI BINTI ABDUL HAMID	831028045372	2025-09-10 10:26:00	2025-09-10 10:26:00
1308	NURUL HIDAYAH BINTI ABDUL HALIP	831109015618	2025-09-10 10:26:00	2025-09-10 10:26:00
1309	NURUL HIDAYAH BINTI ABDUL KADIR	010904010914	2025-09-10 10:26:00	2025-09-10 10:26:00
1310	NURUL HUDA BINTI SAAD	740314085486	2025-09-10 10:26:00	2025-09-10 10:26:00
1311	NURUL HUDA BINTI ZAKARIA	050125010380	2025-09-10 10:26:00	2025-09-10 10:26:00
1312	NURUL HUDA INSYIRAH BINTI MOHD SYAFIQ AMRY	130408011244	2025-09-10 10:26:00	2025-09-10 10:26:00
1313	NURUL NAJIHA BINTI RIZUAN	060713010634	2025-09-10 10:26:00	2025-09-10 10:26:00
1314	NURUL QAYYIMAH BINTI KAMARUZZAMAN	950519015372	2025-09-10 10:26:00	2025-09-10 10:26:00
1315	NURUL RASYIQAH MIASARA	111125011320	2025-09-10 10:26:00	2025-09-10 10:26:00
1316	NURUL SHAFIQAH BINTI SAHARUDIN	921118055696	2025-09-10 10:26:00	2025-09-10 10:26:00
1317	NURUL SHEILA RAMLI	911101016368	2025-09-10 10:26:00	2025-09-10 10:26:00
1318	NURUL SYAHIDATUL AZMA BINTI ZAINAL	950413015956	2025-09-10 10:26:00	2025-09-10 10:26:00
1319	NURUL ZARA HUSNA BINTI MUHD HANAFI	151107010558	2025-09-10 10:26:00	2025-09-10 10:26:00
1320	NURULHUDA BT YAAKUB	830903015530	2025-09-10 10:26:00	2025-09-10 10:26:00
1321	NURWANI BT ISMAIL	840624016062	2025-09-10 10:26:00	2025-09-10 10:26:00
1322	NURZATIL ISMAH BINTI IBRAHIM	860508465272	2025-09-10 10:26:00	2025-09-10 10:26:00
1323	NURZAWANI BINTI ZAKARIA	960115016490	2025-09-10 10:26:00	2025-09-10 10:26:00
1324	NUTHANI A/P MATHIYALAGAN	870919055410	2025-09-10 10:26:00	2025-09-10 10:26:00
1325	NYOKE CHIN	460817105892	2025-09-10 10:26:00	2025-09-10 10:26:00
1326	OMAR BIN ABAS 	640827045369	2025-09-10 10:26:00	2025-09-10 10:26:00
1327	OMAR BIN BECHE	460913015141	2025-09-10 10:26:00	2025-09-10 10:26:00
1328	OMAR BIN HARUN	610914015435	2025-09-10 10:26:00	2025-09-10 10:26:00
1329	ON FOO YOK	461008085996	2025-09-10 10:26:00	2025-09-10 10:26:00
1330	ONG BEE GEOK	600815016150	2025-09-10 10:26:00	2025-09-10 10:26:00
1331	ONG CHAW BOO @ ONG GEOK TIN	480911015090	2025-09-10 10:26:00	2025-09-10 10:26:00
1332	ONG CHIN 	771106015637	2025-09-10 10:26:00	2025-09-10 10:26:00
1333	ONG ENG HUAT	540921015395	2025-09-10 10:26:00	2025-09-10 10:26:00
1334	ONG HUI WEN 	061007010762	2025-09-10 10:26:00	2025-09-10 10:26:00
1335	ONG KIM NEE	470615015193	2025-09-10 10:26:00	2025-09-10 10:26:00
1336	ONG MEI YUN	060825010268	2025-09-10 10:26:00	2025-09-10 10:26:00
1337	OTHMAN B ABU BAKAR	520118015005	2025-09-10 10:26:00	2025-09-10 10:26:00
1338	OTHMAN BIN ALI 	510804015823	2025-09-10 10:26:00	2025-09-10 10:26:00
1339	OTHMAN BIN AMAN	650628015879	2025-09-10 10:26:00	2025-09-10 10:26:00
1340	OTHMAN BIN BUNTAL	590519015421	2025-09-10 10:26:00	2025-09-10 10:26:00
1341	OTHMAN BIN MD DIN	811026016297	2025-09-10 10:26:00	2025-09-10 10:26:00
1342	OTHMAN BIN MOHAMED	600313015377	2025-09-10 10:26:00	2025-09-10 10:26:00
1343	OTHMAN BIN MOHD SHAH	610513015987	2025-09-10 10:26:00	2025-09-10 10:26:00
1344	OTHMAN BIN SAIAN	460316015485	2025-09-10 10:26:00	2025-09-10 10:26:00
1345	OULAGA NATHAN	631011015103	2025-09-10 10:26:00	2025-09-10 10:26:00
1346	PABAL BIN ABDULLAH	520609015587	2025-09-10 10:26:00	2025-09-10 10:26:00
1347	PACHIAPPAN A/L RAMAN	760208017111	2025-09-10 10:26:00	2025-09-10 10:26:00
1348	PADMINI A/P JEYAGOBI	911202146604	2025-09-10 10:26:00	2025-09-10 10:26:00
1349	PADZIL BIN HASRAN	540104015707	2025-09-10 10:26:00	2025-09-10 10:26:00
1350	PADZILLAH BTE A.RAHMAN	560701015586	2025-09-10 10:26:00	2025-09-10 10:26:00
1351	PAH BINTI SUNGKAI 	651019016002	2025-09-10 10:26:00	2025-09-10 10:26:00
1352	PAIMAN BIN POYENG	550324015599	2025-09-10 10:26:00	2025-09-10 10:26:00
1353	PAKIALETCHUMI A/P GANESIN	800830065600	2025-09-10 10:26:00	2025-09-10 10:26:00
1354	PANCHAVARNAM A/P MARAIPPAN 	851123065708	2025-09-10 10:26:00	2025-09-10 10:26:00
1355	PANG BOON HUA 	810709015707	2025-09-10 10:26:00	2025-09-10 10:26:00
1356	PANG CHEW MING 	740930015027	2025-09-10 10:26:00	2025-09-10 10:26:00
1357	PANG HOCK WOON	501101015443	2025-09-10 10:26:00	2025-09-10 10:26:00
1358	PANG HONG SENG	430411015179	2025-09-10 10:26:00	2025-09-10 10:26:00
1359	PANG KAIP SONG	640728015439	2025-09-10 10:26:00	2025-09-10 10:26:00
1360	PANG KIM TAT	520207015525	2025-09-10 10:26:00	2025-09-10 10:26:00
1361	PANG KOW MOI 	480217015138	2025-09-10 10:26:00	2025-09-10 10:26:00
1362	PANG LAM SENG @ PANG NAM SENG 	440817015143	2025-09-10 10:26:00	2025-09-10 10:26:00
1363	PANG SONG MOI	610909016126	2025-09-10 10:26:00	2025-09-10 10:26:00
1364	PANG TECK SIAK	590215015123	2025-09-10 10:26:00	2025-09-10 10:26:00
1365	PANG YEN ZIN	771103016140	2025-09-10 10:26:00	2025-09-10 10:26:00
1366	PATCHIAMMAL A/P VEERAPEN 	840913016800	2025-09-10 10:26:00	2025-09-10 10:26:00
1367	PATI BINTI MAAREDAN	660511016324	2025-09-10 10:26:00	2025-09-10 10:26:00
1368	PATIMAH A/P KANAN 	580208085730	2025-09-10 10:26:00	2025-09-10 10:26:00
1369	PAU KIT CHAN	650410015067	2025-09-10 10:26:00	2025-09-10 10:26:00
1370	PAUL A/L VISUVASAM	650525015227	2025-09-10 10:26:00	2025-09-10 10:26:00
1371	PAVALA RANI A/P SINNAIHA 	960306035248	2025-09-10 10:26:00	2025-09-10 10:26:00
1372	PECK YEN WEI	940711015103	2025-09-10 10:26:00	2025-09-10 10:26:00
1373	PEE KOON HWA	490325015417	2025-09-10 10:26:00	2025-09-10 10:26:00
1374	PEE XIAO YUAN	970428017426	2025-09-10 10:26:00	2025-09-10 10:26:00
1375	PERUMAL A/L GOVENDRAN	530102015501	2025-09-10 10:26:00	2025-09-10 10:26:00
1376	PERUMAL A/L KANDASAMY	440510105515	2025-09-10 10:26:00	2025-09-10 10:26:00
1377	PHOO CHEE TING	700616015647	2025-09-10 10:26:00	2025-09-10 10:26:00
1378	PHUA LEE CHU 	650215055338	2025-09-10 10:26:00	2025-09-10 10:26:00
1379	PIONG TENG KWEE @ PIONG AKAU	370716015127	2025-09-10 10:26:00	2025-09-10 10:26:00
1380	PO SWEE TIEK	661127045133	2025-09-10 10:26:00	2025-09-10 10:26:00
1381	PONOSAMY A/L RAMALINGAM	350412015289	2025-09-10 10:26:00	2025-09-10 10:26:00
1382	POO YANG KENG	530823015878	2025-09-10 10:26:00	2025-09-10 10:26:00
1383	PRAMILA A/P CHANDRA	870506235608	2025-09-10 10:26:00	2025-09-10 10:26:00
1384	PRIYADARSHINI A/P RAVINDRAN	970911017258	2025-09-10 10:26:00	2025-09-10 10:26:00
1385	PUA CHAI YIN	530419015788	2025-09-10 10:26:00	2025-09-10 10:26:00
1386	PUA WEE BENG	550708015379	2025-09-10 10:26:00	2025-09-10 10:26:00
1387	PUGANAMMAL A/P THANGARAJA	910619055578	2025-09-10 10:26:00	2025-09-10 10:26:00
1388	PUNAM BINTI PUNAM	480108045346	2025-09-10 10:26:00	2025-09-10 10:26:00
1389	PUTERI HAZIMAH QISTINA	050531011768	2025-09-10 10:26:00	2025-09-10 10:26:00
1390	PUTERI NUR ANITA	030608060106	2025-09-10 10:26:00	2025-09-10 10:26:00
1391	PUTERI NUR IRDINA BATRISYA BINTI ISMAIL	100524010620	2025-09-10 10:26:00	2025-09-10 10:26:00
1392	QUINN ARRABAELLA	250309011210	2025-09-10 10:26:00	2025-09-10 10:26:00
1393	R KARUNANEETHI A/L RAMAN 	580301015219	2025-09-10 10:26:00	2025-09-10 10:26:00
1394	R. AZMI BIN ITHNIN	640802015403	2025-09-10 10:26:00	2025-09-10 10:26:00
1395	RABA'AH BACHIK	491005015498	2025-09-10 10:26:00	2025-09-10 10:26:00
1396	RABIAH TULADIAH	511212055236	2025-09-10 10:26:00	2025-09-10 10:26:00
1397	RABI'ATUL NURA'IN	950208145882	2025-09-10 10:26:00	2025-09-10 10:26:00
1398	RADUAN BIN ABD AHMAD	660120055211	2025-09-10 10:26:00	2025-09-10 10:26:00
1399	RAFIDAH BINTI ABDUL AZIZ	810815065126	2025-09-10 10:26:00	2025-09-10 10:26:00
1400	RAFIDAH BTE MOHAMMAD 	860604235194	2025-09-10 10:26:00	2025-09-10 10:26:00
1401	RAFIEE BIN ABAS	670909015777	2025-09-10 10:26:00	2025-09-10 10:26:00
1402	RAFIK SHAIK	580731715039	2025-09-10 10:26:00	2025-09-10 10:26:00
1403	RAHIM BIN MOHD TAP	610927015151	2025-09-10 10:26:00	2025-09-10 10:26:00
1404	RAHMAN AFANDI	850419016409	2025-09-10 10:26:00	2025-09-10 10:26:00
1405	RAHMAT @ AWANG BIN LIDON	560401715505	2025-09-10 10:26:00	2025-09-10 10:26:00
1406	RAHMAT BIN MOHAMAT	560224015929	2025-09-10 10:26:00	2025-09-10 10:26:00
1407	RAIJAH BT ESLAN	650528016110	2025-09-10 10:26:00	2025-09-10 10:26:00
1408	RAJA ABD RAHIM BIN RAJA MOHAMAD	580629015183	2025-09-10 10:26:00	2025-09-10 10:26:00
1409	RAJA AINNUR DANIA 	010108011174	2025-09-10 10:26:00	2025-09-10 10:26:00
1410	RAJA MOHD FAZLEY	740525065215	2025-09-10 10:26:00	2025-09-10 10:26:00
1411	RAJA NASZAIR BIN RAJA BASOK	600608015577	2025-09-10 10:26:00	2025-09-10 10:26:00
1412	RAJA NAZARUDIN BIN RAJA BASOK 	630802015025	2025-09-10 10:26:00	2025-09-10 10:26:00
1413	RAJAA MOOKAN	790120015979	2025-09-10 10:26:00	2025-09-10 10:26:00
1414	RAJENDRAN A/L MUNISAMY	581013015673	2025-09-10 10:26:00	2025-09-10 10:26:00
1415	RAJKUMAR A/L SUBRAMANIAM	671005015517	2025-09-10 10:26:00	2025-09-10 10:26:00
1416	RAJOO A/L DURAISAMY	410703015391	2025-09-10 10:26:00	2025-09-10 10:26:00
1417	RAMAN BIN SARING	650403015165	2025-09-10 10:26:00	2025-09-10 10:26:00
1418	RAMASAMY A/L MURUGESOO	660725015781	2025-09-10 10:26:00	2025-09-10 10:26:00
1419	RAMAYEE	561111715018	2025-09-10 10:26:00	2025-09-10 10:26:00
1420	RAMLAH BINTI MAHAT	611218015866	2025-09-10 10:26:00	2025-09-10 10:26:00
1421	RAMLAN BIN TEK	481025015365	2025-09-10 10:26:00	2025-09-10 10:26:00
1422	RAMLI BIN AMAT	640706015729	2025-09-10 10:26:00	2025-09-10 10:26:00
1423	RAMLI BIN BAKRI 	540819055243	2025-09-10 10:26:00	2025-09-10 10:26:00
1424	RAMLI BIN MOHD ZIN	511007015489	2025-09-10 10:26:00	2025-09-10 10:26:00
1425	RAMLI BIN MON	590219016115	2025-09-10 10:26:00	2025-09-10 10:26:00
1426	RASHID BIN MOHD YUSUF 	490406086081	2025-09-10 10:26:00	2025-09-10 10:26:00
1427	RASIP BIN ALI	720528015134	2025-09-10 10:26:00	2025-09-10 10:26:00
1428	RASITA KHALIL	N040630011692	2025-09-10 10:26:00	2025-09-10 10:26:00
1429	RASMANEE A/P VELLU 	491005055342	2025-09-10 10:26:00	2025-09-10 10:26:00
1430	RASULIN ABU BAKAR	720126015693	2025-09-10 10:26:00	2025-09-10 10:26:00
1431	RATNA HARYANY BINTI MISLAN	931009015934	2025-09-10 10:26:00	2025-09-10 10:26:00
1432	RAZAK BIN ABD HAMID 	620909015501	2025-09-10 10:26:00	2025-09-10 10:26:00
1433	RAZAK BIN HASHIM	560908086277	2025-09-10 10:26:00	2025-09-10 10:26:00
1434	RAZALI BIN AB GHANI	480902045255	2025-09-10 10:26:00	2025-09-10 10:26:00
1435	RAZALI BIN ABD KADIR 	630901016103	2025-09-10 10:26:00	2025-09-10 10:26:00
1436	RAZALI BIN JANTAN	550503015869	2025-09-10 10:26:00	2025-09-10 10:26:00
1437	RAZALI HASHIM	590605015663	2025-09-10 10:26:00	2025-09-10 10:26:00
1438	RAZALINE 	780502015772	2025-09-10 10:26:00	2025-09-10 10:26:00
1439	RAZIDAH BINTI YUSUF	680604015134	2025-09-10 10:26:00	2025-09-10 10:26:00
1440	RAZMAN 	820607016775	2025-09-10 10:26:00	2025-09-10 10:26:00
1441	RAZMAN BIN JAMALUDIN	861110235295	2025-09-10 10:26:00	2025-09-10 10:26:00
1442	REFIAAH BINTI NAFIAH	641011015452	2025-09-10 10:26:00	2025-09-10 10:26:00
1443	REGUPAZI A/P M TANGAVLA	570929016365	2025-09-10 10:26:00	2025-09-10 10:26:00
1444	RENE B MD HASSAN	630825015095	2025-09-10 10:26:00	2025-09-10 10:26:00
1445	REVETHI	660903015742	2025-09-10 10:26:00	2025-09-10 10:26:00
1446	RIDHWAN SHAH ROJI	900206016133	2025-09-10 10:26:00	2025-09-10 10:26:00
1447	RIDZUAN BIN AL-AMIN	660909045213	2025-09-10 10:26:00	2025-09-10 10:26:00
1448	RIQA NUR FATHIYYA	150416011568	2025-09-10 10:26:00	2025-09-10 10:26:00
1449	RIZALMAN BIN HARUN	770315055729	2025-09-10 10:26:00	2025-09-10 10:26:00
1450	ROBIAH BINTI HUSSIN 	740520025986	2025-09-10 10:26:00	2025-09-10 10:26:00
1451	ROBIAH BINTI MOHD ALI	570814715000	2025-09-10 10:26:00	2025-09-10 10:26:00
1452	ROBIAH BT HUSSIN	740530025986	2025-09-10 10:26:00	2025-09-10 10:26:00
1453	ROBIAH BT KASSIM	560209015656	2025-09-10 10:26:00	2025-09-10 10:26:00
1454	ROBIAH MD ISA	580907015838	2025-09-10 10:26:00	2025-09-10 10:26:00
1455	ROBIYAH BINTI AHAMAD ZANI	541002016076	2025-09-10 10:26:00	2025-09-10 10:26:00
1456	RODIAH BINTI MD DAWI	600429045420	2025-09-10 10:26:00	2025-09-10 10:26:00
1457	RODZIAH BINTI ABDUL AZIZ @ NASIR 	710108015674	2025-09-10 10:26:00	2025-09-10 10:26:00
1458	ROGAYAH BT IBRAHIM	700325065038	2025-09-10 10:26:00	2025-09-10 10:26:00
1459	ROHANA BINTI MOHD SOM	670405015052	2025-09-10 10:26:00	2025-09-10 10:26:00
1460	ROHANI BT SERTIB 	540918015490	2025-09-10 10:26:00	2025-09-10 10:26:00
1461	ROHAYA BINTI ALI HASSAN	690406015984	2025-09-10 10:26:00	2025-09-10 10:26:00
1462	ROHIE HIDAYAT	820304015759	2025-09-10 10:26:00	2025-09-10 10:26:00
1463	ROHIM ARSHAD	611104025097	2025-09-10 10:26:00	2025-09-10 10:26:00
1464	ROHIM BIN HAMID	610703025895	2025-09-10 10:26:00	2025-09-10 10:26:00
1465	ROJI BIN AHMAD	640630015633	2025-09-10 10:26:00	2025-09-10 10:26:00
1466	ROKIAH	640519015520	2025-09-10 10:26:00	2025-09-10 10:26:00
1467	ROKIAH BINTI ABU	660819015416	2025-09-10 10:26:00	2025-09-10 10:26:00
1468	ROKIAH BINTI IDRIS 	510507015448	2025-09-10 10:26:00	2025-09-10 10:26:00
1469	ROKIAH BINTI MOHD	640613016482	2025-09-10 10:26:00	2025-09-10 10:26:00
1470	ROKIAH BINTI TAMRIN	530420015304	2025-09-10 10:26:00	2025-09-10 10:26:00
1471	ROKIAH BINTI WAN HARON	620512016290	2025-09-10 10:26:00	2025-09-10 10:26:00
1472	ROKIEAH BINTI IBRAHIM	620531015832	2025-09-10 10:26:00	2025-09-10 10:26:00
1473	RONAH BT MAMEK	570606016344	2025-09-10 10:26:00	2025-09-10 10:26:00
1474	ROSDI BIN MISRAN	450401015165	2025-09-10 10:26:00	2025-09-10 10:26:00
1475	ROSDI BIN SADELI	730314016481	2025-09-10 10:26:00	2025-09-10 10:26:00
1476	ROSDI TUQIMAN	751203015091	2025-09-10 10:26:00	2025-09-10 10:26:00
1477	ROSDINA A/P ROSLI	040326060828	2025-09-10 10:26:00	2025-09-10 10:26:00
1478	ROSE HAZWANI BINTI ZAINAL ABIDIN	920510015854	2025-09-10 10:26:00	2025-09-10 10:26:00
1479	ROSELAN B AWANG	640826015651	2025-09-10 10:26:00	2025-09-10 10:26:00
1480	ROSIAH BINTI MOHD SHAH	830921055456	2025-09-10 10:26:00	2025-09-10 10:26:00
1481	ROSIDAH GHAPAR	560705015444	2025-09-10 10:26:00	2025-09-10 10:26:00
1482	ROSLAN BIN SALLEH	670307045151	2025-09-10 10:26:00	2025-09-10 10:26:00
1483	ROSLI BIN AB WAHAB 	810829015891	2025-09-10 10:26:00	2025-09-10 10:26:00
1484	ROSLI BIN ALI	621120016093	2025-09-10 10:26:00	2025-09-10 10:26:00
1485	ROSLI BIN MAAROF	381030015177	2025-09-10 10:26:00	2025-09-10 10:26:00
1486	ROSLI BIN SABTU	761218016985	2025-09-10 10:26:00	2025-09-10 10:26:00
1487	ROSLI BIN SADELI 	680728015291	2025-09-10 10:26:00	2025-09-10 10:26:00
1488	ROSLILAH BINTI ISHAK	650224015362	2025-09-10 10:26:00	2025-09-10 10:26:00
1489	ROSLINA IBRAHIM	750224105710	2025-09-10 10:26:00	2025-09-10 10:26:00
1490	ROSLINAWATI BINTI ISMAIL	910708065508	2025-09-10 10:26:00	2025-09-10 10:26:00
1491	ROSLIZA BT AHMAD 	710115015488	2025-09-10 10:26:00	2025-09-10 10:26:00
1492	ROSMAWATY BT ZAINUDIN	860402335584	2025-09-10 10:26:00	2025-09-10 10:26:00
1493	ROSNAH BINTI SALIM	650308015634	2025-09-10 10:26:00	2025-09-10 10:26:00
1494	ROSNANI BINTI ISMAIL	750918016720	2025-09-10 10:26:00	2025-09-10 10:26:00
1495	ROSNANI BINTI MOHD SALLEH	801113035438	2025-09-10 10:26:00	2025-09-10 10:26:00
1496	ROSNANI BINTI MOHD SKAKRI	870125025834	2025-09-10 10:26:00	2025-09-10 10:26:00
1497	ROSNANI BT AHMED	771003016178	2025-09-10 10:26:00	2025-09-10 10:26:00
1498	ROSNANI MAT ALI 	771003065690	2025-09-10 10:26:00	2025-09-10 10:26:00
1499	ROSS MARIA A/P SINNAPAN	821002016582	2025-09-10 10:26:00	2025-09-10 10:26:00
1500	ROSTAM BIN SAMSUDIN	670413015247	2025-09-10 10:26:00	2025-09-10 10:26:00
1501	ROZETA BINTI ESA	580629015394	2025-09-10 10:26:00	2025-09-10 10:26:00
1502	ROZETA BINTI RAMLI	631211015028	2025-09-10 10:26:00	2025-09-10 10:26:00
1503	ROZITA BINTI SAMSURY	830331016182	2025-09-10 10:26:00	2025-09-10 10:26:00
1504	ROZNITA MOHD MUSLIM	811012015496	2025-09-10 10:26:00	2025-09-10 10:26:00
1505	RUBIAH IBRAHIM 	910714015670	2025-09-10 10:26:00	2025-09-10 10:26:00
1506	RUBIKA PILLAI A/P UMADAS	910816085434	2025-09-10 10:26:00	2025-09-10 10:26:00
1507	RUMILIYANA BINTI TUSIMAN	820811055448	2025-09-10 10:26:00	2025-09-10 10:26:00
1508	RUPIAH BINTI HUSIN	410925015282	2025-09-10 10:26:00	2025-09-10 10:26:00
1509	RUSIAH HJ TAMRIN	631118015576	2025-09-10 10:26:00	2025-09-10 10:26:00
1510	RUZITA AZLYANA SYAFIKA	020318120650	2025-09-10 10:26:00	2025-09-10 10:26:00
1511	S. LETCHUMAN  A/L D.G. PELLY  	480919105461	2025-09-10 10:26:00	2025-09-10 10:26:00
1512	S.KERESNAN A/L N.SUPPIAH	610831015245	2025-09-10 10:26:00	2025-09-10 10:26:00
1513	S.PARIMALA A/P RM SUPPIAH	600315015696	2025-09-10 10:26:00	2025-09-10 10:26:00
1514	SAAD BIN AHMAD 	481115065411	2025-09-10 10:26:00	2025-09-10 10:26:00
1515	SAÁDAHTUL ASIAH BINTI JAMUIN	900103016472	2025-09-10 10:26:00	2025-09-10 10:26:00
1516	SA'ADIAH BT LEHAM	600518016090	2025-09-10 10:26:00	2025-09-10 10:26:00
1517	SA'ADON BIN ARBAK 	630903016377	2025-09-10 10:26:00	2025-09-10 10:26:00
1518	SA'AFIE BIN AHMAD	630608015021	2025-09-10 10:26:00	2025-09-10 10:26:00
1519	SAARAH BINTI SULAN	351007055026	2025-09-10 10:26:00	2025-09-10 10:26:00
1520	SABARIAH BINTI JANTAN	910926015488	2025-09-10 10:26:00	2025-09-10 10:26:00
1521	SABARIAH BTE MOHMEDDIN	610603015016	2025-09-10 10:26:00	2025-09-10 10:26:00
1522	SABIRAH BT ALI	550913015108	2025-09-10 10:26:00	2025-09-10 10:26:00
1523	SA'DIAH BINTI SELONG	470927015846	2025-09-10 10:26:00	2025-09-10 10:26:00
1524	SA'EDIN BN MOHAMAD	401108015587	2025-09-10 10:26:00	2025-09-10 10:26:00
1525	SAFIKAH BINTI PAIROS 	960914335164	2025-09-10 10:26:00	2025-09-10 10:26:00
1526	SAFIYAH BINTI HARUN	851227095338	2025-09-10 10:26:00	2025-09-10 10:26:00
1527	SAHDAN BIN MAON	540311015005	2025-09-10 10:26:00	2025-09-10 10:26:00
1528	SAID BIN HASSAN	500626015011	2025-09-10 10:26:00	2025-09-10 10:26:00
1529	SAIFULNIZAM BIN SHAMSUL	790802015319	2025-09-10 10:26:00	2025-09-10 10:26:00
1530	SAILAH BINTI MOHD SAHAR 	700331015280	2025-09-10 10:26:00	2025-09-10 10:26:00
1531	SAIM BIN SIDEK	500912015477	2025-09-10 10:26:00	2025-09-10 10:26:00
1532	SAIPUNIZAN BIN SURIP	800727015947	2025-09-10 10:26:00	2025-09-10 10:26:00
1533	SAKINAH BT MAHMUD 	420702035306	2025-09-10 10:26:00	2025-09-10 10:26:00
1534	SALASIAH BT ABDULLAH	550115085806	2025-09-10 10:26:00	2025-09-10 10:26:00
1535	SALEH BIN A. RAHMAN	410531015247	2025-09-10 10:26:00	2025-09-10 10:26:00
1536	SALEHA BINTI PALANCHOI	521228015596	2025-09-10 10:26:00	2025-09-10 10:26:00
1537	SALEHAN TUKIRAN	481104015515	2025-09-10 10:26:00	2025-09-10 10:26:00
1538	SALIHA BT ITHNIN	711114016248	2025-09-10 10:26:00	2025-09-10 10:26:00
1539	SALIM BIN SURIB	500120015751	2025-09-10 10:26:00	2025-09-10 10:26:00
1540	SALIM BIN YUSOF	520226015213	2025-09-10 10:26:00	2025-09-10 10:26:00
1541	SALIPAH @ BALIPAH BINTI ABD RAHMAN\t	510224015456	2025-09-10 10:26:00	2025-09-10 10:26:00
1542	SALLEH BIN ABDUL MALEK	500614715299	2025-09-10 10:26:00	2025-09-10 10:26:00
1543	SALMAH BINTI ADNAN	600420015874	2025-09-10 10:26:00	2025-09-10 10:26:00
1544	SALMAH BINTI YAACOB	770106016870	2025-09-10 10:26:00	2025-09-10 10:26:00
1545	SALMAH BT AHMAD 	610424016566	2025-09-10 10:26:00	2025-09-10 10:26:00
1546	SALMAH KASIM	820621015402	2025-09-10 10:26:00	2025-09-10 10:26:00
1547	SALMI BINTI SOBANI	810311015678	2025-09-10 10:26:00	2025-09-10 10:26:00
1548	SALZALEEY BIN AYUB	650904016377	2025-09-10 10:26:00	2025-09-10 10:26:00
1549	SAMAD BIN YUSOF	460523015533	2025-09-10 10:26:00	2025-09-10 10:26:00
1550	SAMIJO BIN HARON 	451213015285	2025-09-10 10:26:00	2025-09-10 10:26:00
1551	SAMINATHAN@SINGARAM A/L RAMAIAH	480328715065	2025-09-10 10:26:00	2025-09-10 10:26:00
1552	SAMSIAH BINTI ABU ZAHID	480706085276	2025-09-10 10:26:00	2025-09-10 10:26:00
1553	SAMSOL BIN KHAMIS 	710807015147	2025-09-10 10:26:00	2025-09-10 10:26:00
1554	SAMSUDIN ABDUL RAHMAN	620321065399	2025-09-10 10:26:00	2025-09-10 10:26:00
1555	SAMSUDIN BIN HASSAN 	360603015201	2025-09-10 10:26:00	2025-09-10 10:26:00
1556	SAMSUDIN BIN KHAMIS	691114015741	2025-09-10 10:26:00	2025-09-10 10:26:00
1557	SAMSUDIN ISMAIL	580715015665	2025-09-10 10:26:00	2025-09-10 10:26:00
1558	SANGAR A/L APLAHIDU	790704025863	2025-09-10 10:26:00	2025-09-10 10:26:00
1559	SANJANAATHEVI A/P KUMAR	101022011636	2025-09-10 10:26:00	2025-09-10 10:26:00
1560	SAPIEAN BIN JAFFAR	670311015035	2025-09-10 10:26:00	2025-09-10 10:26:00
1561	SAPRAH BINTI SILOM	580530105736	2025-09-10 10:26:00	2025-09-10 10:26:00
1562	SARASWATHI A/P BATUMALAI 	910827017066	2025-09-10 10:26:00	2025-09-10 10:26:00
1563	SARASWATHI A/P RENGANATHAN	510103015222	2025-09-10 10:26:00	2025-09-10 10:26:00
1564	SARASWATHY	710505055354	2025-09-10 10:26:00	2025-09-10 10:26:00
1565	SARASWATHY A/P THENANAM	790907105978	2025-09-10 10:26:00	2025-09-10 10:26:00
1566	SARATHA DEVI SUBRAMANIAM	630104108312	2025-09-10 10:26:00	2025-09-10 10:26:00
1567	SARINAH BINTI JUANY 	780201016608	2025-09-10 10:26:00	2025-09-10 10:26:00
1568	SARTIAH BINTI SARBINI	540720015874	2025-09-10 10:26:00	2025-09-10 10:26:00
1569	SATHIYA PRIYA A/P P. RAJA RATNAM	790719015836	2025-09-10 10:26:00	2025-09-10 10:26:00
1570	SATIAM BT WAGIMAN	280520015062	2025-09-10 10:26:00	2025-09-10 10:26:00
1571	SATIAVANI A/P MUNIAN	740103086884	2025-09-10 10:26:00	2025-09-10 10:26:00
1572	SAU CHENG	400815015362	2025-09-10 10:26:00	2025-09-10 10:26:00
1573	SAUDAH BINTI MAHAT	570712016874	2025-09-10 10:26:00	2025-09-10 10:26:00
1574	SAUDAH BT ABDULLAH	581007025584	2025-09-10 10:26:00	2025-09-10 10:26:00
1575	SAUDAH BT MOHAMED DAUD 	601124105482	2025-09-10 10:26:00	2025-09-10 10:26:00
1576	SAW THEAN EE	710722075511	2025-09-10 10:26:00	2025-09-10 10:26:00
1577	SEE BON CHUAN	480312015013	2025-09-10 10:26:00	2025-09-10 10:26:00
1578	SEE CHEE MING	571218015061	2025-09-10 10:26:00	2025-09-10 10:26:00
1579	SEE KAI THONG	631228015323	2025-09-10 10:26:00	2025-09-10 10:26:00
1580	SELA ZAEE BT PETRUS	880112125210	2025-09-10 10:26:00	2025-09-10 10:26:00
1581	SELAMAH BINTI ABD RAHMAN	611218015284	2025-09-10 10:26:00	2025-09-10 10:26:00
1582	SELAMAT BIN PAID	591211016203	2025-09-10 10:26:00	2025-09-10 10:26:00
1583	SELMAH BIN NASIR	590513016386	2025-09-10 10:26:00	2025-09-10 10:26:00
1584	SELVAN KRISHNAN	570926015447	2025-09-10 10:26:00	2025-09-10 10:26:00
1585	SEN YI YUN	930523045074	2025-09-10 10:26:00	2025-09-10 10:26:00
1586	SENASI PAIDITHALLY 	441028015073	2025-09-10 10:26:00	2025-09-10 10:26:00
1587	SENAWI KASIM	450508025179	2025-09-10 10:26:00	2025-09-10 10:26:00
1588	SENIN BIN MAMIN	530119015217	2025-09-10 10:26:00	2025-09-10 10:26:00
1589	SEOW HUI EN	050805100320	2025-09-10 10:26:00	2025-09-10 10:26:00
1590	SER AH TEE 	560217015867	2025-09-10 10:26:00	2025-09-10 10:26:00
1591	SERENA SOON HWEI SZE	900416015016	2025-09-10 10:26:00	2025-09-10 10:26:00
1592	SERINAM MAT KARON	460127105238	2025-09-10 10:26:00	2025-09-10 10:26:00
1593	SET AH KOW	370306715067	2025-09-10 10:26:00	2025-09-10 10:26:00
1594	SEVAMARI A/P N PILLAI	400116085062	2025-09-10 10:26:00	2025-09-10 10:26:00
1595	SHA SAALIZA MOHD SAID	850529016338	2025-09-10 10:26:00	2025-09-10 10:26:00
1596	SHAARI BIN ISMAIL 	390223025325	2025-09-10 10:26:00	2025-09-10 10:26:00
1597	SHAFEE @ SHAFFIE BIN A RAHMAN	440814035341	2025-09-10 10:26:00	2025-09-10 10:26:00
1598	SHAFEIN BIN ALIB	600310016067	2025-09-10 10:26:00	2025-09-10 10:26:00
1600	SHAHIRAH BINTI MOHAMAD YUNOS	930521015314	2025-09-10 10:26:00	2025-09-10 10:26:00
1601	SHAHRIZATUL AZLINA BT SHARUDIN	050420011140	2025-09-10 10:26:00	2025-09-10 10:26:00
1602	SHAIDAH MAHAMOOD	540418035444	2025-09-10 10:26:00	2025-09-10 10:26:00
1603	SHAM GEOK CHAN	511025015052	2025-09-10 10:26:00	2025-09-10 10:26:00
1604	SHAMINEEY A/P KRISHA RAO	900521085382	2025-09-10 10:26:00	2025-09-10 10:26:00
1605	SHAMSUDDIN BIN HASSAN 	621129045413	2025-09-10 10:26:00	2025-09-10 10:26:00
1606	SHAMSUDIN BIN ANI	600725015517	2025-09-10 10:26:00	2025-09-10 10:26:00
1607	SHAMSUL AMRI BIN SULAIMAN	031202040337	2025-09-10 10:26:00	2025-09-10 10:26:00
1608	SHAMSURIZAL	720115045299	2025-09-10 10:26:00	2025-09-10 10:26:00
1609	SHANTHA KUMARI A/P A.K.NAIR	511109055000	2025-09-10 10:26:00	2025-09-10 10:26:00
1610	SHARIBAH YUSUF	551016015882	2025-09-10 10:26:00	2025-09-10 10:26:00
1611	SHARIFAH AMIRAH BINTI SYED AMRAN	891024235464	2025-09-10 10:26:00	2025-09-10 10:26:00
1612	SHARIFAH BINTI SHINA	630411065340	2025-09-10 10:26:00	2025-09-10 10:26:00
1613	SHARIFAH BT WAHIT 	580719045028	2025-09-10 10:26:00	2025-09-10 10:26:00
1614	SHARIFAH HUSSIN	721202715160	2025-09-10 10:26:00	2025-09-10 10:26:00
1615	SHARIFAH ROSNAH BT SYED ABDULLAH	530426015866	2025-09-10 10:26:00	2025-09-10 10:26:00
1616	SHARIL BIN ABDULLAH	951110065635	2025-09-10 10:26:00	2025-09-10 10:26:00
1617	SHARIR BIN SIMAIL	470408015385	2025-09-10 10:26:00	2025-09-10 10:26:00
1618	SHARONIZA BINTI SHAIDIN 	870822086384	2025-09-10 10:26:00	2025-09-10 10:26:00
1619	SHARVINI A/P MURUGAN     	010109040364	2025-09-10 10:26:00	2025-09-10 10:26:00
1620	SHASHA IDAYU 	060808012018	2025-09-10 10:26:00	2025-09-10 10:26:00
1621	SHE ZHONG XUAN	030723010999	2025-09-10 10:26:00	2025-09-10 10:26:00
1622	SHEE KIM KHUAN	700113015047	2025-09-10 10:26:00	2025-09-10 10:26:00
1623	SHUM YOKE LING	841007085024	2025-09-10 10:26:00	2025-09-10 10:26:00
1624	SIA YU	580203105958	2025-09-10 10:26:00	2025-09-10 10:26:00
1625	SIALOS BINTI UDA	511025015220	2025-09-10 10:26:00	2025-09-10 10:26:00
1626	SIMBOK BT ACHIN	500723065264	2025-09-10 10:26:00	2025-09-10 10:26:00
1627	SIRINA BINTI SIDIN	470110715178	2025-09-10 10:26:00	2025-09-10 10:26:00
1628	SITI AISHAH ABDUL WAHAB	460102015228	2025-09-10 10:26:00	2025-09-10 10:26:00
1629	SITI AISHAH BINTI MOHD TAHIR 	011129011856	2025-09-10 10:26:00	2025-09-10 10:26:00
1630	SITI AISHAH BINTI TAPIT	811207065442	2025-09-10 10:26:00	2025-09-10 10:26:00
1631	SITI ASAH @ SITI AISAH BINTI NONG 	540608015444	2025-09-10 10:26:00	2025-09-10 10:26:00
1632	SITI AYUSAFURA BINTI MUZAMIL	851222055388	2025-09-10 10:26:00	2025-09-10 10:26:00
1633	SITI FATIMAH BINTI ISMAIL	921103016272	2025-09-10 10:26:00	2025-09-10 10:26:00
1634	SITI FATIMAH BINTI MD TOP 	610522015436	2025-09-10 10:26:00	2025-09-10 10:26:00
1635	SITI HAJAR BT MD GHAZALI	950119025168	2025-09-10 10:26:00	2025-09-10 10:26:00
1636	SITI HAJARUL FAIRUZ BINTI AZAMI	940427025638	2025-09-10 10:26:00	2025-09-10 10:26:00
1637	SITI HASLINDA BITNI HALIM	900211016648	2025-09-10 10:26:00	2025-09-10 10:26:00
1638	SITI HASMAH BINTI ISHAK 	890711015506	2025-09-10 10:26:00	2025-09-10 10:26:00
1639	SITI HAZIRAH HAZWANI	890209065428	2025-09-10 10:26:00	2025-09-10 10:26:00
1640	SITI HUSNA BINTI HAZILIN	010308010512	2025-09-10 10:26:00	2025-09-10 10:26:00
1641	SITI INDAHAN BINTI ASMAT 	580127015140	2025-09-10 10:26:00	2025-09-10 10:26:00
1642	SITI JAMALIAH ABD JAMIL	531025015798	2025-09-10 10:26:00	2025-09-10 10:26:00
1643	SITI JULIANA BT MD SUBOH 	830506015756	2025-09-10 10:26:00	2025-09-10 10:26:00
1644	SITI KHADIJAH MD SALLEH	580207045024	2025-09-10 10:26:00	2025-09-10 10:26:00
1645	SITI MAIMUNAH ISMAL 	720918055132	2025-09-10 10:26:00	2025-09-10 10:26:00
1646	SITI MASAZURAWATI BINTI MASERI 	830817016318	2025-09-10 10:26:00	2025-09-10 10:26:00
1647	SITI MASNIZAWATI 	870124035168	2025-09-10 10:26:00	2025-09-10 10:26:00
1648	SITI NADZIRAH BT RAMLEE	880722015764	2025-09-10 10:26:00	2025-09-10 10:26:00
1649	SITI NAZIHAH BINTI MOHD ZAIN	970113015346	2025-09-10 10:26:00	2025-09-10 10:26:00
1650	SITI NOOR HIYAH BINTI ESA	880115235220	2025-09-10 10:26:00	2025-09-10 10:26:00
1651	SITI NOORAIZAH BT AHMAD	670428086216	2025-09-10 10:26:00	2025-09-10 10:26:00
1652	SITI NOORNABILA NASUHA BINTI MAZLAN	981002115196	2025-09-10 10:26:00	2025-09-10 10:26:00
1653	SITI NOR KHADIJAH BT ALI HUSSIN 	890811235012	2025-09-10 10:26:00	2025-09-10 10:26:00
1654	SITI NORAIN BINTI ROSLI	890606295008	2025-09-10 10:26:00	2025-09-10 10:26:00
1655	SITI NORAISHAH	950407015570	2025-09-10 10:26:00	2025-09-10 10:26:00
1656	SITI NORAISHAH BINTI MD ISA	751004055234	2025-09-10 10:26:00	2025-09-10 10:26:00
1657	SITI NORAISHAH BT MOHD ARIFIN 	941129035664	2025-09-10 10:26:00	2025-09-10 10:26:00
1658	SITI NORLAILA ABD SAMAD	780228015656	2025-09-10 10:26:00	2025-09-10 10:26:00
1659	SITI NUR AISHAH	870210015040	2025-09-10 10:26:00	2025-09-10 10:26:00
1660	SITI NUR AMIRA	990808015164	2025-09-10 10:26:00	2025-09-10 10:26:00
1661	SITI NUR FATHIHA	970902015314	2025-09-10 10:26:00	2025-09-10 10:26:00
1662	SITI NUR FATIHAH	011102011354	2025-09-10 10:26:00	2025-09-10 10:26:00
1663	SITI NUR SYAHMAH ABD MALEK	040620130508	2025-09-10 10:26:00	2025-09-10 10:26:00
1664	SITI NURAISHAH BT MUSTAN	980810016570	2025-09-10 10:26:00	2025-09-10 10:26:00
1665	SITI NURBAYZURAH BINTI AMRAN 	851116015542	2025-09-10 10:26:00	2025-09-10 10:26:00
1666	SITI NURUL IZATI BINTI KAMISAN	971125017634	2025-09-10 10:26:00	2025-09-10 10:26:00
1667	SITI RAMIZAN SHAIKH HUSSIN	670101115900	2025-09-10 10:26:00	2025-09-10 10:26:00
1668	SITI ROHANI BINTI OSMAN	801130025696	2025-09-10 10:26:00	2025-09-10 10:26:00
1669	SITI SABARIYAH MAT ZIN	880912115088	2025-09-10 10:26:00	2025-09-10 10:26:00
1670	SITI SAHARA BTE ABU BAKAR	720925015796	2025-09-10 10:26:00	2025-09-10 10:26:00
1671	SITI SAHARIAH ABDUL AZIZ	770628105504	2025-09-10 10:26:00	2025-09-10 10:26:00
1672	SITI SALINA BINTI JAFRI	860609015078	2025-09-10 10:26:00	2025-09-10 10:26:00
1673	SITI SURAYA BINTI MOHD ROSLAN 	830228016168	2025-09-10 10:26:00	2025-09-10 10:26:00
1674	SITI SYAZWANI BINTI JAAFAR 	941009015968	2025-09-10 10:26:00	2025-09-10 10:26:00
1675	SITI SYUHADA 	930905875030	2025-09-10 10:26:00	2025-09-10 10:26:00
1676	SITI ZAINAB BINTI IBRAHIM	610301015010	2025-09-10 10:26:00	2025-09-10 10:26:00
1677	SIVABALAN A/L SETU	730226145101	2025-09-10 10:26:00	2025-09-10 10:26:00
1678	SIVARAJA @SELVARAJA A/L KALIMUTHU 	521009015123	2025-09-10 10:26:00	2025-09-10 10:26:00
1679	SO YENG TI @ SOO YONG TEE	510618015299	2025-09-10 10:26:00	2025-09-10 10:26:00
1680	SOH BEE GEOK	691123015532	2025-09-10 10:26:00	2025-09-10 10:26:00
1681	SOH HAI CHOO	550403015466	2025-09-10 10:26:00	2025-09-10 10:26:00
1682	SOH TAI TEE	771012016284	2025-09-10 10:26:00	2025-09-10 10:26:00
1683	SOLEHA AZWA 	880101015534	2025-09-10 10:26:00	2025-09-10 10:26:00
1684	SOLOMON A/L SUBRAMAN	510120015283	2025-09-10 10:26:00	2025-09-10 10:26:00
1685	SONG SAM MOY	491011015072	2025-09-10 10:26:00	2025-09-10 10:26:00
1686	SOPHIAN BIN MOHD SAID	731013055203	2025-09-10 10:26:00	2025-09-10 10:26:00
1687	SOPIAH BINTI RAMLI	691029025080	2025-09-10 10:26:00	2025-09-10 10:26:00
1688	SRI MUGASUMAN A/L RASAN	820811016529	2025-09-10 10:26:00	2025-09-10 10:26:00
1689	STEVE PANG WEI FONG 	111025102911	2025-09-10 10:26:00	2025-09-10 10:26:00
1690	SUA AI LIN 	010901010898	2025-09-10 10:26:00	2025-09-10 10:26:00
1691	SUBRAMANIAM 	590326055291	2025-09-10 10:26:00	2025-09-10 10:26:00
1692	SUHAILA BINTI OTHMAN	751004016868	2025-09-10 10:26:00	2025-09-10 10:26:00
1693	SUHAIMI BIN MOHD SUJAK 	740416015729	2025-09-10 10:26:00	2025-09-10 10:26:00
1694	SUHAIMI BIN ZULKEPPLY	700309015153	2025-09-10 10:26:00	2025-09-10 10:26:00
1695	SUHILAWATI	800611115444	2025-09-10 10:26:00	2025-09-10 10:26:00
1696	SUHOR B MARTO	510828015465	2025-09-10 10:26:00	2025-09-10 10:26:00
1697	SUKAIMY B MD ARSAD	530903015587	2025-09-10 10:26:00	2025-09-10 10:26:00
1698	SUKI BIN YUSOF	520502016299	2025-09-10 10:26:00	2025-09-10 10:26:00
1699	SUKOR BIN AHMAD	531026015781	2025-09-10 10:26:00	2025-09-10 10:26:00
1700	SUKUMARAN A/L NADASON 	600830015703	2025-09-10 10:26:00	2025-09-10 10:26:00
1701	SULAIMAN BIN ABBAS	520601015697	2025-09-10 10:26:00	2025-09-10 10:26:00
1702	SULAIMAN BIN OMAR	501002025339	2025-09-10 10:26:00	2025-09-10 10:26:00
1703	SULAIMAN BIN SIDEK	410716015067	2025-09-10 10:26:00	2025-09-10 10:26:00
1704	SULEIMAN @ SULIAMAN BIN AHMAD	511026016161	2025-09-10 10:26:00	2025-09-10 10:26:00
1705	SUMANGALI A/P MOHAN 	840307015648	2025-09-10 10:26:00	2025-09-10 10:26:00
1706	SUMARNI BINTI JAAFAR	590501015378	2025-09-10 10:26:00	2025-09-10 10:26:00
1707	SUMATHI BIN SUFAR	500505015875	2025-09-10 10:26:00	2025-09-10 10:26:00
1708	SUMIATI SUBRADO	861117385202	2025-09-10 10:26:00	2025-09-10 10:26:00
1709	SUN BINTI SALLEH	340504015072	2025-09-10 10:26:00	2025-09-10 10:26:00
1710	SUNIZA BINTI CHE MD SUKRAN	880727295152	2025-09-10 10:26:00	2025-09-10 10:26:00
1711	SUPIAH BINTI JURAIMI	860107015596	2025-09-10 10:26:00	2025-09-10 10:26:00
1712	SUPIAH BT KARMO	380309015030	2025-09-10 10:26:00	2025-09-10 10:26:00
1713	SURIAN BIN SUMIDIN	590811045345	2025-09-10 10:26:00	2025-09-10 10:26:00
1714	SURIATI BINTI MAHADI\t	821111146474	2025-09-10 10:26:00	2025-09-10 10:26:00
1715	SURIDAH BINTI AHMAD 	640614015000	2025-09-10 10:26:00	2025-09-10 10:26:00
1716	SURYAZIEHAN ZAID	820723015366	2025-09-10 10:26:00	2025-09-10 10:26:00
1717	SUZANA MADIN	870125065326	2025-09-10 10:26:00	2025-09-10 10:26:00
1718	SUZEYANA BINTI MD PERANG	840926016420	2025-09-10 10:26:00	2025-09-10 10:26:00
1719	SUZLIANA	660102018070	2025-09-10 10:26:00	2025-09-10 10:26:00
1720	SYAFIL BIN LAWRENCE	951028125467	2025-09-10 10:26:00	2025-09-10 10:26:00
1721	SYAHRIL AQMAL BIN SHAHRUL NADLI	020323100419	2025-09-10 10:26:00	2025-09-10 10:26:00
1722	SYAIFUL AZLI BIN MUHAMAD	801013085163	2025-09-10 10:26:00	2025-09-10 10:26:00
1723	SYED HISHAHUDDIEN	790722065199	2025-09-10 10:26:00	2025-09-10 10:26:00
1724	SYED MOHD AZIZ BIN TK HARUN	640117065509	2025-09-10 10:26:00	2025-09-10 10:26:00
1725	TAIB BIN HASHIM 	780428015941	2025-09-10 10:26:00	2025-09-10 10:26:00
1726	TALIB BIN GADOH	400905015091	2025-09-10 10:26:00	2025-09-10 10:26:00
1727	TAM KAN MEE	541203015512	2025-09-10 10:26:00	2025-09-10 10:26:00
1728	TAN AH CHOO	491025055366	2025-09-10 10:26:00	2025-09-10 10:26:00
1729	TAN AH FOH	420105015497	2025-09-10 10:26:00	2025-09-10 10:26:00
1730	TAN AH KEW @ TUAN KOOK FOOK	440217015115	2025-09-10 10:26:00	2025-09-10 10:26:00
1731	TAN AH LAI	510514015569	2025-09-10 10:26:00	2025-09-10 10:26:00
1732	TAN AH LEK	500414015749	2025-09-10 10:26:00	2025-09-10 10:26:00
1733	TAN CHEE KIAT	990901015599	2025-09-10 10:26:00	2025-09-10 10:26:00
1734	TAN CHEE SIONG	571221015951	2025-09-10 10:26:00	2025-09-10 10:26:00
1735	TAN CHEW LIN	690330015506	2025-09-10 10:26:00	2025-09-10 10:26:00
1736	TAN CHI LING	940208015122	2025-09-10 10:26:00	2025-09-10 10:26:00
1737	TAN CHIN HU 	730312016031	2025-09-10 10:26:00	2025-09-10 10:26:00
1738	TAN CHIN YOONG	540502015139	2025-09-10 10:26:00	2025-09-10 10:26:00
1739	TAN CHOI TENG	421127015249	2025-09-10 10:26:00	2025-09-10 10:26:00
1740	TAN CHOR KEN     	480903715011	2025-09-10 10:26:00	2025-09-10 10:26:00
1741	TAN ENG SIANG	380811015351	2025-09-10 10:26:00	2025-09-10 10:26:00
1742	TAN FEI SAN	940211015190	2025-09-10 10:26:00	2025-09-10 10:26:00
1743	TAN IE @ TAN TEE	491031045148	2025-09-10 10:26:00	2025-09-10 10:26:00
1744	TAN JEN ERN	840220015427	2025-09-10 10:26:00	2025-09-10 10:26:00
1745	TAN KAH HOAN	371201015042	2025-09-10 10:26:00	2025-09-10 10:26:00
1746	TAN KAI MENG	890206235153	2025-09-10 10:26:00	2025-09-10 10:26:00
1747	TAN KANG SAN	730816016385	2025-09-10 10:26:00	2025-09-10 10:26:00
1748	TAN KIM @ TAN CHING KEAK	340208015203	2025-09-10 10:26:00	2025-09-10 10:26:00
1749	TAN KIM HUA	490804105268	2025-09-10 10:26:00	2025-09-10 10:26:00
1750	TAN KOK CHOO	551231015164	2025-09-10 10:26:00	2025-09-10 10:26:00
1751	TAN KOK KEONG 	760201016415	2025-09-10 10:26:00	2025-09-10 10:26:00
1752	TAN KONG MENG	590120015833	2025-09-10 10:26:00	2025-09-10 10:26:00
1753	TAN LAM JOO	620312015461	2025-09-10 10:26:00	2025-09-10 10:26:00
1754	TAN LEH CHU	660214015840	2025-09-10 10:26:00	2025-09-10 10:26:00
1755	TAN LU NEE	070730011494	2025-09-10 10:26:00	2025-09-10 10:26:00
1756	TAN MEE HWA	650619015826	2025-09-10 10:26:00	2025-09-10 10:26:00
1757	TAN PING YEE	901118145378	2025-09-10 10:26:00	2025-09-10 10:26:00
1758	TAN POI CHEE	461205015065	2025-09-10 10:26:00	2025-09-10 10:26:00
1759	TAN SENG GUAN	540515015277	2025-09-10 10:26:00	2025-09-10 10:26:00
1760	TAN SEW MAN	440112015012	2025-09-10 10:26:00	2025-09-10 10:26:00
1761	TAN SHU MEI	960518015396	2025-09-10 10:26:00	2025-09-10 10:26:00
1762	TAN SIEW HIANG	610523025214	2025-09-10 10:26:00	2025-09-10 10:26:00
1763	TAN SIEW LUAN 	420716015330	2025-09-10 10:26:00	2025-09-10 10:26:00
1764	TAN SIN POW	310731015147	2025-09-10 10:26:00	2025-09-10 10:26:00
1765	TAN SIOK KIOW	650422055082	2025-09-10 10:26:00	2025-09-10 10:26:00
1766	TAN SIU WAH	481015015310	2025-09-10 10:26:00	2025-09-10 10:26:00
1767	TAN SU SUAN	391023045043	2025-09-10 10:26:00	2025-09-10 10:26:00
1768	TAN TECK MING	090627140915	2025-09-10 10:26:00	2025-09-10 10:26:00
1769	TAN TIAN HAI	701222015411	2025-09-10 10:26:00	2025-09-10 10:26:00
1770	TAN TICK HAU	550228015337	2025-09-10 10:26:00	2025-09-10 10:26:00
1771	TAN YEAN NEE	880416235144	2025-09-10 10:26:00	2025-09-10 10:26:00
1772	TAN YUN SUN	500710045213	2025-09-10 10:26:00	2025-09-10 10:26:00
1773	TANG ENG KIAT	440409105545	2025-09-10 10:26:00	2025-09-10 10:26:00
1774	TAY BEE LENG 	520729015696	2025-09-10 10:26:00	2025-09-10 10:26:00
1775	TAY BOON HOO	530721016239	2025-09-10 10:26:00	2025-09-10 10:26:00
1776	TAY CHI SENG	900423015807	2025-09-10 10:26:00	2025-09-10 10:26:00
1777	TAY CHYE	500415015329	2025-09-10 10:26:00	2025-09-10 10:26:00
1778	TAY SAY KEI 	520415015175	2025-09-10 10:26:00	2025-09-10 10:26:00
1779	TAY SHIA LING	790413015710	2025-09-10 10:26:00	2025-09-10 10:26:00
1780	TAY SIAK YONG @ TEE WAN	480308015133	2025-09-10 10:26:00	2025-09-10 10:26:00
1781	TAY TECH CHUAN	620614015029	2025-09-10 10:26:00	2025-09-10 10:26:00
1782	TAY YI WEN 	991020045020	2025-09-10 10:26:00	2025-09-10 10:26:00
1783	TEE AH BEE	491024015303	2025-09-10 10:26:00	2025-09-10 10:26:00
1784	TEE AH SOON	530607015371	2025-09-10 10:26:00	2025-09-10 10:26:00
1785	TEE BOON KEE	540114016041	2025-09-10 10:26:00	2025-09-10 10:26:00
1786	TEE BOON KIAN	571003016243	2025-09-10 10:26:00	2025-09-10 10:26:00
1787	TEE HUI KEE	910619015736	2025-09-10 10:26:00	2025-09-10 10:26:00
1788	TEE KIM KEE	500303015279	2025-09-10 10:26:00	2025-09-10 10:26:00
1789	TEE LEE SHI	010609010022	2025-09-10 10:26:00	2025-09-10 10:26:00
1790	TEE TEONG TENG @ TEY TEONG TENG	480530015409	2025-09-10 10:26:00	2025-09-10 10:26:00
1791	TEE XIN HUI 	050723010946	2025-09-10 10:26:00	2025-09-10 10:26:00
1792	TEE YOK HUA 	520918045376	2025-09-10 10:26:00	2025-09-10 10:26:00
1793	TEH BINTI HASSAN	530901015890	2025-09-10 10:26:00	2025-09-10 10:26:00
1794	TEH KAW SIONG 	770324016107	2025-09-10 10:26:00	2025-09-10 10:26:00
1795	TEH KIM CHAY	451013065069	2025-09-10 10:26:00	2025-09-10 10:26:00
1796	TEH PEI SI	181002050446	2025-09-10 10:26:00	2025-09-10 10:26:00
1797	TEH YI ZHAN	030613080857	2025-09-10 10:26:00	2025-09-10 10:26:00
1798	TENG KIM PENG	570321715379	2025-09-10 10:26:00	2025-09-10 10:26:00
1799	TENTY YOHANA BINTI SAHAK 	751021105352	2025-09-10 10:26:00	2025-09-10 10:26:00
1800	TEO AH KEE 	490601016089	2025-09-10 10:26:00	2025-09-10 10:26:00
1801	TEO SAN MEI	770130015990	2025-09-10 10:26:00	2025-09-10 10:26:00
1802	TEO SIEW HIANG@TEY SEW YANG	380311015152	2025-09-10 10:26:00	2025-09-10 10:26:00
1803	TEOH JEN YEE	040403010235	2025-09-10 10:26:00	2025-09-10 10:26:00
1804	TEW CHEE MENG	691030015939	2025-09-10 10:26:00	2025-09-10 10:26:00
1805	TEY CHAI SENG 	500226015151	2025-09-10 10:26:00	2025-09-10 10:26:00
1806	TEY CHEN CHUNG 	940619015477	2025-09-10 10:26:00	2025-09-10 10:26:00
1807	TEY GUAT MUI @ TEY GUAT	530815015771	2025-09-10 10:26:00	2025-09-10 10:26:00
1808	TEY JIE YEE	130328010698	2025-09-10 10:26:00	2025-09-10 10:26:00
1809	TEY KENG TECK	490723015295	2025-09-10 10:26:00	2025-09-10 10:26:00
1810	TEY KIM KIAT	370411015476	2025-09-10 10:26:00	2025-09-10 10:26:00
1811	TEY KOCK SENG	730318015611	2025-09-10 10:26:00	2025-09-10 10:26:00
1812	TEY KONG CHAI	601215015511	2025-09-10 10:26:00	2025-09-10 10:26:00
1813	TEY PENG FEI	550207015899	2025-09-10 10:26:00	2025-09-10 10:26:00
1814	TEY POH SAN 	630506015231	2025-09-10 10:26:00	2025-09-10 10:26:00
1815	TEY SIEW CHOO	580403065276	2025-09-10 10:26:00	2025-09-10 10:26:00
1816	TEY TEONG SEONG 	521017015174	2025-09-10 10:26:00	2025-09-10 10:26:00
1817	THANABAL A/L RAJA GOPAL	501120715429	2025-09-10 10:26:00	2025-09-10 10:26:00
1818	THANALECHMY A/P RAMACHALAM	630610015776	2025-09-10 10:26:00	2025-09-10 10:26:00
1819	THANAPACKIAM A/P SUNDARAM	580901015968	2025-09-10 10:26:00	2025-09-10 10:26:00
1820	THASWIN A/L SAGUTHEVAN	211212010519	2025-09-10 10:26:00	2025-09-10 10:26:00
1821	THAVAMANI A/P RENU	701005015888	2025-09-10 10:26:00	2025-09-10 10:26:00
1822	THEIVANAI A/P MUNIANDY	741222085264	2025-09-10 10:26:00	2025-09-10 10:26:00
1823	THEVASHANTINI	910206105274	2025-09-10 10:26:00	2025-09-10 10:26:00
1824	THIVAGARAN MUTHIAH	880724235445	2025-09-10 10:26:00	2025-09-10 10:26:00
1825	TIA KAU @ TEY HWAY CHUAN	390905015343	2025-09-10 10:26:00	2025-09-10 10:26:00
1826	TIEW TWI KEK	590215015713	2025-09-10 10:26:00	2025-09-10 10:26:00
1827	TIJAH BINTI BUROK	440831045090	2025-09-10 10:26:00	2025-09-10 10:26:00
1828	TIONG WHEE TING	540614015053	2025-09-10 10:26:00	2025-09-10 10:26:00
1829	TOH AH BEY	600211015210	2025-09-10 10:26:00	2025-09-10 10:26:00
1830	TOH SIEW TIN	610813015292	2025-09-10 10:26:00	2025-09-10 10:26:00
1831	TONG GENN SENG	761024145295	2025-09-10 10:26:00	2025-09-10 10:26:00
1832	TU HWI HOE@TOH WHEE HOE	440606015135	2025-09-10 10:26:00	2025-09-10 10:26:00
1833	TUBIN BIN RUKIDIN	401228015215	2025-09-10 10:26:00	2025-09-10 10:26:00
1834	TULASI A/P RAMACHANDRAN	710120015706	2025-09-10 10:26:00	2025-09-10 10:26:00
1835	TYE CHEE HWA	910215016193	2025-09-10 10:26:00	2025-09-10 10:26:00
1836	UDIN @ UZIR ATAN	480519015029	2025-09-10 10:26:00	2025-09-10 10:26:00
1837	UMAR HADIF WAFIY ABDULLAH 	070728100017	2025-09-10 10:26:00	2025-09-10 10:26:00
1838	UMMU SYAIKAH BT MOHAMED	871116015524	2025-09-10 10:26:00	2025-09-10 10:26:00
1839	UMU SAADAH FARHANAH	850412045338	2025-09-10 10:26:00	2025-09-10 10:26:00
1840	UNAKRISHNAN A/L KANDELAN	610404055867	2025-09-10 10:26:00	2025-09-10 10:26:00
1841	UNGKU AHMAD DANIEL	0*0630100437	2025-09-10 10:26:00	2025-09-10 10:26:00
1842	UNGKU LAIGA	480918015368	2025-09-10 10:26:00	2025-09-10 10:26:00
1843	UTHASUREEYAN A/L VEMBU	710927015985	2025-09-10 10:26:00	2025-09-10 10:26:00
1844	V KARUPPIAH A/L VELLASAMY	570330016123	2025-09-10 10:26:00	2025-09-10 10:26:00
1845	VADIVELU A/L PONAYA	841014106145	2025-09-10 10:26:00	2025-09-10 10:26:00
1846	VALIAMA A/P SUBRAMANAM	600213015054	2025-09-10 10:26:00	2025-09-10 10:26:00
1847	VALLIAMAH SHOMA VALLY A/P GOINSAMY	690511085052	2025-09-10 10:26:00	2025-09-10 10:26:00
1848	VICKNESHWARY A/P RAJANDRAN	941217055112	2025-09-10 10:26:00	2025-09-10 10:26:00
1849	VIDYADHINI A/P SELVA KUMARAN	920625135274	2025-09-10 10:26:00	2025-09-10 10:26:00
1850	VIGEKUMAR A/L APPLASAMY	771229025675	2025-09-10 10:26:00	2025-09-10 10:26:00
1851	VIJAYA A/P MANAI	651227025384	2025-09-10 10:26:00	2025-09-10 10:26:00
1852	VISVANATHAN 	821015015327	2025-09-10 10:26:00	2025-09-10 10:26:00
1853	VITHIYA A/P VIJAYAN	980913015992	2025-09-10 10:26:00	2025-09-10 10:26:00
1854	VIVIAN TAN WEE YEN	900810016332	2025-09-10 10:26:00	2025-09-10 10:26:00
1855	VONG GEOK CHEE	780402045296	2025-09-10 10:26:00	2025-09-10 10:26:00
1856	WAHAB BIN AWI	520725105037	2025-09-10 10:26:00	2025-09-10 10:26:00
1857	WAHID BIN ABU BAKAR	610330015431	2025-09-10 10:26:00	2025-09-10 10:26:00
1858	WAI LEE AI	970117016485	2025-09-10 10:26:00	2025-09-10 10:26:00
1859	WAN CHIEW KONG	420530015041	2025-09-10 10:26:00	2025-09-10 10:26:00
1860	WAN GAYAH WAN OMAR	550306015480	2025-09-10 10:26:00	2025-09-10 10:26:00
1861	WAN MAHIRAH BINTI WAN MOHD PANDI	891206145654	2025-09-10 10:26:00	2025-09-10 10:26:00
1862	WAN MOHAMAD SYAFIEE BIN WAN SETAPA 	890808235425	2025-09-10 10:26:00	2025-09-10 10:26:00
1863	WAN MOHAMED ISFARIZAL BIN WAN ZAHARUDIN	960920015159	2025-09-10 10:26:00	2025-09-10 10:26:00
1864	WAN MOHD NOH 	641210015869	2025-09-10 10:26:00	2025-09-10 10:26:00
1865	WAN MOHD REDZUAN BIN WAN MAT ALI	810517115535	2025-09-10 10:26:00	2025-09-10 10:26:00
1866	WAN SAFEE BIN WAN MOHAMAD	531113015077	2025-09-10 10:26:00	2025-09-10 10:26:00
1867	WAN SHAIDATUIMA BINTI WAN ISMAIL	781230145470	2025-09-10 10:26:00	2025-09-10 10:26:00
1868	WAN TALIB BIN WAN MOHD	660411015033	2025-09-10 10:26:00	2025-09-10 10:26:00
1869	WEE AI MENG	590124065280	2025-09-10 10:26:00	2025-09-10 10:26:00
1870	WEI BOON @ WEE YEE BOON	460902015111	2025-09-10 10:26:00	2025-09-10 10:26:00
1871	WIDYANA 	840501016986	2025-09-10 10:26:00	2025-09-10 10:26:00
1872	WILSON A/L K MUTHU 	810531015645	2025-09-10 10:26:00	2025-09-10 10:26:00
1873	WONG AH DEK	500805015375	2025-09-10 10:26:00	2025-09-10 10:26:00
1874	WONG AH LOCK	500524015395	2025-09-10 10:26:00	2025-09-10 10:26:00
1875	WONG KIM HEE	550614085325	2025-09-10 10:26:00	2025-09-10 10:26:00
1876	WONG KOK LEONG	750620016170	2025-09-10 10:26:00	2025-09-10 10:26:00
1877	WONG KONG SUNG	580404015289	2025-09-10 10:26:00	2025-09-10 10:26:00
1878	WONG MAU 	421221015149	2025-09-10 10:26:00	2025-09-10 10:26:00
1879	WONG POH HOOI	660402015824	2025-09-10 10:26:00	2025-09-10 10:26:00
1880	WONG SING LAM	570321015911	2025-09-10 10:26:00	2025-09-10 10:26:00
1881	WONG SUI ING	730714135412	2025-09-10 10:26:00	2025-09-10 10:26:00
1882	WONG TECK YANG	460506045108	2025-09-10 10:26:00	2025-09-10 10:26:00
1883	WONG VOON HUNG	600816106182	2025-09-10 10:26:00	2025-09-10 10:26:00
1884	WONG WEE PHEN	900814045579	2025-09-10 10:26:00	2025-09-10 10:26:00
1885	WOON HUI KUYI 	600402015205	2025-09-10 10:26:00	2025-09-10 10:26:00
1886	YAACOB BIN AHMAD	620125015677	2025-09-10 10:26:00	2025-09-10 10:26:00
1887	YAACOB BIN KASSAN	471225015889	2025-09-10 10:26:00	2025-09-10 10:26:00
1888	YACOB BIN AHMAD	610122015015	2025-09-10 10:26:00	2025-09-10 10:26:00
1889	YAHYA BIN ABD HAMID	491020015773	2025-09-10 10:26:00	2025-09-10 10:26:00
1890	YAHYA BIN HAMZAH 	460805015267	2025-09-10 10:26:00	2025-09-10 10:26:00
1891	YAHYA BIN KITING	451031055059	2025-09-10 10:26:00	2025-09-10 10:26:00
1892	YAIMAH BINTI SALLEH	581011015426	2025-09-10 10:26:00	2025-09-10 10:26:00
1893	YAN SOON PIN	870815235265	2025-09-10 10:26:00	2025-09-10 10:26:00
1894	YAP BOON HYE	801219015152	2025-09-10 10:26:00	2025-09-10 10:26:00
1895	YAP CHAI SIM	550106055234	2025-09-10 10:26:00	2025-09-10 10:26:00
1896	YAP CHEOW LAI	580109015139	2025-09-10 10:26:00	2025-09-10 10:26:00
1897	YAP CHOK MOI 	581203045160	2025-09-10 10:26:00	2025-09-10 10:26:00
1898	YAP MEOW 	501230015431	2025-09-10 10:26:00	2025-09-10 10:26:00
1899	YAP MEU CHAN	480615015483	2025-09-10 10:26:00	2025-09-10 10:26:00
1900	YAP PENG HOCK	690511016321	2025-09-10 10:26:00	2025-09-10 10:26:00
1901	YAP POO CHOI 	670331016385	2025-09-10 10:26:00	2025-09-10 10:26:00
1902	YAP SIEW YOKE	961014015792	2025-09-10 10:26:00	2025-09-10 10:26:00
1903	YATINAH BINTI SELAMAT 	541223015528	2025-09-10 10:26:00	2025-09-10 10:26:00
1904	YAWAHIL BIN SALLEH	540213045307	2025-09-10 10:26:00	2025-09-10 10:26:00
1905	YAZID BIN A. KHALID	560818016507	2025-09-10 10:26:00	2025-09-10 10:26:00
1906	YB MOHD AZAHAR	720514015839	2025-09-10 10:26:00	2025-09-10 10:26:00
1907	YEE TAK LUM	571008016277	2025-09-10 10:26:00	2025-09-10 10:26:00
1908	YEO CHAI MENG	790511015431	2025-09-10 10:26:00	2025-09-10 10:26:00
1909	YEO HUA SIA	450928015233	2025-09-10 10:26:00	2025-09-10 10:26:00
1910	YEO WEE LOK	811019015659	2025-09-10 10:26:00	2025-09-10 10:26:00
1911	YEOW TIAN SONG	410503015573	2025-09-10 10:26:00	2025-09-10 10:26:00
1912	YEW ENG	511108015859	2025-09-10 10:26:00	2025-09-10 10:26:00
1913	YEW JIN YUAN	990614045357	2025-09-10 10:26:00	2025-09-10 10:26:00
1914	YEW KOI	540924015673	2025-09-10 10:26:00	2025-09-10 10:26:00
1915	YIM KAI CHENG	531115015847	2025-09-10 10:26:00	2025-09-10 10:26:00
1916	YOGAARAJAN 	190127011381	2025-09-10 10:26:00	2025-09-10 10:26:00
1917	YOGITHA A/P SATHASIVAM	850729265048	2025-09-10 10:26:00	2025-09-10 10:26:00
1918	YONG LAI CHENG	990215016241	2025-09-10 10:26:00	2025-09-10 10:26:00
1919	YONG SAN	510429015687	2025-09-10 10:26:00	2025-09-10 10:26:00
1920	YONG SOON TIAM @ YONG KOH POH	440904015061	2025-09-10 10:26:00	2025-09-10 10:26:00
1921	YONG WOOI MENG	641225015423	2025-09-10 10:26:00	2025-09-10 10:26:00
1922	YOU SOO LAN	590720016282	2025-09-10 10:26:00	2025-09-10 10:26:00
1923	YOW THOR HONG	770305016021	2025-09-10 10:26:00	2025-09-10 10:26:00
1924	YUSOF BIN IBRAHIM	480914015555	2025-09-10 10:26:00	2025-09-10 10:26:00
1925	YUSOF BIN MUSA	550624715263	2025-09-10 10:26:00	2025-09-10 10:26:00
1926	YUSSOF BIN YUNUS	631216035589	2025-09-10 10:26:00	2025-09-10 10:26:00
1927	YUSSOF BIN YUNUS	12.9.23	2025-09-10 10:26:00	2025-09-10 10:26:00
1928	ZABAIDAH BINTI OSNAN	651101016642	2025-09-10 10:26:00	2025-09-10 10:26:00
1929	ZABIDAH IBRAHIM	790810016178	2025-09-10 10:26:00	2025-09-10 10:26:00
1930	ZAHAR BIN NEEMAT	510729055349	2025-09-10 10:26:00	2025-09-10 10:26:00
1931	ZAHARI BIN IBRAHIM 	641011035613	2025-09-10 10:26:00	2025-09-10 10:26:00
1932	ZAIHUDDIN BIN SURATMAN	580612016155	2025-09-10 10:26:00	2025-09-10 10:26:00
1933	ZAINAB BT SUPAH	500721015028	2025-09-10 10:26:00	2025-09-10 10:26:00
1934	ZAINAL ABIDIN BIN MOHD NOOR	540513015951	2025-09-10 10:26:00	2025-09-10 10:26:00
1935	ZAINAL B. MAMEK	570312017069	2025-09-10 10:26:00	2025-09-10 10:26:00
1936	ZAINAL BIN MD ZIN	500709015631	2025-09-10 10:26:00	2025-09-10 10:26:00
1937	ZAINALABIDIN ISA	610817025623	2025-09-10 10:26:00	2025-09-10 10:26:00
1938	ZAINI BIN ABDULLAH	670627016413	2025-09-10 10:26:00	2025-09-10 10:26:00
1939	ZAINI MD NOOR	730603115056	2025-09-10 10:26:00	2025-09-10 10:26:00
1940	ZAINON BINTI SERI	660825015498	2025-09-10 10:26:00	2025-09-10 10:26:00
1941	ZAINUDDIN BIN HASSAN 	610406035173	2025-09-10 10:26:00	2025-09-10 10:26:00
1942	ZAINUDDIN BIN YUSOF	630416086271	2025-09-10 10:26:00	2025-09-10 10:26:00
1943	ZAKARAIA BIN DAHLAN 	570522017059	2025-09-10 10:26:00	2025-09-10 10:26:00
1944	ZAKARIA B ALI	600902016079	2025-09-10 10:26:00	2025-09-10 10:26:00
1945	ZAKARIA BIN AB RAHMAN 	540304016165	2025-09-10 10:26:00	2025-09-10 10:26:00
1946	ZAKARIA BIN AB SAMAD 	500428015985	2025-09-10 10:26:00	2025-09-10 10:26:00
1947	ZAKARIA BIN MAHMOOD	541120016317	2025-09-10 10:26:00	2025-09-10 10:26:00
1948	ZAKARIA BIN MD JAN	500228015243	2025-09-10 10:26:00	2025-09-10 10:26:00
1949	ZAKARIA UMAR	580918715207	2025-09-10 10:26:00	2025-09-10 10:26:00
1950	ZAKWAN FAHMI	950104065749	2025-09-10 10:26:00	2025-09-10 10:26:00
1951	ZALEHA BINTI ARIFIN	570101017384	2025-09-10 10:26:00	2025-09-10 10:26:00
1952	ZALIHA BINTI LIMAT 	441031015488	2025-09-10 10:26:00	2025-09-10 10:26:00
1953	ZALINA MAT PERSI	810310085498	2025-09-10 10:26:00	2025-09-10 10:26:00
1954	ZALMAH BINTI ALIAS	721024015902	2025-09-10 10:26:00	2025-09-10 10:26:00
1955	ZAMREE	661230015047	2025-09-10 10:26:00	2025-09-10 10:26:00
1956	ZAMRI BIN ITHNIN	710116045179	2025-09-10 10:26:00	2025-09-10 10:26:00
1957	ZAMRI BIN TALIB	520317065013	2025-09-10 10:26:00	2025-09-10 10:26:00
1958	ZARINA BINTI GHAZALI	651030065016	2025-09-10 10:26:00	2025-09-10 10:26:00
1959	ZAUKIAH BINTI SAAD 	580710026146	2025-09-10 10:26:00	2025-09-10 10:26:00
1960	ZOLKAPPLI BIN RAHMAT	601114015627	2025-09-10 10:26:00	2025-09-10 10:26:00
1961	ZOLKEPLI BIN AHMAD	591108015237	2025-09-10 10:26:00	2025-09-10 10:26:00
1962	ZORKARNAIN BIN ABDULLAH	600701015387	2025-09-10 10:26:00	2025-09-10 10:26:00
1963	ZORRIAH BINTI ABD HAMID (15MG)	570125016634	2025-09-10 10:26:00	2025-09-10 10:26:00
1964	ZUBAIDAH BTE HASSAN	630205016150	2025-09-10 10:26:00	2025-09-10 10:26:00
1965	ZULAIHA BINTI MOHD HALIMI	790811016014	2025-09-10 10:26:00	2025-09-10 10:26:00
1966	ZULAIHA BT MOHAMAD	760605017086	2025-09-10 10:26:00	2025-09-10 10:26:00
1967	ZULKARNAIN BIN PONIRAN	761124016255	2025-09-10 10:26:00	2025-09-10 10:26:00
1968	ZULKEFLY BIN ABU SAMAH	581125085203	2025-09-10 10:26:00	2025-09-10 10:26:00
1970	ZULKIPLE BIN MOHD NOR	621015045861	2025-09-10 10:26:00	2025-09-10 10:26:00
1971	ZULKIPLI BIN YAAKUB	641003115509	2025-09-10 10:26:00	2025-09-10 10:26:00
1972	ZULLKUFFLI BIN YUSOFF	590303015705	2025-09-10 10:26:00	2025-09-10 10:26:00
1973	ZURAIDA BINTI MAT KARI	941203115436	2025-09-10 10:26:00	2025-09-10 10:26:00
1974	ZURAIDAH MOHD TAIB	880607015910	2025-09-10 10:26:00	2025-09-10 10:26:00
1975	ZURIDA BT MOHD NOOR	731125035370	2025-09-10 10:26:00	2025-09-10 10:26:00
1977	ZAFIFAH BINTI YAHYA	780803016314	2025-10-22 10:41:44.958204	2025-10-22 10:41:44.958204
1969	ZULKIFLI BIN HARUN	691218035173	2025-09-10 10:26:00	2025-10-22 14:29:51.527299
826	MUHAMMAD ZAFRAN ANAQI BIN MUHAMAD ZAKRI 	250420010291	2025-09-10 10:26:00	2025-10-27 09:08:02.505823
1978	B/O NOOR SALLYANA BINTI ABU SAWAL 	030423050294I1	2025-10-27 09:08:54.984048	2025-10-27 09:08:54.984048
23	A RAHIM BIN KASIM	430917015467	2025-09-10 10:26:00	2025-10-27 10:04:47.033151
1982	TAN YANN HOU	230527040097	2025-10-27 10:30:31.986122	2025-10-27 10:30:31.986122
1983	ROHAZARIZA BINTI YAACOB	760421016740 	2025-10-27 10:30:58.220103	2025-10-27 10:30:58.220103
324	DARSEH BINTI JUMADI	521126015640	2025-09-10 10:26:00	2025-10-27 10:36:15.429113
1984	NG TAN BOY	490727085186 	2025-10-27 10:37:24.46872	2025-10-27 10:37:24.46872
1599	SHAHIDA BINTI MAKHTAR	790520065270	2025-09-10 10:26:00	2025-10-27 11:50:34.647622
348	EZWANA BINTI MISMAN	850825015874	2025-09-10 10:26:00	2025-10-27 11:51:17.908772
1985	FARAH NOR SYAZWANI BINTI ZAKARIA	941015015470	2025-10-27 12:00:24.744986	2025-10-27 12:00:24.744986
1986	NORAMIRAH AFIQAH BINTI ILIYAHS	961102295448	2025-10-27 12:08:06.346512	2025-10-27 12:08:06.346512
252	BALBIR SINGH A/L SUKHDEV SINGH	701206015163	2025-09-10 10:26:00	2025-11-04 16:31:43.481419
1987	DR INTAN NOR CHAHAYA BT SHUKOR	720630016388	2025-11-05 11:52:41.439623	2025-11-05 11:52:41.439623
1988	SALLEHUDIN BIN KAHAR 	650606045153	2025-11-05 11:54:12.806087	2025-11-05 11:54:12.806087
1989	RAYQA MEDINA BINTI ROHAIZAD	250411010388	2025-11-10 11:24:21.077129	2025-11-10 11:24:21.077129
1990	MUHAMMAD SYAFIQ RAYQAL BIN ROSLAN	250624102083	2025-11-10 11:25:35.43014	2025-11-10 11:25:35.43014
1991	B/O SLAMET	C9586161I2	2025-11-10 11:25:59.96886	2025-11-10 11:25:59.96886
1992	B/O NURFARKKHANA BINTI KAMRUDDIN	850405105136I6	2025-11-10 11:26:23.948531	2025-11-10 11:26:23.948531
1993	B/O VEMALA A/P VAJAN	8706112325036I2	2025-11-10 11:52:47.438134	2025-11-10 11:52:47.438134
1994	NUR ISYA MEDINA BINTI MOHAMAD TASNIM	250606010986	2025-11-10 11:53:42.868982	2025-11-10 11:53:42.868982
1995	HELENA SOFEA BINTI MOHAMAD HAZIQ 	250715010694	2025-11-10 11:54:14.413726	2025-11-10 11:54:14.413726
1996	ASHRAFUN NISAH BINTI A RAHMAN	601129015902	2025-11-10 12:41:11.941857	2025-11-10 12:41:11.941857
1997	MOHD ROSMADI BIN MAT ARSHAD	770409036449	2025-11-10 12:41:21.827589	2025-11-10 12:41:21.827589
1998	ZULKIFLI BIN JUMAKAN	660102016681	2025-11-10 12:41:34.386145	2025-11-10 12:41:34.386145
1999	HANAN BINTI FAISAL	870430665088	2025-11-10 12:41:52.311394	2025-11-10 12:41:52.311394
2000	KWAN AH LAN 	411011015280	2025-11-10 12:55:47.032353	2025-11-10 12:55:47.032353
2001	MOHD NAZLIE BIN AZMAN	840802085133	2025-11-10 12:56:08.717559	2025-11-10 12:56:08.717559
2002	ABD RAHMAN BIN MOHDAL	850125026089	2025-11-10 12:56:35.150823	2025-11-10 12:56:35.150823
2003	NORIMRANUDDIN BIN MD SHAH	960709015989	2025-11-10 12:56:51.664963	2025-11-10 12:56:51.664963
2004	MOHD SHARI BIN TAPIT	760905016317	2025-11-10 12:57:21.063094	2025-11-10 12:57:21.063094
2005	CHOO NYUK LAH	530329715086	2025-11-10 12:57:33.574	2025-11-10 12:57:33.574
2006	MUHAMAD HAZIQ BIN ABDUL RAHIM	050512010305	2025-11-24 15:15:54.163391	2025-11-24 15:15:54.163391
2007	DANIEL A/L BALI	000907020609	2025-11-24 15:51:45.319817	2025-11-24 15:51:45.319817
2008	SIN YEE LAN	730815016586	2025-11-24 15:51:53.659748	2025-11-24 15:51:53.659748
2009	GOVANDAN A/L VEERAPPAN	570809016707	2025-11-24 15:52:02.993502	2025-11-24 15:52:02.993502
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, created_at, updated_at, ic_number) FROM stdin;
1	admin	admin@gmail.com	$2a$10$9dvqJKAYK7PQVJwlsiqhUuJlQNV/Oha2aZBgCbyTFN7Uvj3hEdyS2	2025-09-17 16:26:32.658664	2025-09-17 16:48:39.781332	\N
8	Test User	\N	$2a$10$nmS7Fuj.rlZGyXmWz69Jq.FcFcIdf8EnCTLPo/PaCnajAyLpmzOWG	2025-09-18 11:11:19.652714	2025-09-18 11:11:19.652714	123456789012
9	admin	\N	$2a$10$D13fAOVBaqep66SF3QfC4uaY2bBRdtA7xOw3fIJvW6a83jyvjc2Qq	2025-09-18 11:13:35.902889	2025-09-18 11:13:35.902889	132456
10	user	\N	$2a$10$kK9ql/6Cd8s14X6wJRI39eQevXYLxJ6HzLDeUUDEQXXHwcgJpWV3u	2025-09-18 11:15:59.82273	2025-09-18 11:15:59.82273	123456789
12	Testing	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-09-22 08:51:05.806457	2025-09-22 08:51:05.806457	123456
11	Muhammad Redzuan	\N	$2a$10$JGC5shr65Dy5Qxk4YLiYw.ppSbg5prHJYJ/SgZMbJLKOPjGWmM4Ta	2025-09-18 11:21:01.860637	2025-10-23 16:24:55.289592	911216146621
13	For Testing Only	\N	$2a$10$9QFvnUHi.YBk82sKzAWfxu.VokWG0yW2ZpXYc/pzyb6RHYxS/7LKK	2025-11-07 11:47:19.038805	2025-11-07 11:47:19.038805	12345678
14	Mazni Binti Sareh	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	771021016614
15	Noorulhida Bt. Ishak	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	820326016330
16	Shahir Izwan Bin Md. Hanapiah@Othman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	860929237139
17	Chia Chen Yin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	860402235890
18	Kek Siok Ling	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	860411236246
19	Goh Ching Yik	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	870922125264
20	Soh Pei Cin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	881130235602
21	Seow Xin Ni	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	880315235110
22	Fui Huey Pin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	880708015944
23	Chan Mui Wen	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	880730236022
24	Mira Marina binti Mahfodz	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	890508235028
25	Tan Yew Jin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	880816235805
26	Ummu Zahidah Bt Abu Bakar	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	891017015340
27	Nur Hateikah Binti Othman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	900219015682
28	Gan Su Ling	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	900714045248
29	Lim Soon Hong	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	900708105881
30	Nur Syafiqah Binti Anuar	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	910504065354
31	Set Li Yan	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	930608015608
32	Muhammad Mazaitul Akmal bin Sulaiman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	920325055117
33	Vasanthy A/P Elankovan	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	930301086540
34	Chong Hui Ting	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	920609015520
35	Ong Ming Jian	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	930704045209
36	Mohd Asyraf Bin Samsudin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	920128015335
37	Siti Hajar Binti Norazharr	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	950827105134
38	Nur Azlina Binti Tharujathulla	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	960514016412
39	Siti Nabiella Binti Noor Azmi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	941119016048
40	Nadia Syafika Binti Md Razak	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	970215235040
41	Ummul Syuhaida Binti Mohd Nor	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	951104055182
42	Nuramalina binti Afandi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	880911065488
43	Nurul Athirah binti Riduan	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	960726045186
44	Nurul Qistina binti Mohd Shaberi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	971013115176
45	Nur Azwa Syazwani Binti Ab Rahman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	971106015764
46	Siti Aisyah Binti Mohd Ali	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	990125016862
47	Leong Hao Xiang	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	990212105417
48	Nor Ameeza binti Md Amin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	960828055254
49	Noor Shakirah binti Mohd Farid	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	990531016286
50	Muhamad Shauqiemuez Bin Ramli	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	980527035557
51	Mohammad Nurhuzairie Bin Anuar	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	970908025169
52	Muhammad Sahmi bin Mohd Sari	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	970331085537
53	Nur Farah Aqilah Binti A Zahari	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	980818036234
54	Woh Kah Lok	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	981130065082
55	Koo Bao Yi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	980725016680
56	Leow Zi Qing	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	011126040248
57	Nurul Nasuha Binti Alma Za'adi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010612101320
58	Hannan Binti Abdul Razak	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010928110506
59	Saiful Amri Bin Hasnan	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	011025102067
60	Muhammad Sirajuddin Bin Ab Rahman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010108060451
61	Nor Hidayatul Alia Binti Harun	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010209100686
62	Shamimi Irawayu Binti Samsudin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010602030864
63	Nur Ayuni Syahirah Binti Abdul Naidi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010823030702
64	Nur Alyani Binti Mohamad Asri	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010925101428
65	Nor Syahira Binti A Ham Suri	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010307011812
66	Leong Kar Qi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	010517080189
67	Norliza Binti Uwai	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	680122015836
68	Afif Norazam bin Mohd Salleh	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	771105016697
69	Mohd Rizman Bin Yunan	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	800927145885
70	Shahrulnizam bin Zakaria	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	780920065801
71	Norziela Rahyza Binti Zamri	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	860201015058
72	Norihan Binti Shamsudin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	790223105766
73	Norsaliza Kamaruzaman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	790619025148
74	Nurkairunisah Bt Mahbar	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	870406065162
75	Intan Nadzirah Binti Yunos	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	950415015896
76	Muhammad Mustaqim bin Mohammad Rosdi	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	940825035583
77	Nurul Hanis Nabilah Binti Kaharuddin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	980309065432
78	Sarmeme Binti Herman	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	970221125622
79	Noami Inezsha Ugok	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	981027136268
80	Sania Sukudat	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	981112125766
81	Frenchcila Laping	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	980605125962
82	Angely Coltrane Anak Clement	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	000110130640
83	Hanis Binti Jamirin	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	000217121410
84	Rozzalia Anak Sudie	\N	$2a$10$TmyTIVdUfjXAjU1g2h8IkeIycdgEJ0GPpmkNdT78ThH/UuoV/i5Sa	2025-11-07 11:47:00	2025-11-07 11:47:00	000131130404
\.


--
-- Name: defaulters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.defaulters_id_seq', 1, false);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_id_seq', 23, true);


--
-- Name: drugs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drugs_id_seq', 119, true);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 403, true);


--
-- Name: patients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patients_id_seq', 2009, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: defaulters defaulters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defaulters
    ADD CONSTRAINT defaulters_pkey PRIMARY KEY (id);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: drugs drugs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugs
    ADD CONSTRAINT drugs_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_drug_id_patient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_drug_id_patient_id_key UNIQUE (drug_id, patient_id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: patients patients_ic_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_ic_number_key UNIQUE (ic_number);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_ic_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_ic_number_key UNIQUE (ic_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_drugs_department_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drugs_department_id ON public.drugs USING btree (department_id);


--
-- Name: idx_enrollments_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_active ON public.enrollments USING btree (is_active);


--
-- Name: idx_enrollments_drug_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_drug_id ON public.enrollments USING btree (drug_id);


--
-- Name: idx_enrollments_latest_refill; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_latest_refill ON public.enrollments USING btree (latest_refill_date);


--
-- Name: idx_enrollments_patient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_patient_id ON public.enrollments USING btree (patient_id);


--
-- Name: idx_patients_ic_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_ic_number ON public.patients USING btree (ic_number);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: departments update_departments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON public.departments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: drugs update_drugs_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_drugs_updated_at BEFORE UPDATE ON public.drugs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: enrollments update_enrollments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_enrollments_updated_at BEFORE UPDATE ON public.enrollments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: patients update_patients_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: defaulters defaulters_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defaulters
    ADD CONSTRAINT defaulters_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drugs(id) ON DELETE CASCADE;


--
-- Name: defaulters defaulters_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defaulters
    ADD CONSTRAINT defaulters_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id) ON DELETE CASCADE;


--
-- Name: defaulters defaulters_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defaulters
    ADD CONSTRAINT defaulters_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: drugs drugs_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugs
    ADD CONSTRAINT drugs_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drugs(id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict pco1D7Bh0dbxpNcp9wW8LZSNgiETjBk29UOGhJ3hmqPJjkoNTjQEaZyNHjnVwgU

