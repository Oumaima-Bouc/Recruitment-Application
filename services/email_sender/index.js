require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');
const { Client } = require('pg');

const app = express();
app.use(bodyParser.json());

// Postgres client (optional)
let pgClient = null;
if (process.env.DATABASE_URL) {
  pgClient = new Client({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } });
  pgClient.connect()
    .then(() => console.log('Connected to Postgres (DATABASE_URL)'))
    .catch(err => console.error('Postgres connection error', err));
} else {
  console.log('DATABASE_URL not set; Postgres functionality is disabled');
} 

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
// Use official app email as default
const FROM_EMAIL = process.env.FROM_EMAIL || 'khedmni.mdpa@gmail.com';
const PORT = process.env.PORT || 3000;

// Try to load SendGrid SDK only if API key is provided. If the SDK isn't installed
// (e.g. developer didn't run `npm install @sendgrid/mail`), we continue without it.
let sgMail = null;
if (SENDGRID_API_KEY) {
  try {
    sgMail = require('@sendgrid/mail');
    sgMail.setApiKey(SENDGRID_API_KEY);
    console.log('SendGrid enabled');
  } catch (err) {
    console.warn('SendGrid SDK could not be loaded. SendGrid is disabled. Install @sendgrid/mail or use SMTP/Mailtrap for real email delivery.');
    sgMail = null;
  }
} else {
  console.log('SendGrid not configured; emails will be logged to console or sent via SMTP if configured');
}

// Optionally configure SMTP transport if provided (use Mailtrap for testing)
let smtpTransport = null;
if (process.env.SMTP_HOST) {
  smtpTransport = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT, 10) : 587,
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
  console.log(`SMTP transport configured: ${process.env.SMTP_HOST}:${process.env.SMTP_PORT}`);
}

// A simple, friendly HTML email template
function makeVerificationHtml({ email, code }) {
  return `<!doctype html>
  <html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Khedmni verification</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; background:#f7f9fb; color:#222; margin:0; padding:0 }
      .container{max-width:600px;margin:28px auto;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 6px 20px rgba(0,0,0,0.08)}
      .header{background:#f77f00;padding:18px;color:#fff;text-align:center}
      .logo{font-weight:800;letter-spacing:1px}
      .content{padding:24px}
      .code{display:block;margin:20px auto;padding:12px 18px;background:#fff;border:2px dashed #f1a54a;border-radius:8px;text-align:center;font-size:22px;font-weight:700;color:#f77f00;width:fit-content}
      .btn{display:inline-block;background:#1d3557;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;margin-top:12px}
      .hint{margin-top:16px;color:#666;font-size:13px}
      .footer{padding:16px;text-align:center;color:#888;font-size:12px}
      .copy-link{color:#f77f00;text-decoration:none;font-weight:700}
      @media (max-width:480px){.container{margin:12px}}
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <div class="logo">Khedmni</div>
      </div>
      <div class="content">
        <h2 style="margin:0 0 8px 0">Verify your email</h2>
        <p style="margin:0 0 12px 0">Hi ${email.split('@')[0]},</p>
        <p style="margin:0 0 8px 0">Use the verification code below to finish setting up your Khedmni account.</p>
        <div class="code">${code}</div>
        <p class="hint">Can't use the app right now? <a href="/verify?code=${encodeURIComponent(code)}" class="copy-link">Open this web page</a> to copy the code. If you have the Khedmni app installed, <a href="khedmni://verify?code=${encodeURIComponent(code)}" class="copy-link">tap to open the app</a> and it will auto-fill the code.</p>
        <a class="btn" href="khedmni://verify?code=${encodeURIComponent(code)}">Open in Khedmni app</a>
        <p class="hint">If you didn't request this code, ignore this email. For help, reply to ${FROM_EMAIL}.</p>
      </div>
      <div class="footer">Sent with ❤️ by Khedmni</div>
    </div>
  </body>
  </html>`;
}

app.get('/verify', (req, res) => {
  const code = req.query.code || '';
  res.send(`<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Verify</title>
  <style>body{font-family:Arial,Helvetica,sans-serif;background:#f7f9fb;padding:24px} .box{max-width:540px;margin:24px auto;background:#fff;padding:28px;border-radius:8px;text-align:center;box-shadow:0 6px 20px rgba(0,0,0,0.06)} .code{font-size:30px;font-weight:700;color:#f77f00;margin:18px 0;padding:12px 18px;border-radius:8px;border:2px dashed #f1a54a;display:inline-block} .btn{background:#1d3557;color:#fff;padding:10px 16px;border-radius:8px;text-decoration:none;display:inline-block;margin-top:12px} .hint{color:#666;margin-top:12px}</style></head><body><div class="box"><h2>Verification code</h2><div class="code" id="code">${code}</div><div style="margin-top:14px"><button class="btn" id="copy">Copy code</button></div><p class="hint">You can paste this into the Khedmni app or use the app link below.</p><p style="margin-top:12px"><a class="btn" href="khedmni://verify?code=${encodeURIComponent(code)}">Open Khedmni</a></p><script>document.getElementById('copy').addEventListener('click',()=>{const t=document.getElementById('code').innerText;navigator.clipboard.writeText(t).then(()=>{alert('Code copied to clipboard')})})</script></div></body></html>`);
});

