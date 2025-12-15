Medical Appointment & Records System – Database Setup

This repository contains the PostgreSQL database scripts and helper files for the Medical Appointment & Records System used in our Database Security project.

The database is called medicaldb and models:

Users and roles (patients, doctors, pharmacist, admin)

Patients and doctors

Appointments and medical records

Prescriptions

Billing

Simple audit logs

1. Files in this package

SQL scripts

01_create_database.sql

Creates an empty database medicaldb.

Grants basic privileges to postgres (and optionally to project members).

02_schema_data_checks.sql

Drops existing tables (commented out by default).

Creates all tables: users, patients, doctors, pharmacists, appointments, medical_records, prescriptions, billing, audit_logs.

Inserts realistic sample data (10 patients, 5 doctors, 1 pharmacist, 1 admin, appointments, records, prescriptions, billing, audit entries).

Contains a set of SELECT queries at the end to quickly verify data and relationships.

Other project files (if present)

02_erd_diagram.png – ERD-style diagram of the schema.

05_roles_and_permissions.sql – Access control / RBAC script (for Part 4 of the project).

2. Prerequisites

PostgreSQL 16 (or compatible PostgreSQL version).

A database superuser account (usually postgres).

pgAdmin 4 or access to the psql command-line client.

The steps below work both on Linux and Windows as long as PostgreSQL is installed.



3. How to create and load the database
Step 1 – Create the empty database

Option A – Using pgAdmin

-Connect to your PostgreSQL server as a superuser (e.g. postgres).
-Open Query Tool on database postgres (not medicaldb).
-Open the file 01_create_database.sql and execute it.
-You should now see a new database medicaldb under Databases.

Option B – Using psql

	psql -U postgres -d postgres -f 01_create_database.sql

Step 2 – Create tables and insert sample data

Connect to the medicaldb database:
-In pgAdmin: right-click medicaldb → Connect → Query Tool.
-In psql: psql -U postgres -d medicaldb.

Open and execute 02_schema_data_checks.sql PART_1 and PART_2

The script will:

-(Optionally) drop old tables if you uncomment the DROP TABLE lines at the top.
-Create all schema objects.
-Insert sample users, patients, doctors, appointments, medical records, prescriptions, billing, and audit logs.

Step 3 - Quick checks
use PART_3 to Run a set of SELECT queries at the end to verify the counts and relationships.




Expected values:
-users: 17
-patients: 10
-doctors: 5
-pharmacists: 1
-appointments: 10
-medical_records: 10
-prescriptions: 5
-billing: 10
-audit_logs: 3

You can also run the other queries in the script to inspect:

-Appointments joined with patients and doctors
-Medical records joined with patients
-Billing entries per patient
-Audit logs with actor usernames
