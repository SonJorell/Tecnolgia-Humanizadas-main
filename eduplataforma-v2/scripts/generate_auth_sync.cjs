const fs = require('fs');

const csvPath = 'c:/Users/jorel/Downloads/perfiles_rows.csv';
const outPath = 'c:/Users/jorel/Downloads/Tecno/Tecnolgia-Humanizadas-main/eduplataforma-v2/supabase/migrations/008_sync_auth_users.sql';

const csv = fs.readFileSync(csvPath, 'utf8');
const lines = csv.split('\n').slice(1).filter(l => l.trim() !== '');

let sql = `-- ═══════════════════════════════════\n`;
sql += `-- 008_sync_auth_users.sql\n`;
sql += `-- Sincroniza cuentas desde el CSV a auth.users con clave prueba123\n`;
sql += `-- ═══════════════════════════════════\n\n`;
sql += `CREATE EXTENSION IF NOT EXISTS pgcrypto;\n\n`;

for (const line of lines) {
  // Split correctly considering possible quotes, but the provided CSV seems to be simple comma-separated
  const parts = line.split(',');
  const id = parts[0];
  const email = parts[10];

  if (!id || !email || !email.includes('@')) continue;

  sql += `
INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES (
  '${id}', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', '${email}', 
  crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
  '{"provider":"email","providers":["email"]}', '{}', false
) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES (
  '${id}', '${id}', 
  json_build_object('sub', '${id}', 'email', '${email}', 'email_verified', false), 
  'email', '${id}', current_timestamp, current_timestamp, current_timestamp
) ON CONFLICT (provider_id, provider) DO NOTHING;
`;
}

fs.writeFileSync(outPath, sql);
console.log('SQL generado exitosamente en:', outPath);
