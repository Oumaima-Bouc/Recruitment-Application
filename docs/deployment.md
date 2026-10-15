# Deployment guide (quick start)

This document explains how to deploy the Node email service to a free provider (Render) and how to set up continuous integration for building the Flutter Android app with GitHub Actions.

## Goals
- Deploy the `services/email_sender` microservice so it is publicly reachable (HTTPS) and can send real emails using SendGrid or Mailtrap SMTP.
- Add GitHub Actions workflows to build/test the Flutter app and to deploy the service automatically.
- Add a smoke-test action to verify the deployed service.

## Provider choice
We use **Render** as a free and easy provider for the email microservice, and **GitHub Actions** (free for public repos / free tier for private) for CI and deploy automation.

### Render setup
1. Create a Render account (https://render.com) and connect your GitHub repository.
2. Create a new **Web Service** on Render:
   - Select your repository and the `services/email_sender` folder (select Docker or Node service). If you use the Dockerfile added to the repo, Render will build the image automatically.
   - Set the build and start commands (if using Dockerfile none needed; if Node set `npm ci && npm start`).
   - Add environment variables in the Render service settings:
     - `SENDGRID_API_KEY` (for SendGrid), or SMTP variables (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`) for Mailtrap
     - `FROM_EMAIL` (optional; default is khedmni.mdpa@gmail.com)
3. Note the service URL (e.g. `https://khedmni-email.onrender.com`) and the Render **Service ID** (from the URL or service settings).
4. Create a Render API key (Dashboard → Account → API Keys).

### Add a managed Postgres database (optional but recommended)
1. In the Render dashboard click **Databases → New Database** and create a Postgres instance (free tier is usually available for small projects).
2. After the database is provisioned, copy the **Internal Database URL** (starts with `postgres://` or `postgresql://`).
3. In your email service (Render service settings → Environment) add: `DATABASE_URL = <internal-db-url>` and save.
4. Redeploy the email service; inside the container you can run `node scripts/init_db.js` to create the example `jobs` table, or run it locally with the same `DATABASE_URL` set.

The email service has a simple jobs API to demonstrate DB usage:
- `GET /jobs` — returns jobs list
- `POST /jobs` — create a job `{ title, company }`

Add the `DATABASE_URL` GitHub secret if you want Actions to be able to run migration scripts against the DB (use carefully).

### GitHub secrets needed for automated deploy (optional)
- `RENDER_API_KEY` — Render API key (for triggering deploy via Actions)
- `RENDER_SERVICE_ID` — the ID of the Render service
- `PRODUCTION_EMAIL_URL` — the public URL of your service (used by smoke tests)
- `SMOKE_TEST_EMAIL` — an email address you control (for smoke test deliveries)

Add these secrets in your GitHub repository Settings → Secrets → Actions.

## How the provided workflows work
- `.github/workflows/flutter-ci.yml` — Runs on push/pull-request to `main`, installs Flutter, runs `flutter pub get`, runs `flutter test`, builds a release `apk`, and uploads it as an artifact.
- `.github/workflows/deploy-email-service.yml` — On push to `main` or manual dispatch: builds a Docker image for `services/email_sender`, pushes it to GitHub Container Registry (ghcr.io) and—if `RENDER_API_KEY` & `RENDER_SERVICE_ID` are configured—triggers a Render deploy using the API.
- `.github/workflows/smoke-test-email.yml` — Manually run via the Actions UI to POST a verification email to the production service and verify it accepts requests.

## After deployment
1. Set `EMAIL_SERVICE_URL` in your app to the production URL (emulator: use direct URL; Android emulator uses the public URL, not 10.0.2.2)
2. Run the smoke test action or manually POST to `$PRODUCTION_EMAIL_URL/send-verification` to validate delivery.

---

If you'd rather use Railway, Fly.io, or Render's GitHub native integration instead of the pattern above, tell me and I'll update the deploy workflow to match that provider's API/CLI.
