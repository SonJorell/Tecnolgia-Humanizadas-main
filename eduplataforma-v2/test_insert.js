const url = 'https://slmbeartbgkihoznylly.supabase.co/rest/v1/materiales';
const apiKey = 'sb_publishable_TKXdtfKSmH12SYNZAOBjRg_dqwCfa14';

async function test() {
  const payload = {
    id: '12345678-1234-1234-1234-123456789012',
    titulo: 'Test Material',
    tipo: 'guia',
    archivos: []
  };

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'apikey': apiKey,
      'Authorization': 'Bearer ' + apiKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify(payload)
  });

  const text = await response.text();
  console.log('Status:', response.status);
  console.log('Response:', text);
}

test();
