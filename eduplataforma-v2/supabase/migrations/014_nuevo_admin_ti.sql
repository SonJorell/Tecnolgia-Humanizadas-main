-- ═══════════════════════════════════
-- 014_nuevo_admin_ti.sql
-- EduPlataforma v2.0
-- Crear un nuevo usuario administrador TI
-- ═══════════════════════════════════

DO $$
DECLARE
  v_new_ti_id UUID := gen_random_uuid();
BEGIN
  -- Insertar un usuario TI completamente nuevo para evitar conflictos con el anterior
  INSERT INTO auth.users (
    id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
  ) VALUES (
    v_new_ti_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin.ti@escuela.cl', 
    crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
    '{"provider":"email","providers":["email"]}', '{"email_verified":true}', false
  );

  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
  VALUES (
    v_new_ti_id, v_new_ti_id, 
    json_build_object('sub', v_new_ti_id, 'email', 'admin.ti@escuela.cl', 'email_verified', true), 
    'email', v_new_ti_id, current_timestamp, current_timestamp, current_timestamp
  );

  INSERT INTO public.perfiles (id, nombre, rol, xp, monedas, nivel)
  VALUES (v_new_ti_id, 'Admin TI Principal', 'ti', 0, 0, 1);
  
END $$;
