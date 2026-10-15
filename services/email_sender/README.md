Khedmni Email Sender Service

This is a lightweight Express service used by the Khedmni app to send verification emails.

Features:
- Sends a beautiful HTML verification email with a large 4-digit code
- Includes an email-friendly web page (`/verify?code=<code>`) where the user can copy the code
- Attempts SendGrid first (if `SENDGRID_API_KEY` is provided), then SMTP fallback, else logs to console
- Default `FROM_EMAIL` is `khedmni.mdpa@gmail.com` (override with env var `FROM_EMAIL`)

How to run:
1. Install dependencies: `npm install`
2. (Optional) Configure environment variables in a `.env` file:
   - `SENDGRID_API_KEY` (optional)
   - `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS` (optional SMTP fallback)
   - `FROM_EMAIL` (optional; defaults to `khedmni.mdpa@gmail.com`)
   - `PORT` (optional; default 3000)
3. Start the service: `node index.js`

Usage:
- POST /send-verification
  - body: { email: string, code: string }
  - Response: { ok: true, sentWith: 'sendgrid'|'smtp'|'console' }

- GET /verify?code=<code>
  - Returns a small web page that displays the code and includes a Copy button and a deep link to open the app.

Notes:
- Emails include a deep link `khedmni://verify?code=<code>` which the mobile app listens for; if the app is opened via that link it will auto-fill the code and attempt verification.
- In development, emails are logged to the console if no delivery mechanism is configured.

Docker & Deploy:
- A `Dockerfile` is included for building a container image for the service.
- We provide a GitHub Actions workflow that builds & pushes the container (`.github/workflows/deploy-email-service.yml`) and can trigger a deploy on Render if you provide `RENDER_API_KEY` and `RENDER_SERVICE_ID` as GitHub secrets.
- If you prefer manual deployment, you can link the repo in Render and point the service to the `services/email_sender` folder and either use the `Dockerfile` or Node build commands.

Database (Postgres) integration:
- You can add a managed Postgres database on Render (or any Postgres provider). Once created, Render will provide an **Internal Database URL** (starts with `postgres://...` or `postgresql://...`).
- Add `DATABASE_URL` to the service environment variables (Render service → Environment) set to the Internal Database URL. Restart or redeploy the service.
- A small init script is provided at `scripts/init_db.js` which creates a `jobs` table. Run it on the server (or locally) with:
  - `node scripts/init_db.js` (ensure `DATABASE_URL` is set in env)
- If you do not have shell access on Render (paid feature), you can initialize the DB with a protected HTTP endpoint:
  - Add `INIT_DB_SECRET=<a-random-secret>` to the service Environment variables.
  - Trigger initialization with:

    curl -X POST "https://<your-service-url>/admin/init-db?secret=<your-secret>"

  - The endpoint will create the `jobs` table and return `{ "ok": true, "message": "db initialized" }` on success. *Remove `INIT_DB_SECRET` after use.*
- The service exposes a simple jobs API for testing:
  - `GET /jobs` — returns list of jobs (requires DB configured)
  - `POST /jobs` — create a job { title, company }

Notes:
- The app will attempt to connect to Postgres only if `DATABASE_URL` is set.
- Make sure to set `DATABASE_URL` in Render to the Internal DB URL (or use a tenant-allowed public URL if appropriate).
