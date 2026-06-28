const SUPABASE_URL = 'https://aukwtuvwfbemfmioslkl.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1a3d0dXZ3ZmJlbWZtaW9zbGtsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMDM1OTQsImV4cCI6MjA5NTc3OTU5NH0.V3ZeFIKnQM9w8O27WvHHU12m2cXkx36F0SsTfSn7d4s';

// Admin password (cámbiala después)
const ADMIN_PASSWORD = 'studio17admin';

// Tu número de WhatsApp (sin + ni espacios)
const WHATSAPP_NUMBER = '34677777177';

async function supabaseRequest(path, options = {}) {
  const url = `${SUPABASE_URL}/rest/v1/${path}`;
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': options.prefer || 'return=representation',
    ...options.headers
  };
  const res = await fetch(url, { ...options, headers });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(err);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : [];
}
