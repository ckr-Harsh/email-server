# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
# Initialize a new Go module
RUN go mod init email-server
COPY server.go .
# Download dependencies and build
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server .

# Final stage
FROM alpine:3.19

# Install required packages
RUN apk add --no-cache postfix dovecot dovecot-lmtpd mailx shadow openssl rsyslog

# Copy the binary
COPY --from=builder /app/server /server

# Copy configuration files
COPY postfix/main.cf /etc/postfix/main.cf
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf

# Copy scripts
COPY create_user.sh /create_user.sh
COPY entrypoint.sh /entrypoint.sh

# Initialize aliases
RUN touch /etc/postfix/aliases && postalias /etc/postfix/aliases

# Set permissions
RUN chmod +x /create_user.sh /entrypoint.sh /server && chown -R dovecot:dovecot /etc/dovecot

EXPOSE 25 143 8080

ENTRYPOINT ["/entrypoint.sh"]
