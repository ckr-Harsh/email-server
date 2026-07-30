# Mail Server with Postfix, Dovecot, and Roundcube

A fully functional mail server stack using Docker, providing SMTP, IMAP, a REST API for user management, and a Roundcube Webmail UI.

## Features

- **SMTP & IMAP**: Local mail delivery using Postfix and access via Dovecot.
- **REST API**: Dynamically create new email users with custom passwords.
- **Web UI**: Access emails via the Roundcube Webmail interface.
- **Maildir Storage**: Reliable email storage format.

## Prerequisites

- Docker and Docker Compose (or `docker-compose`)
- Ports `25` (SMTP), `143` (IMAP), `8001` (Web UI), and `6000` (API) available on your host.

## Quick Start

1. Clone this repository.
2. Build and start the containers in the background:
   ```bash
   docker compose up --build -d
   ```
3. Access the Roundcube Webmail UI at `http://localhost:8001` (or `http://<your-ip>:8001` if using WSL/VMs).

---

## Configuration

### Creating Users (API)
Users are no longer hardcoded. You can dynamically provision users via the REST API exposed on port `6000`.

**Create a new user:**
```bash
curl -X POST http://localhost:6000/create-user \
-H "Content-Type: application/json" \
-d '{"username":"testuser", "password":"YourSecurePassword123"}'
```

### Accessing Emails

**Via Web UI (Roundcube):**
- URL: `http://localhost:8001`
- Login with the credentials you created via the API.

**Via IMAP Client:**
- Server: `localhost`
- Port: `143`
- Security: None (TLS disabled by default for local dev)
- Authentication: Username and Password

### Sending Test Emails Locally
You can trigger a local test email via the API:
```bash
curl http://localhost:6000/test-email?to=testuser
```

---

## ⚠️ Important Note on Outbound Email Delivery (Production)

If you attempt to send an email to an external address (e.g., Gmail, ProtonMail) from your local environment, **it will likely be rejected or dropped**.

Major email providers enforce strict anti-spam policies. To successfully send emails to the internet, you MUST configure the following in a production environment:

1. **Real Domain name**: Update `docker-compose.yml` to use your purchased domain instead of `example.com`.
2. **DNS Records**: Configure your domain's DNS with valid **SPF**, **DKIM**, and **DMARC** records.
3. **Clean IP & Reverse DNS**: Ensure your hosting provider gives you a clean IP address and configure a **PTR (Reverse DNS)** record that resolves to your mail server's domain.
4. **Port 25 Unblocked**: Ensure your ISP or Cloud Provider (AWS, DigitalOcean, etc.) has not blocked outbound traffic on Port 25 (many block it by default to prevent spam).

For local testing, the server will successfully process outbound messages, but external servers will reject them until these production prerequisites are met.

---

## Troubleshooting

- **Check Mailserver Logs:**
  ```bash
  docker compose logs mailserver
  ```
- **View Internal Mail Logs (Postfix/Dovecot):**
  ```bash
  docker exec mailserver tail -f /var/log/mail.log /var/log/dovecot.log
  ```
- **UI Not Loading:** If `localhost` fails to route properly on Windows/WSL, find your WSL IP (e.g., `hostname -I`) and visit `http://<wsl-ip>:8001`.

## Security Note
This server is currently configured for **development/testing**. For production:
- Generate and mount SSL/TLS certificates.
- Enforce `ssl = required` in `dovecot.conf`.
- Configure Postfix with TLS support.
- Place it behind a secure reverse proxy.

## License
MIT
