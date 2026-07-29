# Mail Server with Postfix and Dovecot

A simple mail server setup using Docker, Postfix, and Dovecot.

## Features

- Local mail delivery using Postfix
- IMAP access via Dovecot
- User authentication with system users
- Maildir format for email storage
- Basic logging configuration

## Prerequisites

- Docker and Docker Compose
- Ports 25 (SMTP) and 143 (IMAP) available

## Quick Start

1. Clone this repository
2. Update environment variables in `docker-compose.yml` if needed
3. Build and start the container:
   ```bash
   docker-compose up --build -d
   ```

# Configuration

## Users

Users are defined in the MAIL_USERS environment variable in docker-compose.yml in the format:

```
username1:password1,username2:password2
```

## Mail Storage

Emails are stored in /var/mail/username/Maildir for each user.

## Accessing Emails

Using IMAP
Server: localhost
Port: 143
Security: None (plain text)
Authentication: Username and password

## Example Python Client

```python
import imaplib

# Connect to IMAP server

imap = imaplib.IMAP4('localhost', 143)
imap.login('user1', 'password1')
imap.select('inbox')

# List all emails

status, messages = imap.search(None, 'ALL')
print(messages)
```

# Troubleshooting

## Check the container logs:

    ```bash
    docker logs mailserver
    ```

## View mail logs:

    ```bash
    docker exec mailserver tail -f /var/log/maillog
    ```

## Security Note

For production use, please:

Enable SSL/TLS
Use strong passwords
Configure proper firewall rules
Enable additional security measures

# License

MIT
