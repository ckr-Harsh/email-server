#!/bin/sh
set -e

# Create dovecot directory if it doesn't exist
mkdir -p /etc/dovecot

# Set default master password if not provided
if [ -z "$MASTER_PASSWORD" ]; then
    MASTER_PASSWORD="Appsentinels1"
    echo "Using default master password: $MASTER_PASSWORD"
    echo "WARNING: Please set MASTER_PASSWORD environment variable in production"
fi

# Create master users file
echo "Creating master users file..."
cat >/etc/dovecot/master-users <<EOF
# Format: username:password:uid:gid:(extra fields)
admin:{PLAIN}${MASTER_PASSWORD}:::
EOF

# Set proper permissions
chmod 600 /etc/dovecot/master-users
chown dovecot:dovecot /etc/dovecot/master-users

# Create vmail user/group if they don't exist
if ! id vmail >/dev/null 2>&1; then
    addgroup -S vmail
    adduser -S -G vmail -H -s /sbin/nologin vmail
fi

# Ensure mail directory exists with correct permissions
# mkdir -p /var/mail
chown -R vmail:mail /var/mail
# chmod -R 775 /var/mail

echo "Master user setup complete!"
echo "Master password: $MASTER_PASSWORD"
echo ""
echo "To access a user's mailbox, use the format: admin*username"

# Reload Dovecot configuration if running
if [ -x "$(command -v dovecot)" ]; then
    echo "Reloading Dovecot configuration..."
    dovecot reload
fi
