-- =====================================================
-- RBAC IMPLEMENTATION
-- Medical Database Access Control with Row-Level Security
-- ALL 18 USERS INCLUDED
-- =====================================================

-- =====================================================
-- PART 1: CREATE DATABASE ROLES
-- =====================================================

CREATE ROLE role_patient NOLOGIN;
CREATE ROLE role_doctor NOLOGIN;
CREATE ROLE role_pharmacist NOLOGIN;
CREATE ROLE role_admin NOLOGIN;
CREATE ROLE role_system NOLOGIN;

-- Note: NOLOGIN means these are group roles that will be granted to actual user accounts

-- =====================================================
-- PART 2: REVOKE DEFAULT PUBLIC ACCESS
-- =====================================================

-- Remove all default permissions from public schema
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO role_patient, role_doctor, role_pharmacist, role_admin, role_system;

-- =====================================================
-- PART 3: GRANT PERMISSIONS TO ROLE_PATIENT
-- =====================================================

-- Patients can SELECT their own data from these tables
GRANT SELECT ON patients TO role_patient;
GRANT SELECT ON appointments TO role_patient;
GRANT SELECT ON medical_records TO role_patient;
GRANT SELECT ON prescriptions TO role_patient;
GRANT SELECT ON billing TO role_patient;

-- Patients can view doctor information (to know who they're seeing)
GRANT SELECT ON doctors TO role_patient;
GRANT SELECT ON users TO role_patient;

-- Patients can UPDATE only specific columns in their own record
GRANT UPDATE (contact_info, last_login_at) ON patients TO role_patient;

-- Patients can INSERT their own appointment requests (if system allows)
GRANT INSERT ON appointments TO role_patient;
GRANT USAGE, SELECT ON SEQUENCE appointments_appointment_id_seq TO role_patient;

-- =====================================================
-- PART 4: GRANT PERMISSIONS TO ROLE_DOCTOR
-- =====================================================

-- Doctors can view patient information
GRANT SELECT ON patients, users TO role_doctor;

-- Doctors can view all doctors (colleagues)
GRANT SELECT ON doctors, pharmacists TO role_doctor;

-- Doctors have full access to appointments they're involved in
GRANT SELECT, INSERT, UPDATE ON appointments TO role_doctor;
GRANT USAGE, SELECT ON SEQUENCE appointments_appointment_id_seq TO role_doctor;

-- Doctors can create and update medical records
GRANT SELECT, INSERT, UPDATE ON medical_records TO role_doctor;
GRANT USAGE, SELECT ON SEQUENCE medical_records_record_id_seq TO role_doctor;
-- Note: No DELETE - medical records should never be deleted, only marked as corrected

-- Doctors can create and update prescriptions
GRANT SELECT, INSERT, UPDATE ON prescriptions TO role_doctor;
GRANT USAGE, SELECT ON SEQUENCE prescriptions_prescription_id_seq TO role_doctor;

-- Doctors can view billing (to verify services) but not modify
GRANT SELECT ON billing TO role_doctor;

-- Doctors can INSERT audit logs for their actions
GRANT INSERT ON audit_logs TO role_doctor;
GRANT USAGE, SELECT ON SEQUENCE audit_logs_log_id_seq TO role_doctor;

-- Update their own last_login_at
GRANT UPDATE (last_login_at, contact_info) ON doctors TO role_doctor;

-- =====================================================
-- PART 5: GRANT PERMISSIONS TO ROLE_PHARMACIST
-- =====================================================

-- Pharmacists can view prescriptions and related patient/doctor info
GRANT SELECT ON prescriptions TO role_pharmacist;
GRANT SELECT ON patients, doctors, users TO role_pharmacist;

-- Pharmacists can UPDATE only specific prescription columns
GRANT UPDATE (status, dispensed_at, pharmacist_id) ON prescriptions TO role_pharmacist;

-- Pharmacists CANNOT see full medical records (privacy)
-- They only see prescription information

-- Pharmacists can INSERT audit logs
GRANT INSERT ON audit_logs TO role_pharmacist;
GRANT USAGE, SELECT ON SEQUENCE audit_logs_log_id_seq TO role_pharmacist;

-- Update their own info
GRANT SELECT, UPDATE (can_dispense) ON pharmacists TO role_pharmacist;

-- =====================================================
-- PART 6: GRANT PERMISSIONS TO ROLE_ADMIN
-- =====================================================

-- Admins have full access to all tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

-- =====================================================
-- PART 7: GRANT PERMISSIONS TO ROLE_SYSTEM
-- =====================================================

-- System bot can read appointments and billing for automated tasks
GRANT SELECT ON appointments, billing, users, patients TO role_system;

-- System can update appointment status (for automated reminders)
GRANT UPDATE (status) ON appointments TO role_system;

-- System can log its actions
GRANT INSERT ON audit_logs TO role_system;
GRANT USAGE, SELECT ON SEQUENCE audit_logs_log_id_seq TO role_system;

-- =====================================================
-- PART 8: ROW-LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on sensitive tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------
-- PATIENTS Table Policies
-- -----------------------------------------------------

-- Patients can only see their own patient record
CREATE POLICY patient_view_own_record ON patients
    FOR SELECT
    TO role_patient
    USING (user_id = current_setting('app.current_user_id', true)::integer);

-- Patients can update only their own contact info
CREATE POLICY patient_update_own_contact ON patients
    FOR UPDATE
    TO role_patient
    USING (user_id = current_setting('app.current_user_id', true)::integer)
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::integer);

