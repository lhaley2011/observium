<?php

## Check http://www.observium.org/docs/config_options/ for documentation of possible settings

// Database config ---  This MUST be configured
$config['db_extension'] = 'mysqli';
$config['db_name']      = 'observium';
$config['db_host']      = 'localhost';
$config['db_user']      = 'USERNAME';
$config['db_pass']      = 'PASSWORD';

// Base directory
$config['install_dir'] = "/opt/observium";

$config['html_dir']    = "/opt/observium/html";

// Default community list to use when adding/discovering
$config['snmp']['community'] = array("public");

// Authentication Model
$config['auth_mechanism'] = "mysql";    // default, other options: ldap, http-auth, please see documentation for config help

// Enable alerter
// $config['poller-wrapper']['alerter'] = TRUE;

//$config['web_show_disabled'] = FALSE;    // Show or not disabled devices on major pages.

// Set up a default alerter (email to a single address)
//$config['email']['default']        = "user@your-domain";
//$config['email']['from']           = "Observium <observium@your-domain>";
//$config['email']['default_only']   = TRUE;

// fping path
$config['fping'] = "/usr/sbin/fping";

// End config.php
