<?php

$config = array();

// Database configuration (SQLite for simplicity)
$config['db_dsnw'] = 'sqlite:////var/roundcube/db/sqlite.db?mode=0640';

// Mail server settings - use the service name from docker-compose
$config['default_host'] = 'tcp://mailserver:143';
$config['smtp_server'] = 'tcp://mailserver:25';

// IMAP authentication using master user (e.g. admin*user)
$config['imap_auth_type'] = 'PLAIN';  // IMPORTANT for master user login

// Disable SSL/TLS verification for now (self-signed)
$config['imap_conn_options'] = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true
    )
);

$config['smtp_conn_options'] = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true
    )
);

// Enable debugging
$config['debug_level'] = 1;
$config['log_driver'] = 'stdout';
$config['log_date_format'] = 'Y-m-d H:i:s';

// Roundcube plugins
$config['plugins'] = array(
    'archive',
    'managesieve',
    'password',
    'identity_select'
);

// Identity plugin settings
$config['identity_select_headers'] = true;
$config['identity_select_editor'] = true;
$config['identity_select_shortcuts'] = true;
$config['identities_level'] = 2;  // Allow all identities

// Show all folders, not just subscribed ones
$config['imap_force_ns'] = true;
$config['imap_ns_personal'] = '';
$config['imap_ns_other'] = '';
$config['imap_ns_shared'] = '';
$config['imap_list_subscribed'] = false;

// Auto-create user in Roundcube's database on login
$config['auto_create_user'] = true;

// Set the admin username (must match your admin username in Dovecot)
$config['support_username'] = 'admin';

// Mail folder visibility options
$config['show_real_foldernames'] = true;
$config['show_real_foldernames_in_list'] = true;
$config['imap_skip_hidden_folders'] = false;

// Default folders to show
$config['default_imap_folders'] = array('INBOX', 'Drafts', 'Sent', 'Junk', 'Trash');
$config['create_default_folders'] = true;
$config['default_list_mode'] = 'list';

// Session lifetime in minutes (8 hours)
$config['session_lifetime'] = 480;

// Use HTTP (not HTTPS) - proxy handles TLS
$config['use_https'] = false;

// Mail preview and UI preferences
$config['preview_pane'] = true;
$config['preview_pane_mark_read'] = 0;
$config['message_sort_col'] = 'date';
$config['message_sort_order'] = 'DESC';

// Trash and deletion behavior
$config['skip_deleted'] = false;
$config['flag_for_deletion'] = true;

// Allow admin to manage all settings
$config['dont_override'] = array();

// SMTP login (optional — if you support sending mail)
$config['smtp_user'] = '%u';  // Uses login (e.g., admin*user)
$config['smtp_pass'] = '%p';  // Uses login password

// Installer flag — disable in production
$config['enable_installer'] = true;

// Optional: custom support URL
$config['support_url'] = '';