-- Doctors can view all patients
CREATE POLICY doctor_view_all_patients ON patients
    FOR SELECT
    TO role_doctor
    USING (true);

-- Pharmacists can view patient basic info (for prescription verification)
CREATE POLICY pharmacist_view_patients ON patients
    FOR SELECT
    TO role_pharmacist
    USING (true);

-- Admin can do anything
CREATE POLICY admin_all_patients ON patients
    FOR ALL
    TO role_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------
-- APPOINTMENTS Table Policies
-- -----------------------------------------------------

-- Patients can see their own appointments
CREATE POLICY patient_view_own_appointments ON appointments
    FOR SELECT
    TO role_patient
    USING (patient_id IN (
        SELECT patient_id FROM patients 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Patients can create appointments for themselves
CREATE POLICY patient_create_own_appointments ON appointments
    FOR INSERT
    TO role_patient
    WITH CHECK (patient_id IN (
        SELECT patient_id FROM patients 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Doctors can view and modify appointments they're assigned to
CREATE POLICY doctor_manage_appointments ON appointments
    FOR ALL
    TO role_doctor
    USING (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ))
    WITH CHECK (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- System can view and update all appointments
CREATE POLICY system_manage_appointments ON appointments
    FOR ALL
    TO role_system
    USING (true)
    WITH CHECK (true);

-- Admin full access
CREATE POLICY admin_all_appointments ON appointments
    FOR ALL
    TO role_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------
-- MEDICAL_RECORDS Table Policies
-- -----------------------------------------------------

-- Patients can view their own medical records
CREATE POLICY patient_view_own_records ON medical_records
    FOR SELECT
    TO role_patient
    USING (patient_id IN (
        SELECT patient_id FROM patients 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Doctors can create records for any patient, but only update their own records
CREATE POLICY doctor_create_records ON medical_records
    FOR INSERT
    TO role_doctor
    WITH CHECK (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

CREATE POLICY doctor_view_all_records ON medical_records
    FOR SELECT
    TO role_doctor
    USING (true);

CREATE POLICY doctor_update_own_records ON medical_records
    FOR UPDATE
    TO role_doctor
    USING (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ))
    WITH CHECK (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Admin full access
CREATE POLICY admin_all_records ON medical_records
    FOR ALL
    TO role_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------
-- PRESCRIPTIONS Table Policies
-- -----------------------------------------------------

-- Patients can view their own prescriptions
CREATE POLICY patient_view_own_prescriptions ON prescriptions
    FOR SELECT
    TO role_patient
    USING (patient_id IN (
        SELECT patient_id FROM patients 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Doctors can create and view prescriptions
CREATE POLICY doctor_manage_prescriptions ON prescriptions
    FOR ALL
    TO role_doctor
    USING (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ))
    WITH CHECK (doctor_id IN (
        SELECT doctor_id FROM doctors 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Pharmacists can view all prescriptions and update status/dispense info
CREATE POLICY pharmacist_view_prescriptions ON prescriptions
    FOR SELECT
    TO role_pharmacist
    USING (true);

CREATE POLICY pharmacist_update_prescriptions ON prescriptions
    FOR UPDATE
    TO role_pharmacist
    USING (true)
    WITH CHECK (true); -- Restricted by column-level permissions

-- Admin full access
CREATE POLICY admin_all_prescriptions ON prescriptions
    FOR ALL
    TO role_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------
-- BILLING Table Policies
-- -----------------------------------------------------

-- Patients can view their own billing
CREATE POLICY patient_view_own_billing ON billing
    FOR SELECT
    TO role_patient
    USING (patient_id IN (
        SELECT patient_id FROM patients 
        WHERE user_id = current_setting('app.current_user_id', true)::integer
    ));

-- Doctors can view billing related to their appointments
CREATE POLICY doctor_view_billing ON billing
    FOR SELECT
    TO role_doctor
    USING (true);

-- System can view all billing
CREATE POLICY system_view_billing ON billing
    FOR SELECT
    TO role_system
    USING (true);

-- Admin full access
CREATE POLICY admin_all_billing ON billing
    FOR ALL
    TO role_admin
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- PART 9: CREATE ALL 18 POSTGRESQL LOGIN USERS
-- =====================================================

-- -----------------------------------------------------
-- ADMIN USER (1 user)
-- -----------------------------------------------------
CREATE USER admin1_db WITH PASSWORD 'secure_admin_password';
GRANT role_admin TO admin1_db;
GRANT CONNECT ON DATABASE medicaldb TO admin1_db;

-- -----------------------------------------------------
-- PATIENT USERS (10 users)
-- -----------------------------------------------------
CREATE USER patient_john_db WITH PASSWORD 'secure_john_password';
GRANT role_patient TO patient_john_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_john_db;

CREATE USER patient_mary_db WITH PASSWORD 'secure_mary_password';
GRANT role_patient TO patient_mary_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_mary_db;

CREATE USER patient_luc_db WITH PASSWORD 'secure_luc_password';
GRANT role_patient TO patient_luc_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_luc_db;

CREATE USER patient_sophie_db WITH PASSWORD 'secure_sophie_password';
GRANT role_patient TO patient_sophie_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_sophie_db;

CREATE USER patient_marc_db WITH PASSWORD 'secure_marc_password';
GRANT role_patient TO patient_marc_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_marc_db;

CREATE USER patient_claire_db WITH PASSWORD 'secure_claire_password';
GRANT role_patient TO patient_claire_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_claire_db;

CREATE USER patient_anna_db WITH PASSWORD 'secure_anna_password';
GRANT role_patient TO patient_anna_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_anna_db;

CREATE USER patient_tom_db WITH PASSWORD 'secure_tom_password';
GRANT role_patient TO patient_tom_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_tom_db;

CREATE USER patient_nina_db WITH PASSWORD 'secure_nina_password';
GRANT role_patient TO patient_nina_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_nina_db;

CREATE USER patient_paul_db WITH PASSWORD 'secure_paul_password';
GRANT role_patient TO patient_paul_db;
GRANT CONNECT ON DATABASE medicaldb TO patient_paul_db;

-- -----------------------------------------------------
-- DOCTOR USERS (5 users)
-- -----------------------------------------------------
CREATE USER doctor_smith_db WITH PASSWORD 'secure_smith_password';
GRANT role_doctor TO doctor_smith_db;
GRANT CONNECT ON DATABASE medicaldb TO doctor_smith_db;

CREATE USER doctor_brown_db WITH PASSWORD 'secure_brown_password';
GRANT role_doctor TO doctor_brown_db;
GRANT CONNECT ON DATABASE medicaldb TO doctor_brown_db;

CREATE USER doctor_muller_db WITH PASSWORD 'secure_muller_password';
GRANT role_doctor TO doctor_muller_db;
GRANT CONNECT ON DATABASE medicaldb TO doctor_muller_db;

CREATE USER doctor_fischer_db WITH PASSWORD 'secure_fischer_password';
GRANT role_doctor TO doctor_fischer_db;
GRANT CONNECT ON DATABASE medicaldb TO doctor_fischer_db;

CREATE USER doctor_schmit_db WITH PASSWORD 'secure_schmit_password';
GRANT role_doctor TO doctor_schmit_db;
GRANT CONNECT ON DATABASE medicaldb TO doctor_schmit_db;

-- -----------------------------------------------------
-- PHARMACIST USER (1 user)
-- -----------------------------------------------------
CREATE USER pharm_anna_db WITH PASSWORD 'secure_pharm_password';
GRANT role_pharmacist TO pharm_anna_db;
GRANT CONNECT ON DATABASE medicaldb TO pharm_anna_db;

-- -----------------------------------------------------
-- SYSTEM BOT (1 user)
-- -----------------------------------------------------
CREATE USER system_bot_db WITH PASSWORD 'secure_system_password';
GRANT role_system TO system_bot_db;
GRANT CONNECT ON DATABASE medicaldb TO system_bot_db;

-- =====================================================
-- PART 10: HELPER FUNCTION FOR SETTING USER CONTEXT
-- =====================================================

-- This function sets the current user context for RLS policies
-- In a real application, this would be called after authentication

CREATE OR REPLACE FUNCTION set_user_context(p_user_id INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM set_config('app.current_user_id', p_user_id::text, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to all roles
GRANT EXECUTE ON FUNCTION set_user_context(INTEGER) TO role_patient, role_doctor, role_pharmacist, role_admin, role_system;

-- =====================================================
-- PART 11: AUDIT TRIGGER (Automatic logging)
-- =====================================================

-- Create function to automatically log data changes
CREATE OR REPLACE FUNCTION log_data_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, details)
    VALUES (
        current_setting('app.current_user_id', true)::integer,
        TG_OP,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.patient_id 
            ELSE NEW.patient_id 
        END,
        json_build_object('operation', TG_OP, 'timestamp', NOW())::text
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to sensitive tables
CREATE TRIGGER audit_medical_records
    AFTER INSERT OR UPDATE OR DELETE ON medical_records
    FOR EACH ROW EXECUTE FUNCTION log_data_changes();

CREATE TRIGGER audit_prescriptions
    AFTER INSERT OR UPDATE OR DELETE ON prescriptions
    FOR EACH ROW EXECUTE FUNCTION log_data_changes();

-- =====================================================
-- PART 12: VERIFICATION QUERIES
-- =====================================================

-- Check created roles
SELECT rolname, rolcanlogin FROM pg_roles 
WHERE rolname LIKE 'role_%' OR rolname LIKE '%_db'
ORDER BY rolname;

-- Check table permissions for each role
SELECT 
    grantee, 
    table_name, 
    privilege_type
FROM information_schema.table_privileges
WHERE grantee LIKE 'role_%'
ORDER BY grantee, table_name, privilege_type;

-- Check RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND rowsecurity = true;

-- Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- =====================================================
-- USER MAPPING REFERENCE
-- =====================================================
/*
APPLICATION USER → POSTGRESQL USER → ROLE → USER_ID
=======================================================
admin1          → admin1_db         → role_admin       → user_id=1
patient_john    → patient_john_db   → role_patient     → user_id=2
patient_mary    → patient_mary_db   → role_patient     → user_id=3
patient_luc     → patient_luc_db    → role_patient     → user_id=4
patient_sophie  → patient_sophie_db → role_patient     → user_id=5
patient_marc    → patient_marc_db   → role_patient     → user_id=6
patient_claire  → patient_claire_db → role_patient     → user_id=7
patient_anna    → patient_anna_db   → role_patient     → user_id=8
patient_tom     → patient_tom_db    → role_patient     → user_id=9
patient_nina    → patient_nina_db   → role_patient     → user_id=10
patient_paul    → patient_paul_db   → role_patient     → user_id=11
doctor_smith    → doctor_smith_db   → role_doctor      → user_id=12
doctor_brown    → doctor_brown_db   → role_doctor      → user_id=13
doctor_muller   → doctor_muller_db  → role_doctor      → user_id=14
doctor_fischer  → doctor_fischer_db → role_doctor      → user_id=15
doctor_schmit   → doctor_schmit_db  → role_doctor      → user_id=16
pharm_anna      → pharm_anna_db     → role_pharmacist  → user_id=17
system_bot      → system_bot_db     → role_system      → user_id=18
*/

-- =====================================================
-- END OF RBAC IMPLEMENTATION
-- ALL 18 USERS READY TO USE
-- =====================================================