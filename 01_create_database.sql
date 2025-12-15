-- 01_create_database.sql
-- Creates an empty database named medicaldb.
-- Run this while connected to the "postgres" database.

-- OPTIONAL: uncomment next line if you want to drop an old DB first
-- DROP DATABASE IF EXISTS medicaldb;

CREATE DATABASE medicaldb
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Basic privileges. More fine-grained RBAC will be added later in a separate script.
GRANT TEMPORARY, CONNECT ON DATABASE medicaldb TO PUBLIC;
GRANT ALL ON DATABASE medicaldb TO postgres;

-- If roles member1/member2/member3 exist on the target system,
-- you can optionally grant them connect:
-- GRANT CONNECT ON DATABASE medicaldb TO member1;
-- GRANT CONNECT ON DATABASE medicaldb TO member2;
-- GRANT CONNECT ON DATABASE medicaldb TO member3;

