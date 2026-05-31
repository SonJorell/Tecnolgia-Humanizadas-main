-- ═══════════════════════════════════
-- 008_sync_auth_users.sql
-- Sincroniza cuentas desde el CSV a auth.users con clave prueba123
-- ═══════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;


INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '07ea08e6-b256-4cdd-ba2f-1e153908e6f2', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'jorell.ia@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '07ea08e6-b256-4cdd-ba2f-1e153908e6f2', '07ea08e6-b256-4cdd-ba2f-1e153908e6f2', 
  json_build_object('sub', '07ea08e6-b256-4cdd-ba2f-1e153908e6f2', 'email', 'jorell.ia@escuela.cl', 'email_verified', false), 
  'email', '07ea08e6-b256-4cdd-ba2f-1e153908e6f2', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '0813b731-7cea-4a91-8b54-bf8b64345016', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'yerko.mt@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '0813b731-7cea-4a91-8b54-bf8b64345016', '0813b731-7cea-4a91-8b54-bf8b64345016', 
  json_build_object('sub', '0813b731-7cea-4a91-8b54-bf8b64345016', 'email', 'yerko.mt@escuela.cl', 'email_verified', false), 
  'email', '0813b731-7cea-4a91-8b54-bf8b64345016', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '0baf7a02-599e-4b8d-84e8-669d94cf187d', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'patricio.ma@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '0baf7a02-599e-4b8d-84e8-669d94cf187d', '0baf7a02-599e-4b8d-84e8-669d94cf187d', 
  json_build_object('sub', '0baf7a02-599e-4b8d-84e8-669d94cf187d', 'email', 'patricio.ma@escuela.cl', 'email_verified', false), 
  'email', '0baf7a02-599e-4b8d-84e8-669d94cf187d', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '1e090a63-9e0c-4fa4-84c1-155f6f6e822e', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'roberto.vv@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '1e090a63-9e0c-4fa4-84c1-155f6f6e822e', '1e090a63-9e0c-4fa4-84c1-155f6f6e822e', 
  json_build_object('sub', '1e090a63-9e0c-4fa4-84c1-155f6f6e822e', 'email', 'roberto.vv@escuela.cl', 'email_verified', false), 
  'email', '1e090a63-9e0c-4fa4-84c1-155f6f6e822e', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '2351e10e-96a9-477d-aff0-98e7bc6b2fe2', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'tamara.qm@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '2351e10e-96a9-477d-aff0-98e7bc6b2fe2', '2351e10e-96a9-477d-aff0-98e7bc6b2fe2', 
  json_build_object('sub', '2351e10e-96a9-477d-aff0-98e7bc6b2fe2', 'email', 'tamara.qm@escuela.cl', 'email_verified', false), 
  'email', '2351e10e-96a9-477d-aff0-98e7bc6b2fe2', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '3127d0fc-c301-4aed-8ba9-2b5fefaffda9', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dairk.cd@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '3127d0fc-c301-4aed-8ba9-2b5fefaffda9', '3127d0fc-c301-4aed-8ba9-2b5fefaffda9', 
  json_build_object('sub', '3127d0fc-c301-4aed-8ba9-2b5fefaffda9', 'email', 'dairk.cd@escuela.cl', 'email_verified', false), 
  'email', '3127d0fc-c301-4aed-8ba9-2b5fefaffda9', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '319b7364-7f5d-4b25-a6e1-2ac1db8529e1', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'leandro.fg@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '319b7364-7f5d-4b25-a6e1-2ac1db8529e1', '319b7364-7f5d-4b25-a6e1-2ac1db8529e1', 
  json_build_object('sub', '319b7364-7f5d-4b25-a6e1-2ac1db8529e1', 'email', 'leandro.fg@escuela.cl', 'email_verified', false), 
  'email', '319b7364-7f5d-4b25-a6e1-2ac1db8529e1', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '319cb754-382a-4cc2-9dec-9f25a34423c2', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'benjamin.af@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '319cb754-382a-4cc2-9dec-9f25a34423c2', '319cb754-382a-4cc2-9dec-9f25a34423c2', 
  json_build_object('sub', '319cb754-382a-4cc2-9dec-9f25a34423c2', 'email', 'benjamin.af@escuela.cl', 'email_verified', false), 
  'email', '319cb754-382a-4cc2-9dec-9f25a34423c2', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '399cf444-ee2d-4d3d-b9db-eff394eedf32', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'brandon.os@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '399cf444-ee2d-4d3d-b9db-eff394eedf32', '399cf444-ee2d-4d3d-b9db-eff394eedf32', 
  json_build_object('sub', '399cf444-ee2d-4d3d-b9db-eff394eedf32', 'email', 'brandon.os@escuela.cl', 'email_verified', false), 
  'email', '399cf444-ee2d-4d3d-b9db-eff394eedf32', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '3f9a494e-0b90-4f84-898b-66efae34413b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.mate@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '3f9a494e-0b90-4f84-898b-66efae34413b', '3f9a494e-0b90-4f84-898b-66efae34413b', 
  json_build_object('sub', '3f9a494e-0b90-4f84-898b-66efae34413b', 'email', 'profesor.mate@escuela.cl', 'email_verified', false), 
  'email', '3f9a494e-0b90-4f84-898b-66efae34413b', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '427ed827-1e4a-4447-a134-40b5543a80ae', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'axel.fp@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '427ed827-1e4a-4447-a134-40b5543a80ae', '427ed827-1e4a-4447-a134-40b5543a80ae', 
  json_build_object('sub', '427ed827-1e4a-4447-a134-40b5543a80ae', 'email', 'axel.fp@escuela.cl', 'email_verified', false), 
  'email', '427ed827-1e4a-4447-a134-40b5543a80ae', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '464f5477-a9ae-4482-8716-3c0262b300f8', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'miguel.os@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '464f5477-a9ae-4482-8716-3c0262b300f8', '464f5477-a9ae-4482-8716-3c0262b300f8', 
  json_build_object('sub', '464f5477-a9ae-4482-8716-3c0262b300f8', 'email', 'miguel.os@escuela.cl', 'email_verified', false), 
  'email', '464f5477-a9ae-4482-8716-3c0262b300f8', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '4aa66fea-ec8c-4ce5-b2b8-421b0da2ee8f', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'camilo.sf@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '4aa66fea-ec8c-4ce5-b2b8-421b0da2ee8f', '4aa66fea-ec8c-4ce5-b2b8-421b0da2ee8f', 
  json_build_object('sub', '4aa66fea-ec8c-4ce5-b2b8-421b0da2ee8f', 'email', 'camilo.sf@escuela.cl', 'email_verified', false), 
  'email', '4aa66fea-ec8c-4ce5-b2b8-421b0da2ee8f', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '4fc32de6-da28-488b-a941-d64581482d0a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'jorell@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '4fc32de6-da28-488b-a941-d64581482d0a', '4fc32de6-da28-488b-a941-d64581482d0a', 
  json_build_object('sub', '4fc32de6-da28-488b-a941-d64581482d0a', 'email', 'jorell@escuela.cl', 'email_verified', false), 
  'email', '4fc32de6-da28-488b-a941-d64581482d0a', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '66168a47-081f-4e3f-95af-c9c60715477b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mauricio.cc@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '66168a47-081f-4e3f-95af-c9c60715477b', '66168a47-081f-4e3f-95af-c9c60715477b', 
  json_build_object('sub', '66168a47-081f-4e3f-95af-c9c60715477b', 'email', 'mauricio.cc@escuela.cl', 'email_verified', false), 
  'email', '66168a47-081f-4e3f-95af-c9c60715477b', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '68e6b66c-7d53-4358-a1c2-0cbd57b1d81b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ashley.ag@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '68e6b66c-7d53-4358-a1c2-0cbd57b1d81b', '68e6b66c-7d53-4358-a1c2-0cbd57b1d81b', 
  json_build_object('sub', '68e6b66c-7d53-4358-a1c2-0cbd57b1d81b', 'email', 'ashley.ag@escuela.cl', 'email_verified', false), 
  'email', '68e6b66c-7d53-4358-a1c2-0cbd57b1d81b', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '78adc682-f4b2-4ec1-af0e-fd7785d77dd6', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sebastian.av@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '78adc682-f4b2-4ec1-af0e-fd7785d77dd6', '78adc682-f4b2-4ec1-af0e-fd7785d77dd6', 
  json_build_object('sub', '78adc682-f4b2-4ec1-af0e-fd7785d77dd6', 'email', 'sebastian.av@escuela.cl', 'email_verified', false), 
  'email', '78adc682-f4b2-4ec1-af0e-fd7785d77dd6', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '93a4b318-e64f-44e0-b1d3-07c0d30c3a72', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'issel.cp@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '93a4b318-e64f-44e0-b1d3-07c0d30c3a72', '93a4b318-e64f-44e0-b1d3-07c0d30c3a72', 
  json_build_object('sub', '93a4b318-e64f-44e0-b1d3-07c0d30c3a72', 'email', 'issel.cp@escuela.cl', 'email_verified', false), 
  'email', '93a4b318-e64f-44e0-b1d3-07c0d30c3a72', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '9def1d3f-9ad7-47c2-ae03-d02867e3f5c3', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'nicolas.ph@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '9def1d3f-9ad7-47c2-ae03-d02867e3f5c3', '9def1d3f-9ad7-47c2-ae03-d02867e3f5c3', 
  json_build_object('sub', '9def1d3f-9ad7-47c2-ae03-d02867e3f5c3', 'email', 'nicolas.ph@escuela.cl', 'email_verified', false), 
  'email', '9def1d3f-9ad7-47c2-ae03-d02867e3f5c3', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maria@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000001', 'email', 'maria@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000001', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'pedro@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000002', 'email', 'pedro@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000002', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ana@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000003', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000003', 'email', 'ana@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000003', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'diego@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000004', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000004', 'email', 'diego@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000004', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sofia@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000005', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000005', 'email', 'sofia@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000005', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'valentina@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000006', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000006', 'email', 'valentina@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000006', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'martin@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000007', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000007', 'email', 'martin@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000007', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'camila@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000008', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000008', 'email', 'camila@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000008', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'benjamin@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000009', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000009', 'email', 'benjamin@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000009', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'antonia@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000010', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000010', 'email', 'antonia@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000010', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'lucas@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000011', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000011', 'email', 'lucas@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000011', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'isabella@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000012', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000012', 'email', 'isabella@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000012', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mateo@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000013', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000013', 'email', 'mateo@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000013', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a0000000-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'emilia@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000014', 
  json_build_object('sub', 'a0000000-0000-0000-0000-000000000014', 'email', 'emilia@escuela.cl', 'email_verified', false), 
  'email', 'a0000000-0000-0000-0000-000000000014', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'a970e8c9-cb6d-4f1a-a307-bd6d5d7576a0', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'brayan.oc@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'a970e8c9-cb6d-4f1a-a307-bd6d5d7576a0', 'a970e8c9-cb6d-4f1a-a307-bd6d5d7576a0', 
  json_build_object('sub', 'a970e8c9-cb6d-4f1a-a307-bd6d5d7576a0', 'email', 'brayan.oc@escuela.cl', 'email_verified', false), 
  'email', 'a970e8c9-cb6d-4f1a-a307-bd6d5d7576a0', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'b0243951-bce4-49a8-abec-f0a698bf55b5', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sebastian.lm@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'b0243951-bce4-49a8-abec-f0a698bf55b5', 'b0243951-bce4-49a8-abec-f0a698bf55b5', 
  json_build_object('sub', 'b0243951-bce4-49a8-abec-f0a698bf55b5', 'email', 'sebastian.lm@escuela.cl', 'email_verified', false), 
  'email', 'b0243951-bce4-49a8-abec-f0a698bf55b5', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'b2aef22b-93ff-48ee-8889-109ea305aebe', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'claudio.tz@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'b2aef22b-93ff-48ee-8889-109ea305aebe', 'b2aef22b-93ff-48ee-8889-109ea305aebe', 
  json_build_object('sub', 'b2aef22b-93ff-48ee-8889-109ea305aebe', 'email', 'claudio.tz@escuela.cl', 'email_verified', false), 
  'email', 'b2aef22b-93ff-48ee-8889-109ea305aebe', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'b488b667-53d0-43f2-ad1d-2200f626fbc8', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'leonardo.va@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'b488b667-53d0-43f2-ad1d-2200f626fbc8', 'b488b667-53d0-43f2-ad1d-2200f626fbc8', 
  json_build_object('sub', 'b488b667-53d0-43f2-ad1d-2200f626fbc8', 'email', 'leonardo.va@escuela.cl', 'email_verified', false), 
  'email', 'b488b667-53d0-43f2-ad1d-2200f626fbc8', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'c833a03a-8414-4a25-98db-f18fbbe1a6ec', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'yordan.bb@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'c833a03a-8414-4a25-98db-f18fbbe1a6ec', 'c833a03a-8414-4a25-98db-f18fbbe1a6ec', 
  json_build_object('sub', 'c833a03a-8414-4a25-98db-f18fbbe1a6ec', 'email', 'yordan.bb@escuela.cl', 'email_verified', false), 
  'email', 'c833a03a-8414-4a25-98db-f18fbbe1a6ec', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'd0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.lenguaje@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'd0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 
  json_build_object('sub', 'd0000000-0000-0000-0000-000000000001', 'email', 'profesor.lenguaje@escuela.cl', 'email_verified', false), 
  'email', 'd0000000-0000-0000-0000-000000000001', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'd0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.ciencias@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'd0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 
  json_build_object('sub', 'd0000000-0000-0000-0000-000000000002', 'email', 'profesor.ciencias@escuela.cl', 'email_verified', false), 
  'email', 'd0000000-0000-0000-0000-000000000002', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'd0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.historia@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'd0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003', 
  json_build_object('sub', 'd0000000-0000-0000-0000-000000000003', 'email', 'profesor.historia@escuela.cl', 'email_verified', false), 
  'email', 'd0000000-0000-0000-0000-000000000003', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'd0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.ingles@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'd0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000004', 
  json_build_object('sub', 'd0000000-0000-0000-0000-000000000004', 'email', 'profesor.ingles@escuela.cl', 'email_verified', false), 
  'email', 'd0000000-0000-0000-0000-000000000004', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'd0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.arte@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'd0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000005', 
  json_build_object('sub', 'd0000000-0000-0000-0000-000000000005', 'email', 'profesor.arte@escuela.cl', 'email_verified', false), 
  'email', 'd0000000-0000-0000-0000-000000000005', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'da554409-60e0-4af8-97c4-a1ca1b0acf69', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'juan.cm@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'da554409-60e0-4af8-97c4-a1ca1b0acf69', 'da554409-60e0-4af8-97c4-a1ca1b0acf69', 
  json_build_object('sub', 'da554409-60e0-4af8-97c4-a1ca1b0acf69', 'email', 'juan.cm@escuela.cl', 'email_verified', false), 
  'email', 'da554409-60e0-4af8-97c4-a1ca1b0acf69', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'db0c69a8-bd79-4d90-953d-ca82b0057b2d', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'caleb.ac@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'db0c69a8-bd79-4d90-953d-ca82b0057b2d', 'db0c69a8-bd79-4d90-953d-ca82b0057b2d', 
  json_build_object('sub', 'db0c69a8-bd79-4d90-953d-ca82b0057b2d', 'email', 'caleb.ac@escuela.cl', 'email_verified', false), 
  'email', 'db0c69a8-bd79-4d90-953d-ca82b0057b2d', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'dea6987a-f7b2-411a-aed4-8b03300bc175', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'diego.tu@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'dea6987a-f7b2-411a-aed4-8b03300bc175', 'dea6987a-f7b2-411a-aed4-8b03300bc175', 
  json_build_object('sub', 'dea6987a-f7b2-411a-aed4-8b03300bc175', 'email', 'diego.tu@escuela.cl', 'email_verified', false), 
  'email', 'dea6987a-f7b2-411a-aed4-8b03300bc175', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'e0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'coordinador@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'e0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 
  json_build_object('sub', 'e0000000-0000-0000-0000-000000000001', 'email', 'coordinador@escuela.cl', 'email_verified', false), 
  'email', 'e0000000-0000-0000-0000-000000000001', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'e2367fdf-782c-4a1a-ac8e-3cd48addac16', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'director@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'e2367fdf-782c-4a1a-ac8e-3cd48addac16', 
  json_build_object('sub', 'e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'email', 'director@escuela.cl', 'email_verified', false), 
  'email', 'e2367fdf-782c-4a1a-ac8e-3cd48addac16', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  'e27c5542-8af1-4f49-a252-ac1fba125439', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'felipe.vc@escuela.cl', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  'e27c5542-8af1-4f49-a252-ac1fba125439', 'e27c5542-8af1-4f49-a252-ac1fba125439', 
  json_build_object('sub', 'e27c5542-8af1-4f49-a252-ac1fba125439', 'email', 'felipe.vc@escuela.cl', 'email_verified', false), 
  'email', 'e27c5542-8af1-4f49-a252-ac1fba125439', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;
