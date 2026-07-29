#!/bin/sh
set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1
MAIL_DIR="/var/mail/$USERNAME"

# Create user if it doesn't exist
if ! id "$USERNAME" >/dev/null 2>&1; then
    adduser -D -h "$MAIL_DIR" -s /sbin/nologin "$USERNAME"
    # Set password to master password
    if [ -n "$MASTER_PASSWORD" ]; then
        echo "$USERNAME:$MASTER_PASSWORD" | chpasswd
    fi
    usermod -aG mail "$USERNAME"
    echo "Created user $USERNAME"

    # Create mail directory structure
    mkdir -p "$MAIL_DIR/Maildir/cur" "$MAIL_DIR/Maildir/new" "$MAIL_DIR/Maildir/tmp"

    # Ensure vmail:mail own it
    chown -R vmail:mail "$MAIL_DIR"

    # Permissions: owner + group can read/write, others can read (optional)
    chmod -R 777 "$MAIL_DIR"

    # Set the MAIL environment variable for the user
    mkdir -p "/home/$USERNAME"
    echo "export MAIL=~/Maildir" >>"/home/$USERNAME/.profile"
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
    echo "Mail directory set up for $USERNAME"
else
    echo "User $USERNAME already exists"
fi
