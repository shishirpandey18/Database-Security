--
-- PostgreSQL database dump
--

\restrict EGt9pnsE6PhHsfsNCCxp6ucM91iGEPgCqF0tSu4ODtgeX87copJLtILX2hwWvo7

-- Dumped from database version 16.11 (Postgres.app)
-- Dumped by pg_dump version 16.11 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.appointments (
    appointment_id integer NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    status character varying(20) DEFAULT 'scheduled'::character varying NOT NULL,
    created_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    notes text
);


ALTER TABLE public.appointments OWNER TO kranti;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.appointments_appointment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appointments_appointment_id_seq OWNER TO kranti;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.appointments_appointment_id_seq OWNED BY public.appointments.appointment_id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.audit_logs (
    log_id integer NOT NULL,
    user_id integer,
    action character varying(100) NOT NULL,
    table_name character varying(50) NOT NULL,
    record_id integer,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    details text
);


ALTER TABLE public.audit_logs OWNER TO kranti;

--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.audit_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_log_id_seq OWNER TO kranti;

--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.audit_logs_log_id_seq OWNED BY public.audit_logs.log_id;


--
-- Name: billing; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.billing (
    billing_id integer NOT NULL,
    patient_id integer NOT NULL,
    appointment_id integer,
    amount numeric(10,2) NOT NULL,
    payment_status character varying(20) DEFAULT 'unpaid'::character varying NOT NULL,
    insurance_provider bytea,
    insurance_claim_id bytea,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.billing OWNER TO kranti;

--
-- Name: billing_billing_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.billing_billing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.billing_billing_id_seq OWNER TO kranti;

--
-- Name: billing_billing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.billing_billing_id_seq OWNED BY public.billing.billing_id;


--
-- Name: doctors; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.doctors (
    doctor_id integer NOT NULL,
    user_id integer,
    specialty character varying(100),
    license_number character varying(50),
    contact_info text,
    last_login_at timestamp without time zone
);


ALTER TABLE public.doctors OWNER TO kranti;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.doctors_doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctors_doctor_id_seq OWNER TO kranti;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.doctors_doctor_id_seq OWNED BY public.doctors.doctor_id;


--
-- Name: medical_records; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.medical_records (
    record_id integer NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer,
    visit_date date NOT NULL,
    diagnosis bytea,
    treatment_notes bytea,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    modified_at timestamp without time zone,
    visibility character varying(20) DEFAULT 'normal'::character varying NOT NULL
);


ALTER TABLE public.medical_records OWNER TO kranti;

--
-- Name: medical_records_record_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.medical_records_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medical_records_record_id_seq OWNER TO kranti;

--
-- Name: medical_records_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.medical_records_record_id_seq OWNED BY public.medical_records.record_id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.patients (
    patient_id integer NOT NULL,
    user_id integer,
    full_name character varying(100) NOT NULL,
    dob date,
    contact_info bytea,
    last_login_at timestamp without time zone
);


ALTER TABLE public.patients OWNER TO kranti;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.patients_patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_patient_id_seq OWNER TO kranti;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.patients_patient_id_seq OWNED BY public.patients.patient_id;


--
-- Name: pharmacists; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.pharmacists (
    pharmacist_id integer NOT NULL,
    user_id integer,
    can_dispense boolean DEFAULT true NOT NULL
);


ALTER TABLE public.pharmacists OWNER TO kranti;

--
-- Name: pharmacists_pharmacist_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.pharmacists_pharmacist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacists_pharmacist_id_seq OWNER TO kranti;

--
-- Name: pharmacists_pharmacist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.pharmacists_pharmacist_id_seq OWNED BY public.pharmacists.pharmacist_id;


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.prescriptions (
    prescription_id integer NOT NULL,
    record_id integer NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer,
    pharmacist_id integer,
    drug_name character varying(200) NOT NULL,
    dosage character varying(100) NOT NULL,
    frequency character varying(100) NOT NULL,
    status character varying(20) DEFAULT 'issued'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    dispensed_at timestamp without time zone
);


ALTER TABLE public.prescriptions OWNER TO kranti;

--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.prescriptions_prescription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescriptions_prescription_id_seq OWNER TO kranti;

--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.prescriptions_prescription_id_seq OWNED BY public.prescriptions.prescription_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: kranti
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash text NOT NULL,
    role character varying(30) NOT NULL,
    email character varying(100),
    phone character varying(30),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    last_login_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO kranti;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: kranti
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO kranti;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kranti
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: appointments appointment_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.appointments ALTER COLUMN appointment_id SET DEFAULT nextval('public.appointments_appointment_id_seq'::regclass);


--
-- Name: audit_logs log_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN log_id SET DEFAULT nextval('public.audit_logs_log_id_seq'::regclass);


--
-- Name: billing billing_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.billing ALTER COLUMN billing_id SET DEFAULT nextval('public.billing_billing_id_seq'::regclass);


--
-- Name: doctors doctor_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.doctors ALTER COLUMN doctor_id SET DEFAULT nextval('public.doctors_doctor_id_seq'::regclass);


--
-- Name: medical_records record_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.medical_records ALTER COLUMN record_id SET DEFAULT nextval('public.medical_records_record_id_seq'::regclass);


--
-- Name: patients patient_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.patients ALTER COLUMN patient_id SET DEFAULT nextval('public.patients_patient_id_seq'::regclass);


--
-- Name: pharmacists pharmacist_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.pharmacists ALTER COLUMN pharmacist_id SET DEFAULT nextval('public.pharmacists_pharmacist_id_seq'::regclass);


--
-- Name: prescriptions prescription_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions ALTER COLUMN prescription_id SET DEFAULT nextval('public.prescriptions_prescription_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.appointments (appointment_id, patient_id, doctor_id, start_time, end_time, status, created_by, created_at, notes) FROM stdin;
1	1	1	2025-01-12 10:00:00	\N	completed	2	2025-12-15 14:19:57.029888	Routine cardiac check
2	2	2	2025-01-15 14:00:00	\N	scheduled	1	2025-12-15 14:19:57.029888	First GP visit
3	3	2	2025-01-20 09:00:00	\N	completed	4	2025-12-15 14:19:57.029888	Blood pressure follow-up
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.audit_logs (log_id, user_id, action, table_name, record_id, "timestamp", details) FROM stdin;
1	1	CREATE_PATIENT	patients	1	2025-12-15 14:19:57.032831	Admin registered patient
\.


--
-- Data for Name: billing; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.billing (billing_id, patient_id, appointment_id, amount, payment_status, insurance_provider, insurance_claim_id, created_at) FROM stdin;
1	1	1	120.00	paid	\\xc30d0407030273723a26abec4ff46dd241017b8ee6f72fbc8423855db30fb849e014f6c23897fe77c5f3b3c0d9037ad65e5bfb238abba5be4d29507c02381835fc176c4cb818b9aed0b849cef9add7341bfa	\\xc30d040703024758d6f0519e7a3a7ad2410119e22570c2d38fa61179beb4ada5322048aaeeccb7ce52970a4483b663e0490e6541538ead8edea53fdf9be567d10418e5804fb79057c20a1adeb574acc882ff	2025-12-15 14:19:57.032276
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.doctors (doctor_id, user_id, specialty, license_number, contact_info, last_login_at) FROM stdin;
1	12	Cardiology	DOC-LUX-1001	Kirchberg Clinic	\N
2	13	General Practice	DOC-LUX-1002	Family Practice	\N
3	14	Pediatrics	DOC-LUX-3001	Pediatric Center	\N
4	15	Dermatology	DOC-LUX-3002	Dermatology Center	\N
5	16	Neurology	DOC-LUX-3003	Neurology Clinic	\N
\.


--
-- Data for Name: medical_records; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.medical_records (record_id, patient_id, doctor_id, visit_date, diagnosis, treatment_notes, created_at, modified_at, visibility) FROM stdin;
1	1	1	2025-01-12	\\xc30d040703029f42ddf294b7339c7ed2c019017dc9525b20c5baf6e5592eb4c0c85d88a87f46ba93c06a6b896a76ba5fb12d204c90886ef39a20819807e464e639671c2bd84512a9667f86612442a78f9481f87cb47d2e7faeb6d696cfbadc2316e5265bfa2a7c363ffd1ef7098411600517929b2d9bf7738d530c446c86f968f99503e4bcc7e8bdc2785b759627f16c14d8fdca41ac51c93e6cc0255853e234c17ac2953e4becee7461a5e707f87eac59306d3b884c9ba56bf719368e6940416db8ca050d2135c97b7a730594e9b2adb05cfa0a963488faae4c38394d1626c9d9df3dc034af44a7ebae45	\\xc30d0407030209e311ae3335d3126dd2c03201ee7e714f9d4d24356585073428eaa7575fcd82ddd239171ce32d62e613e701d582e4a45f8412ac5af853bd7a4fa61646ca7b622c5d382457942e24d5a7637ba98554d76d66bc8596e6e20cce4d17a82f98d1637ad63159d0fa496441df69328b14a33d92d6c7807383cc0b0a461b143118bbab592f71dd3e36d1e45ad667271d64f80002e2803676db604529f8ca6b8e8b2ff388dd9de0f9fc010e8b994ddda906877645b6edaaded8f79ad2fcc2de8035eb2740a90248c045c72eabbd0424fd1d303a528ad15739c492c4ca47d07d40959aeba76fde2deac80da0b8301ab22dca560ee99b9547637ca4d3329b42bc9e88	2025-12-15 14:19:57.030982	\N	normal
2	1	1	2025-12-15	\\xc30d04070302106684e30829008a63d23f01c6cbe666ac13953fa8e44d233fb5e2398659918b4525cd1e00853f8d44d63de9056ef35ea4f2ae045ab7f06d1777a9a05e80debc2918e3e092ef8f5a6e26	\\xc30d04070302960e2196926d00e460d2450113d888d6a3adc12ab3776ed2509c9eb22cac974b20d2fcc06986321f766193b8e3ba0bd4d5838a292bb4ac351beec30be908e13772f76943f6f2189a36c44a41bcd62ade	2025-12-15 15:30:07.014924	\N	normal
3	1	1	2025-12-15	\\xc30d04070302fa87d40464adf8996ed23f01aabe43b142ced268fb40520ca05d72aa26292f73f7c9d034bfe05dc26a1937cd9c8a9cd09c45179e23d31869752c866afa51173c482192257b2fae69a8f1	\\xc30d040703021892f56f0cd8f75f62d24501e5f1cc1e2f206fa7d584e8e6c8dfa50c94ce536192aa7e0d3860a648f23f2e82c97d87b1f765672bb588fd5eae82858c0e4b573814f29b8a9f464c7e74c32662655ff385	2025-12-15 15:30:11.017728	\N	normal
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.patients (patient_id, user_id, full_name, dob, contact_info, last_login_at) FROM stdin;
1	2	John Miller	1990-04-12	\\xc30d04070302414e22faa2f9dccf66d2c03601fe634a6f95d62ab43e311377f7dd9b4e2cb913691af200fff5cc7530993e1184eca9c3939a259df9d398a7b86836c41fe2812f877a2a34e8d52bb7f65914dc04c9f22127225c371956913f8e30c4327f0ebf8f9c9556215b241df47912e91a74e9147b604a86badfa390382e2bfd085b6ff32429aaba5ee436fb3979faa9fca56a1668a2531b27f75212f5552b547ca30c3aacc18cd67fd4bf97b03b4ec7fa5130e849f4cc1f248c15897f0e7702bccb541a2e970c719fd2199d2489c1f9ba2a6ae4156dd680f93111e34f435bf71037d6a408649c5301036085f6b14ddbac4c662b01d9c7fa814302641ed3e89b6ad7cd2e4d41f9	\N
2	3	Mary Johnson	1985-09-23	\\xc30d04070302dfab5dc79deebda07ed2c03801144dbace578be98c5821a0389ff7aed18c49e33f546443edd00eca9f6bd4154ab62f43501ef476d1b76a6eba85c23844d5c3cde3cd0f395cc1e524a4f84b5ad9a5459de86e37ea91bc0bbe1caaf4130c9651f9882d957355a855f5bce18a00174fc1404cdce2cf32c042a148db286f275a2484ebbfba83ef0ce15062769ded966a35745fa92236021670a98b9cf799aa24f0353f296520da73bc7940dc4ac76e51c2bcd799349618b787084e6ba0bd309b2a0ab8da7ce9ab817b08c9c3276f4970c59b558cbcc56a47a46fce2770d47a9f6747fc6bc92b68c740e547413b35abf64d4a5206d2168b62949bada020366404a490f38ea609	\N
3	4	Luc Schmit	1992-03-05	\\xc30d04070302df37dfba0fde13b87ad2c036017513004ec8fedf09c9ecf106a03c4ebca7fc4e40e42b0c360eb43e725637043db10ef9f06ffb102a47f9eb4b609ecc0238ecadee798b518dd2e589710cccbdd81ba0888efea4b135181063073e812d9a2a922bc577232405bf8a317fc9559c0d1f92ce114f1e99c1509e5723289ec1f9b46c1436a45ecb461b0cd8fa62f82485eff1ab8bf3b86a9d374ec792f493210e038b8552fa33ad848e44afe168d805a766aa57d1288262ac4070c259f6a868bfb1211d760c30bee457e6c50da239ad6ff811f94c445dd2f0c10ea9c1a6e46d7bb0c2c44e31b06fdaf27052d4ed73d3b70d5a1183febefa53b92a610a587c8187b989bf7961	\N
4	5	Sophie Klein	1988-11-19	\\xc30d04070302c06154928f04acf275d2c03801d39a661008949cdfff67c8b8ec779bc1506e391fb7435402b0122044d8d3240b134d34273012de63dd5d114bcad4c80a8623de995f9d25517c4557fd9624cd12a4b16411997d3e214ebeff0ac9a2ba31568447154b475fb3c71f1b930f878645939c81b8e112220bb830b35adc5ccf9907f06de9249cc18460efb27347f1d90276a3225922417bab497cc5418551f2707cc4770d017cc8eecea9a7bff04af9af1d7f94cd124e61ca94667f311e552b5f432264fefc40c97b01d492dfd984acb1c7d13d542c6c25ed74b04bde42a602bf76d1dd2bd42c7fd863b8866f3c681c712103424b168c4113fdee7a8917ef55eb41288e513dd639	\N
5	6	Marc Hoffmann	1979-06-27	\\xc30d04070302b97dd4f54e1130a568d2c040011d7583b6ccd6978d3a63f61736263bd6549f141ef077b9432862ac409027b88e50968c303cb812a31d727d220b0b333d2c150705623d7c4c01fd587c4ecaa9be30760e869e6dc381eb11e801ebd0b2d2e6cb83b9b19859c298d514e9d2c2b1934616eaf00575436903069478446fd6bdfd8a3e541121ffcb3c458556af8e5878ac76fa91eb5cfb7a4b9a74d68897216d7ceff0017cb431ca5ef065a1b10a9ea0a0867206c39e39f31a01aeade6c244b4f4b99c1c8fc41f66525d073ab7753aa5de4d7d2b517fd9cfaed3a46cbaa0e06b506df7214e92e3d1cb57b6e07ccc2c443c7bcab9b8b29bf897ed61673345c3f35f4ef41265174b23b3165cc510861a	\N
6	7	Claire Meyer	1995-02-14	\\xc30d04070302afcf5a17e738e58b68d2c02e0115c413b03a134cea7341e3ddd4bd0b7b5ac66071ae4de394d1e6cd7cf64924c57c80f1d07069e37c11510eaaed262aa90c5537a48c22eaca24b86d3975e9a392d941c1f329231c3f1dfd6450d1acabdd116f9969c00b43493fd4ee837939064a7a3a073c2248c2de9712ee5a97fd5048f742e77debedfdd342d2704b82d722ee08ce21113e11d64981bdf442c7c43ed75754779ebb28668cf646ab001ade42fd6a49637d2bae7afef710cb6f59fe0269517e96250ada40d1ee93125e3b6b55cdf611a38f321fc7e7c0a242d3c49338965d82c23903faac017bdbf2dc0f0756a3cecfcca52d8f06fbb9caaa4883	\N
7	8	Anna Wagner	1983-09-03	\\xc30d04070302f40d725fc2f4515c7cd2c0210136c1fba377eead2e46185d86497db036f235ea2c05f08e5b71d05762134298253e1f5c61bb88fbc968dab2ecde59997237ca007f969c5447b214fd2da07f5db38d013e5fb80172c4af9f28202a0ea5fd5cc10a6a7b02eb10f8ec4c35c6ca5b018eff22c8c55e95b0e64d2f7011902c3d65b0f6a86a131af19b4410162b97d4d698130d0b05c76f0d10d7f0332a6b199c5b7df70c771b518ce72d51bea4bcdb8f13b892f6165d23450b9304711a6d74162ea6c8df64308088bffc587b81b52d415a7e56f4c6a3fd1fbb76493dc28c6b1c4b9c2803bf0302c21ab7ffc42914547d	\N
8	9	Tom Becker	1991-07-30	\\xc30d0407030259afa0812dcc04196fd2c034018c3854199b9118ba5fe93dedda4a1ddccaea249311812f780e43dcc0d78a75c2b040542b231e65e492c0a0d112b8231d3c9d45d4fd4263eebec245514f423de4e3dccec14e967ae591e79a2d5d221d71e22e1034e18eddf132ab5cddcd3c77b57ae5145af3450238b46339d92553631babbd523f277063ac5e9e1a135e82ab1973da5ded05f5943622039c12eae81707f6399e2e0bbd2c3a1d02e08967964baeb95808d9d937bdbaf74a4274ec62cd2a843598928516a99a6d189e0b8d630906007b5b2f0fbaa3d1dcff011e430745f7585c16f77e4122d178cb8dabec4304a85c1af811ed19575f4be6f08f59ca8e2b62e115	\N
9	10	Nina Hansen	2000-01-09	\\xc30d040703025a24db5837dc192e7ed2c02301b91dd814a1351ac1957f3374de47d1103d648a3064cd61d1eefda1dfeccacfb666ee69f3a97a4e6fab232983e4f96e83e42459448caad8c07a7e259b3297dddae2614105306019c47361e359f4c3f59387d99a4e8961555424519978fe1343fea39c37ad833a170d6691c8c2281447082775216da0afb8750e09b56856d58852b99622024c1697edabfcc74a88dcc35fb6eb7c88d6a43fb392cc6deddbc9cd765bc54d39f3c6ebc6429f9235cd07afa774a2cd8ec637db45b2495a247ab7fbced63ca2cc497e95a0b6da53e6b10b836c2b02132b73ce8510ddcaf555fa5848cd1e58	\N
10	11	Paul Frank	1986-05-21	\\xc30d040703022daf10c6beec5efa68d2c02101808aa71a237890843528a025941f9e8ab8808e1676f01bf61f489e992e3193b9389eee5ac3dc883b5f271f907217e18c7e5af21d6b55a295cde229ed4f8a9c656922802f5c0d582f2238906b88345ae536c86b24d752d4cc4173fba6eeae8ce1e17e700ae6de490bc2f6c21d4461bb01cee211cf0f258aa1b0b3ba1bcbad6161d04b90611133fe70fbf08bafbd3611fb57f0169c114eea869c8614f084d1b9e65988e7e05a02e32c3f43fbd9394732416a60477113518f281940858ff9963b8de48615d6f41f316ae67d92a7ca4057f3523cbe9d79d0ff49bcc57a667e725705	\N
\.


--
-- Data for Name: pharmacists; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.pharmacists (pharmacist_id, user_id, can_dispense) FROM stdin;
1	17	t
\.


--
-- Data for Name: prescriptions; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.prescriptions (prescription_id, record_id, patient_id, doctor_id, pharmacist_id, drug_name, dosage, frequency, status, created_at, dispensed_at) FROM stdin;
1	1	1	1	1	Amlodipine	5 mg	Once daily	issued	2025-12-15 14:19:57.031542	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: kranti
--

COPY public.users (user_id, username, password_hash, role, email, phone, created_at, last_login_at) FROM stdin;
1	admin1	hash_admin	admin	admin@clinic.com	+352271000000	2025-12-15 14:19:57.02503	\N
2	patient_john	hash_john	patient	john.miller@example.com	+352621000001	2025-12-15 14:19:57.02503	\N
3	patient_mary	hash_mary	patient	mary.johnson@example.com	+352621000002	2025-12-15 14:19:57.02503	\N
4	patient_luc	hash_luc	patient	luc.schmit@example.com	+352621000101	2025-12-15 14:19:57.02503	\N
5	patient_sophie	hash_sophie	patient	sophie.klein@example.com	+352621000102	2025-12-15 14:19:57.02503	\N
6	patient_marc	hash_marc	patient	marc.hoffmann@example.com	+352621000103	2025-12-15 14:19:57.02503	\N
7	patient_claire	hash_claire	patient	claire.meyer@example.com	+352621000104	2025-12-15 14:19:57.02503	\N
8	patient_anna	hash_anna_p	patient	anna.wagner@example.com	+352621000105	2025-12-15 14:19:57.02503	\N
9	patient_tom	hash_tom	patient	tom.becker@example.com	+352621000106	2025-12-15 14:19:57.02503	\N
10	patient_nina	hash_nina	patient	nina.hansen@example.com	+352621000107	2025-12-15 14:19:57.02503	\N
11	patient_paul	hash_paul	patient	paul.frank@example.com	+352621000108	2025-12-15 14:19:57.02503	\N
12	doctor_smith	hash_smith	doctor	smith@clinic.com	+352271000201	2025-12-15 14:19:57.02503	\N
13	doctor_brown	hash_brown	doctor	brown@clinic.com	+352271000202	2025-12-15 14:19:57.02503	\N
14	doctor_muller	hash_muller	doctor	muller@clinic.com	+352271000203	2025-12-15 14:19:57.02503	\N
15	doctor_fischer	hash_fischer	doctor	fischer@clinic.com	+352271000204	2025-12-15 14:19:57.02503	\N
16	doctor_schmit	hash_schmit	doctor	schmit@clinic.com	+352271000205	2025-12-15 14:19:57.02503	\N
17	pharm_anna	hash_pharm	pharmacist	anna@pharmacy.com	+352271000301	2025-12-15 14:19:57.02503	\N
18	system_bot	hash_system	system	\N	\N	2025-12-15 14:19:57.02503	\N
\.


--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.appointments_appointment_id_seq', 3, true);


--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.audit_logs_log_id_seq', 1, true);


--
-- Name: billing_billing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.billing_billing_id_seq', 1, true);


--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.doctors_doctor_id_seq', 5, true);


--
-- Name: medical_records_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.medical_records_record_id_seq', 3, true);


--
-- Name: patients_patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.patients_patient_id_seq', 10, true);


--
-- Name: pharmacists_pharmacist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.pharmacists_pharmacist_id_seq', 1, true);


--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.prescriptions_prescription_id_seq', 1, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kranti
--

SELECT pg_catalog.setval('public.users_user_id_seq', 18, true);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (log_id);


--
-- Name: billing billing_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_pkey PRIMARY KEY (billing_id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (doctor_id);


--
-- Name: doctors doctors_user_id_key; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_user_id_key UNIQUE (user_id);


--
-- Name: medical_records medical_records_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_pkey PRIMARY KEY (record_id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (patient_id);


--
-- Name: patients patients_user_id_key; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_user_id_key UNIQUE (user_id);


--
-- Name: pharmacists pharmacists_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.pharmacists
    ADD CONSTRAINT pharmacists_pkey PRIMARY KEY (pharmacist_id);


--
-- Name: pharmacists pharmacists_user_id_key; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.pharmacists
    ADD CONSTRAINT pharmacists_user_id_key UNIQUE (user_id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (prescription_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: appointments appointments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id);


--
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id) ON DELETE CASCADE;


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: billing billing_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE SET NULL;


--
-- Name: billing billing_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id) ON DELETE CASCADE;


--
-- Name: doctors doctors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: medical_records medical_records_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id) ON DELETE SET NULL;


--
-- Name: medical_records medical_records_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id) ON DELETE CASCADE;


--
-- Name: patients patients_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: pharmacists pharmacists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.pharmacists
    ADD CONSTRAINT pharmacists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_pharmacist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pharmacist_id_fkey FOREIGN KEY (pharmacist_id) REFERENCES public.pharmacists(pharmacist_id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kranti
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.medical_records(record_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict EGt9pnsE6PhHsfsNCCxp6ucM91iGEPgCqF0tSu4ODtgeX87copJLtILX2hwWvo7

