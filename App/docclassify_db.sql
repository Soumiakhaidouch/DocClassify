--
-- PostgreSQL database dump
--

\restrict TukKbFlFejCRUayvMw92yjMDmrqTfCuDOjX8mH5wwZcdCubq53q0n5fsMIPaQ1W

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: purge_expired_sessions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.purge_expired_sessions() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    deleted INTEGER;
BEGIN
    DELETE FROM sessions WHERE expires_at < NOW();
    GET DIAGNOSTICS deleted = ROW_COUNT;
    RETURN deleted;
END;
$$;


ALTER FUNCTION public.purge_expired_sessions() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    user_id integer,
    document_id integer,
    action character varying(50) NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    ip_address inet,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name_fr character varying(100) NOT NULL,
    name_ar character varying(100),
    slug character varying(50) NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: classification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classification (
    id integer NOT NULL,
    document_id integer NOT NULL,
    category_id integer,
    confidence numeric(5,4) NOT NULL,
    all_scores jsonb DEFAULT '{}'::jsonb NOT NULL,
    model_used character varying(100) DEFAULT 'xlm-roberta'::character varying NOT NULL,
    correct_category integer,
    classified_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT classification_confidence_check CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric)))
);


ALTER TABLE public.classification OWNER TO postgres;

--
-- Name: classification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classification_id_seq OWNER TO postgres;

--
-- Name: classification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classification_id_seq OWNED BY public.classification.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    user_id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    lang_detected character varying(10),
    char_count integer,
    token_count integer,
    is_chunked boolean DEFAULT false NOT NULL,
    upload_date timestamp with time zone DEFAULT now() NOT NULL,
    file_size bigint,
    content text,
    CONSTRAINT documents_file_size_check CHECK ((file_size >= 0)),
    CONSTRAINT documents_file_type_check CHECK (((file_type)::text = ANY ((ARRAY['pdf'::character varying, 'txt'::character varying, 'docx'::character varying, 'text'::character varying])::text[]))),
    CONSTRAINT documents_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'done'::character varying, 'error'::character varying])::text[])))
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id integer NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    ip_address inet,
    user_agent text
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(80) NOT NULL,
    email character varying(150) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_login timestamp with time zone,
    password_hash bytea
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
-- Name: v_category_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_category_stats AS
 SELECT cat.slug,
    cat.name_fr,
    cat.name_ar,
    d.lang_detected,
    count(*) AS total,
    avg(c.confidence) AS avg_confidence
   FROM ((public.classification c
     JOIN public.categories cat ON ((cat.id = c.category_id)))
     JOIN public.documents d ON ((d.id = c.document_id)))
  GROUP BY cat.slug, cat.name_fr, cat.name_ar, d.lang_detected;


ALTER VIEW public.v_category_stats OWNER TO postgres;

--
-- Name: v_document_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_document_summary AS
 SELECT d.id AS document_id,
    u.username,
    u.email,
    d.file_name,
    d.file_type,
    d.status,
    d.lang_detected,
    d.char_count,
    d.token_count,
    d.is_chunked,
    d.upload_date,
    c.confidence,
    cat.slug AS category_slug,
    cat.name_fr AS category_fr,
    cat.name_ar AS category_ar,
    c.model_used,
    c.classified_at
   FROM (((public.documents d
     JOIN public.users u ON ((d.user_id = u.id)))
     LEFT JOIN public.classification c ON ((c.document_id = d.id)))
     LEFT JOIN public.categories cat ON ((cat.id = c.category_id)));


ALTER VIEW public.v_document_summary OWNER TO postgres;

--
-- Name: v_user_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_user_stats AS
 SELECT u.id AS user_id,
    u.username,
    count(d.id) AS total_documents,
    count(d.id) FILTER (WHERE ((d.status)::text = 'done'::text)) AS classified_count,
    count(d.id) FILTER (WHERE ((d.status)::text = 'error'::text)) AS error_count,
    avg(c.confidence) AS avg_confidence,
    max(d.upload_date) AS last_upload
   FROM ((public.users u
     LEFT JOIN public.documents d ON ((d.user_id = u.id)))
     LEFT JOIN public.classification c ON ((c.document_id = d.id)))
  GROUP BY u.id, u.username;


ALTER VIEW public.v_user_stats OWNER TO postgres;

--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: classification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification ALTER COLUMN id SET DEFAULT nextval('public.classification_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_fr_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_fr_key UNIQUE (name_fr);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: classification classification_document_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification
    ADD CONSTRAINT classification_document_id_key UNIQUE (document_id);


--
-- Name: classification classification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification
    ADD CONSTRAINT classification_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_token_hash_key UNIQUE (token_hash);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_action ON public.audit_logs USING btree (action);


--
-- Name: idx_audit_details; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_details ON public.audit_logs USING gin (details);


--
-- Name: idx_audit_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_document_id ON public.audit_logs USING btree (document_id);


--
-- Name: idx_audit_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_timestamp ON public.audit_logs USING btree ("timestamp" DESC);


--
-- Name: idx_audit_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: idx_classification_all_scores; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classification_all_scores ON public.classification USING gin (all_scores);


--
-- Name: idx_classification_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classification_category_id ON public.classification USING btree (category_id);


--
-- Name: idx_classification_classified_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classification_classified_at ON public.classification USING btree (classified_at DESC);


--
-- Name: idx_classification_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classification_document_id ON public.classification USING btree (document_id);


--
-- Name: idx_documents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_status ON public.documents USING btree (status);


--
-- Name: idx_documents_upload_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_upload_date ON public.documents USING btree (upload_date DESC);


--
-- Name: idx_documents_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_user_id ON public.documents USING btree (user_id);


--
-- Name: idx_sessions_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_expires_at ON public.sessions USING btree (expires_at);


--
-- Name: idx_sessions_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_token_hash ON public.sessions USING btree (token_hash);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: audit_logs audit_logs_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: classification classification_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification
    ADD CONSTRAINT classification_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: classification classification_correct_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification
    ADD CONSTRAINT classification_correct_category_fkey FOREIGN KEY (correct_category) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: classification classification_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classification
    ADD CONSTRAINT classification_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: documents documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict TukKbFlFejCRUayvMw92yjMDmrqTfCuDOjX8mH5wwZcdCubq53q0n5fsMIPaQ1W

