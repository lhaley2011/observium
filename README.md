
# Install [Observium](//www.observium.org/) Community

[Observium Install Guide used to create this.](//www.observium.org/docs/install_rhel7/)

### Known Issues
- Apache configuration not correct. Welcome page shown instead of Observium.

### How To Use:
- download this git repo to server you wish to install Observium onto
- edit observium.conf with unique passwords
- run install.sh script (sh install.sh)
- wait for script to finish
- goto <your server ip>
- login with username as admin and password you set in obervium.conf

### Features
- creates observium directory under /opt
- downloads latest release of Observium
- decompresses Observium download into observium directory
- installs Observium dependencies
- configures mysql for observium
- sets up apache for virtual hosts
- adds observium as the default virtual host
- disables SELINUX
- saves all growing data in /var directory
- creates admin user
- sets up observium's default cron poller
- opens http (port 80) on the firewall


### Future Goals
- change php logging to not include NOTICE
- allow script to skips portions already completed
- use same script to install Observium updates


