**Database Set-Up Medical Appointment and Records System.**

This repository is where we kept the PostgreSQL database scripts and helper file of the Medical Appointment and Records System which we applied in our project Database Security.

The database is called medicaldb; it represents a small healthcare clinic system, whose main feature is the emphasis on the secure data storage, access control, encryption, and backup.

**SQL Scripts**

01 createdatabase.sql
- This is the creation of the medicaldb.
- Gives the PostgreSQL superuser base privileges.

02_schema_data_checks.sql
- Drops by default (option) existing tables.
- Creates all schema objects: users, patients, doctors, pharmacists, appointments, medical_records, prescriptions, billing, audit_logs
		
03_Puts realistic sample data in:
10 patients
5 doctors
1 pharmacist
1 admin
appointments, medical records, prescription, billing, audit logs.Verification queries are at the end.

Values of what should be expected after execution:
users: 18
patients: 10
doctors: 5
pharmacists: 1
appointments: 10
medical_records: 10
prescriptions: 5
billing: 10
audit_logs: 3


05_roles_and_permissions.sql

Implements Role-Based Access Control (RBAC) and Row-Level Security (RLS).
PostgreSQL group roles:
1.role_patient
2.role_doctor
3.role_pharmacist
4.role_admin
5.role_system
-Default PUBLIC privileges are revoked.
-Least-privilege permissions are granted per role.
-Row-Level Security (RLS) is enabled on sensitive tables.
-Policies ensure users can access only their own data where applicable.
-A helper function sets session context for RLS enforcement.



**Security Features**

1.Access Control

-Implemented using PostgreSQL roles and privileges.

-Row-Level Security policies restrict access to rows based on user context.

-No direct table access for unauthorized roles.


2.Encryption at Rest

-Uses PostgreSQL pgcrypto extension.

-Sensitive fields are encrypted using symmetric encryption: medical_records.diagnosis, medical_records.treatment_notes, patients.contact_info

-Encryption uses pgp_sym_encrypt.

-Decryption requires an explicit key using pgp_sym_decrypt.

This ensures sensitive medical and personal data is unreadable at rest.


3.Backup & Recovery

-Logical backups are created using pg_dump.

Backup example:pg_dump medicaldb > backups/medicaldb_backup.sql

Restore example: psql medicaldb < backups/medicaldb_backup.sql

Backups preserve encrypted data and full schema structure.


**Demonstration**
A short video demonstrates:
Encrypted data stored in database tables
Controlled decryption using the correct encryption key
Role-based access restrictions
Backup creation and verification

No frontend or login page is included; all security is enforced at the database level.


**Prerequisites**

1.PostgreSQL 16 (or compatible version)

2.PostgreSQL superuser (e.g. postgres)

3.psql or pgAdmin 4


**Setup Instructions**

Step 1 – Create the database
Using psql: psql -U postgres -d postgres -f 01_create_database.sql

Using pgAdmin:
•Connect as superuser.
•Open Query Tool on database postgres.
•Execute 01_create_database.sql.

Step 2 – Create schema and insert data
•Connect to medicaldb and execute:
•02_schema_data_checks.sql


Step 3 – Apply access control

•Execute:05_roles_and_permissions.sql


Step 4 – Verify

Run the verification queries included in the scripts to confirm:
•Data is present
•Access restrictions are enforced
•Encrypted fields are unreadable without decryption



-This project focuses on database-level security, not application development.
-Authentication is simulated using PostgreSQL roles and session variables.
-The design follows security best practices covered in class.
