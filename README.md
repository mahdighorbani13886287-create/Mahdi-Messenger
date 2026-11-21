# Mahdi Messenger — starter project

A cross-platform messenger starter:
- Flutter client (Android, iOS, Windows, Linux, macOS, Web where supported by Flutter)
- NestJS backend scaffold
- PostgreSQL + Prisma schema
- Dark/light themes
- Demo chat UI with local in-memory messages

## Important security status
This is a development starter, **not a production-secure messenger**. The chat UI is a demo and messages are not end-to-end encrypted yet. Do not use it for private or sensitive conversations.
Before production, implement and independently review:
- audited Signal Protocol integration (do not invent cryptography)
- device identity/prekeys and secure key storage
- authenticated sessions, rate limits, abuse controls
- secure file upload/scanning and encrypted object storage
- backups, key recovery, account/device revocation
- TLS, secrets management, logging/privacy controls, penetration testing

## Requirements
- Flutter SDK (stable)
- Node.js LTS and npm
- PostgreSQL

## Run the Flutter app
```bash
cd client
flutter create . --platforms=android,ios,web,windows,linux,macos
flutter pub get
flutter run -d chrome
```
For desktop, use e.g. `flutter run -d windows` after enabling the relevant desktop target in Flutter.

## Run the backend
```bash
cd server
cp .env.example .env
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run start:dev
```
Set `DATABASE_URL` in `server/.env` to your PostgreSQL connection string first.

## Current API
- `GET /health` — health check
- `GET /api/demo/conversations` — demo conversation list
- `POST /api/demo/messages` — demo in-memory message append

The demo endpoints are intentionally not authentication-protected and are not suitable for deployment.


## Admin panel (development only)
- In-app panel: click the admin icon in the Flutter app bar.
- Separate dashboard: `admin-panel/index.html`; serve it locally with `python -m http.server 8080` from that folder, then open `http://localhost:8080`. It connects to `http://localhost:3000/api`.
- Admin endpoints: `GET/PUT /api/admin/settings`, `GET/POST /api/admin/banned-words`, `DELETE /api/admin/banned-words/:id`, `GET/POST /api/admin/admins`.

**Critical limitations:** admin data is in-memory and resets when the server restarts. Admin endpoints currently have NO authentication or authorization; never expose them to the public internet. Word rules are stored but are not yet enforced in message sending. File-size/quota settings are configuration only; resumable chunk upload and storage enforcement are not implemented. End-to-end encryption is not implemented. Production release requires persistent database storage, strong admin authentication, RBAC checks on every endpoint, audit logs, rate limiting, secure upload pipeline, and independent security review.
