#!/bin/sh
set -e

rsyslogd
# Ensure base directories have correct permissions
chown -R vmail:mail /var/mail
# Function to ensure user and maildir are properly set up
ensure_user_maildir() {
    local username="$1"
    local maildir="/var/mail/$username"
    local homedir="/home/$username"

    echo "Ensuring maildir for user: $username"

    # Create user if it doesn't exist
    if ! id "$username" >/dev/null 2>&1; then
        adduser -D -h "$maildir" -s /sbin/nologin "$username"
        # Set password to master password
        if [ -n "$MASTER_PASSWORD" ]; then
            echo "$username:$MASTER_PASSWORD" | chpasswd
        fi
        usermod -aG mail "$username"
        echo "Created user $username"
    fi

    # Ensure maildir exists with correct permissions
    mkdir -p "$maildir/Maildir/cur" "$maildir/Maildir/new" "$maildir/Maildir/tmp"

    # Ensure vmail:mail own it
    chown -R vmail:mail "$maildir"

    # # Permissions: owner + group can read/write, others can read (optional)
    chmod -R 777 "$maildir"

    # Ensure home directory and profile
    mkdir -p "$homedir"
    touch "$homedir/.profile"
    if ! grep -q "export MAIL=" "$homedir/.profile"; then
        echo "export MAIL=~/Maildir" >>"$homedir/.profile"
    fi
    chown -R "$username:$username" "$homedir"
}

# Function to start Dovecot
start_dovecot() {
    echo "Starting Dovecot..."
    # Start Dovecot in the background
    /usr/sbin/dovecot -F &
    DOVECOT_PID=$!

    # Wait for Dovecot to be ready
    sleep 5

    # Check if Dovecot process is running (Alpine-compatible check)
    if kill -0 $DOVECOT_PID 2>/dev/null; then
        echo "Dovecot started successfully (PID: $DOVECOT_PID)"
    else
        echo "Failed to start Dovecot"
        exit 1
    fi
}

# Set Postfix hostname and domain from environment variables
if [ -n "$HOSTNAME" ]; then
    echo "Setting hostname to $HOSTNAME"
    postconf -e "myhostname = $HOSTNAME"
fi

if [ -n "$DOMAIN" ]; then
    echo "Setting domain to $DOMAIN"
    postconf -e "mydomain = $DOMAIN"
    postconf -e "myorigin = $DOMAIN"
fi

# Configure Dovecot expire days
if [ -n "$EXPIRE_DAYS" ]; then
    echo "Setting email expiration to $EXPIRE_DAYS days"
    # Update autoexpunge values for all mailboxes
    sed -i "/autoexpunge = /c\\    autoexpunge = ${EXPIRE_DAYS}d" /etc/dovecot/dovecot.conf
fi

# Process existing maildirs
if [ -d "/var/mail" ]; then
    for maildir in /var/mail/*/; do
        if [ -d "$maildir" ]; then
            username=$(basename "$maildir")
            ensure_user_maildir "$username"
        fi
    done
fi

# Start Dovecot
start_dovecot

# Start the API server in the background
API_PORT=8080
echo "Starting API server on port $API_PORT"
/server &
API_PID=$!

# Start Postfix in the background
echo "Starting Postfix..."
postfix start

echo "Email server is ready!"

# Keep the container running and show both logs
tail -f /var/log/mail.log /var/log/dovecot.log
