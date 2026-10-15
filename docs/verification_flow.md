Verification flow — developer notes

Quick manual test steps:

1. Start the email service
   - cd services/email_sender
   - (optional) create a `.env` file with `FROM_EMAIL=khedmni.mdpa@gmail.com` and SMTP/SendGrid credentials
   - npm install
   - node index.js

2. Run the app (mobile emulator or device)
   - flutter run -d <device>

3. Sign up with an email address
   - On Sign Up, enter name/email/password and press "Create Account".
   - The app will show a Snackbar confirming the verification code was sent.

4. Check email delivery
   - If you configured SendGrid or SMTP, the email will be delivered to the given address.
   - If not configured (development), email content will be logged to the email service console (see server logs).
   - The email includes the code prominently and a link to `https://<email-service-host>/verify?code=<code>` (for copying/debugging) and a deep link `khedmni://verify?code=<code>`.

5. Verify in-app
   - Open the app's verification screen and enter the 4-digit code, or click the deep link from your email which will open the app and auto-fill & verify the code automatically.

6. After successful verification
   - If this was part of signup, the app navigates to Create Profile.
   - If this was a standalone email verification for an already-authenticated user, the interstitial will close and the app will update the user's verified state.

Notes:
- The email web page at `/verify` includes a Copy button that copies the verification code to your clipboard for easy pasting into the app.
- The email uses `khedmni.mdpa@gmail.com` as the default FROM address; override with `FROM_EMAIL` env var.
- If you'd like, we can also implement server-side verification that marks the user verified when clicking a web link, but since user data lives in the local app DB, that requires a shared backend.