app.post('/send-verification', async (req, res) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) return res.status(400).json({ error: 'email and code are required' });

    const subject = 'Your Khedmni verification code';
    const text = `Your verification code is ${code}`;
    const html = makeVerificationHtml({ email, code });

    // 1. Try SendGrid ONLY if the SDK loaded successfully
    if (sgMail) {
      try {
        const msg = { to: email, from: FROM_EMAIL, subject, text, html };
        await sgMail.send(msg);
        return res.json({ ok: true, sentWith: 'sendgrid' });
      } catch (sgError) {
        console.error('SendGrid failed, trying SMTP fallback:', sgError.message);
        // Don't return here; let it fall through to SMTP
      }
    }

    // 2. Try SMTP (Mailtrap)
    if (smtpTransport) {
      await smtpTransport.sendMail({ from: FROM_EMAIL, to: email, subject, text, html });
      return res.json({ ok: true, sentWith: 'smtp' });
    }

    // 3. Fallback: log to console
    console.log(`[DEV EMAIL] To: ${email} | Code: ${code}\n\nHTML:\n${html}`);
    return res.json({ ok: true, sentWith: 'console' });

  } catch (err) {
    console.error('send-verification error', err);
    return res.status(500).json({ error: 'internal' });
  }
});
// Simple jobs API to demonstrate DB usage
app.get('/jobs', async (req, res) => {
  if (!pgClient) return res.status(503).json({ error: 'database not configured' });
  try {
    const result = await pgClient.query('SELECT * FROM jobs ORDER BY created_at DESC');
    return res.json(result.rows);
  } catch (err) {
    console.error('jobs query error', err);
    return res.status(500).json({ error: 'internal' });
  }
});

app.post('/jobs', async (req, res) => {
  if (!pgClient) return res.status(503).json({ error: 'database not configured' });
  try {
    const { title, company } = req.body;
    if (!title) return res.status(400).json({ error: 'title required' });
    const result = await pgClient.query('INSERT INTO jobs (title, company) VALUES ($1, $2) RETURNING *', [title, company]);
    return res.json(result.rows[0]);
  } catch (err) {
    console.error('jobs insert error', err);
    return res.status(500).json({ error: 'internal' });
  }
});

// Admin-only DB init endpoint (safe for one-off use)
app.post('/admin/init-db', async (req, res) => {
  const secret = process.env.INIT_DB_SECRET;
  const provided = req.query.secret || req.headers['x-init-secret'];
  if (!secret || provided !== secret) return res.status(401).json({ error: 'unauthorized' });
  if (!pgClient) return res.status(503).json({ error: 'database not configured' });
  try {
    await pgClient.query(`
      CREATE TABLE IF NOT EXISTS jobs (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        company TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
      );
    `);
    return res.json({ ok: true, message: 'db initialized' });
  } catch (err) {
    console.error('init-db error', err);
    return res.status(500).json({ error: 'internal' });
  }
});

// Properly close DB client on exit
process.on('SIGINT', async () => {
  try { if (pgClient) await pgClient.end(); } catch (err) { console.error(err); }
  process.exit(0);
});

// Health and root endpoints to make the service reachable and easy to test
app.get('/', (req, res) => res.send('Khedmni Email Service: OK'));
app.get('/health', (req, res) => res.json({ ok: true, service: 'khedmni-email' }));

// Helper to print registered routes after startup
function listRoutes() {
  const routes = [];
  if (app._router && app._router.stack) {
    app._router.stack.forEach((middleware) => {
      if (middleware.route) {
        const methods = Object.keys(middleware.route.methods).map(m => m.toUpperCase()).join(',');
        routes.push(`${methods} ${middleware.route.path}`);
      } else if (middleware.name === 'router' && middleware.handle && middleware.handle.stack) {
        middleware.handle.stack.forEach((handler) => {
          if (handler.route) {
            const methods = Object.keys(handler.route.methods).map(m => m.toUpperCase()).join(',');
            routes.push(`${methods} ${handler.route.path}`);
          }
        });
      }
    });
  }
  console.log('Registered routes:', routes.join(' | '));
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Email service listening on port ${PORT}`);
  listRoutes();
});

