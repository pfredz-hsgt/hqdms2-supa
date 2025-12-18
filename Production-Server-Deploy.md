# Deployment Guide
## Quota Drug Management System
### JABATAN FARMASI - HOSPITAL SEGAMAT

---

## Prerequisites
- Linux/Ubuntu LTS Server
- Root or sudo access
- Domain name (or IP address with SSH)

## Requirements
- Node.js (v14 or higher)
- npm
- PostgreSQL

---

## Table of Contents
1. [Initial Server Setup](#step-1-initial-server-setup)
2. [Install Node.js](#step-2-install-nodejs)
3. [Install PostgreSQL](#step-3-install-postgresql)
4. [Configure PostgreSQL & Import DB](#step-4-configure-postgresql--import-database)
5. [Transfer and Setup Application](#step-5-transfer-and-setup-application)
6. [Configure Production Environment](#step-6-configure-production-environment)
7. [Build Frontend for Production](#step-7-build-frontend-for-production)
8. [Install and Configure Apache](#step-8-install-and-configure-apache-react-front-end)
9. [Install and Configure PM2](#step-9-install-and-configure-pm2-api-server-backend)
10. [Setup Automated Database Backups](#step-10-setup-automated-database-backups-optional)
11. [Configure Log Rotation](#step-11-configure-log-rotation-optional)
12. [Performance Optimization](#step-12-performance-optimization-optional)
13. [Setup Monitoring](#step-13-setup-monitoring)
14. [Security Hardening](#step-14-security-hardening)
15. [Final Verification](#step-15-final-verification)
16. [Maintenance Commands](#maintenance-commands)
17. [Security Checklist](#security-checklist)

---

## Step 1: Initial Server Setup

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```
**Reason:** Updates all packages to latest versions for security.

### Install Essential Tools
```bash
sudo apt install -y curl wget git ufw apache2 openssh-server
```
**Reason:** Installs basic utilities, firewall, and intrusion prevention, if not installed yet.

### (Recommended) SSH into server from Windows
In Windows PowerShell:
```powershell
ssh <username>@<ip address>
```
Input password as required.

### Configure Firewall
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw enable
```
**Reason:** Opens ports for SSH and Apache (HTTP/HTTPS), enables firewall.

### Verify Firewall Status
```bash
sudo ufw status
```
**Reason:** Confirms firewall rules are active.

---

## Step 2: Install Node.js

### Install NVM
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
```
**Reason:** Installs Node Version Manager.

### Install Node.js LTS
```bash
nvm install --lts
nvm alias default node
```
**Reason:** Installs and sets default Node.js version.

### Verify Installation
```bash
node --version
npm --version
```
**Reason:** Confirms Node.js and npm are installed.

---

## Step 3: Install PostgreSQL

### Add PostgreSQL Repository
```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
```
**Reason:** Adds official PostgreSQL repository.

### Install PostgreSQL
```bash
sudo apt install -y postgresql postgresql-contrib
```
**Reason:** Installs PostgreSQL database server.

### Start and Enable PostgreSQL
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```
**Reason:** Starts PostgreSQL and enables auto-start on boot.

---

## Step 4: Configure PostgreSQL & Import Database

### Set Strong Password for postgres User
```bash
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'user';"
```
**Reason:** Sets secure password ("user") for PostgreSQL superuser.

### Create Production Database
```bash
sudo -u postgres createdb hqdms
```
**Reason:** Creates application database named "hqdms".

### Verify Database Creation
```bash
sudo -u postgres PAGER= psql -c "\l"
```
**Reason:** Lists all databases; 'hqdms' should appear in the list.

---

## Step 5: Transfer and Setup Application

### Clone project files from GitHub
```bash
cd /var/www/
sudo chown $USER:$USER /var/www/
git clone https://github.com/pfredz-hsgt/hqdms2.git
cd hqdms2
```
**Reason:** Clone the project folder from GitHub.

### Restore Database from previously made backup
```bash
sudo -u postgres psql -d hqdms -f /var/www/hqdms2/database/backup-20251127.sql
```
**Reason:** Executes SQL commands from backup.sql file into hqdms database. In this case it restores backup in working folder pulled from GitHub.

### Clean & Reset Database to max unique ID
```bash
sudo -u postgres psql -d hqdms
```
Password for user postgres: `<enter password>`

```sql
SELECT setval('departments_id_seq', (SELECT MAX(id) FROM departments) + 1);
SELECT setval('drugs_id_seq', (SELECT MAX(id) FROM drugs) + 1);
SELECT setval('enrollments_id_seq', (SELECT MAX(id) FROM enrollments) + 1);
SELECT setval('patients_id_seq', (SELECT MAX(id) FROM patients) + 1);
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users) + 1);
\q
```
**Reason:** Allow system to continue ID from previous backup database, and prevent conflicting numbers (compulsory for all incremental tables: departments, drugs, enrollments, patients, users).

### Configure PostgreSQL for Local Connections
```bash
sudo nano /etc/postgresql/*/main/pg_hba.conf
```
**Reason:** Opens PostgreSQL authentication configuration.

Find lines with "local" and "host 127.0.0.1", ensure they use "md5" authentication:
```
local      all      postgres              md5
local      all      all                   md5
host       all      all      127.0.0.1/32 md5
host       all      all      ::1/128      md5
```

Press `Ctrl + X` → `Y` → `Enter`

**Reason:** Requires password authentication for all local connections.

### Restart PostgreSQL
```bash
sudo systemctl restart postgresql
```
**Reason:** Applies authentication configuration changes.

### Install Dependencies
```bash
npm install --production
cd client
npm install
cd ..
```
**Reason:** Installs production dependencies only (no dev dependencies).

---

## Step 6: Configure Production Environment

### Create Production .env Backend File
```bash
nano /var/www/hqdms2/.env
```
**Reason:** Creates environment configuration for production.

### Add Production Backend .env Configuration
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=hqdms
DB_USER=postgres
DB_PASSWORD=user
PORT=3003
NODE_ENV=production
JWT_SECRET=f3a1b2c4d5e6f7890a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
JWT_EXPIRE=7d
CORS_ORIGIN=http://localhost
```
**Reason:** Configures production database and security settings.

### Create Production .env Frontend File
```bash
nano /var/www/hqdms2/client/.env
```
**Reason:** Creates environment configuration for production.

### Add Production Frontend .env Configuration
```env
REACT_APP_API_URL=/api
```
**Reason:** Configure base API URL to just use `/api` instead of port 3003.

### Verify .env file exists
```bash
ls -a /var/www/hqdms2/client/
```
**Reason:** Verify the .env file is there.

### Set Secure File Permissions
```bash
chmod 600 /var/www/hqdms2/.env
```
**Reason:** Restricts .env file access to owner only.

---

## Step 7: Build Frontend for Production

### Build React Application
```bash
npm run build
```
**Reason:** Creates optimized production build with minification.

### Verify Build
```bash
ls -la client/build
```
**Reason:** Confirms build directory contains production assets.

---

## Step 8: Install and Configure Apache (React Front End)

### Install Apache (if not already installed)
```bash
sudo apt install -y apache2
```
**Reason:** Installs Apache web server.

### Enable Required Modules
```bash
sudo a2enmod rewrite
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod headers
```
**Reason:** Enables URL rewriting, proxying, SSL, and security headers.

### Create Apache Virtual Host
```bash
sudo nano /etc/apache2/sites-available/hqdms2.conf
```
**Reason:** Creates Apache configuration file.

### Add Configuration for HTTP (Apache Config)
```apache
<VirtualHost *:80>
    ServerName 192.168.26.129
    ServerAlias 192.168.26.129
    ServerAdmin farmasihsegamat@moh.gov.my

    DocumentRoot /var/www/hqdms2-public
    
    <Directory /var/www/hqdms2-public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # React Router Support
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_URI} !^/api
        RewriteRule . /index.html [L]
    </Directory>
    
    # Proxy API requests to Node.js backend
    ProxyPreserveHost On
    ProxyPass /api http://localhost:3003/api
    ProxyPassReverse /api http://localhost:3003/api
    
    # Security Headers
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "DENY"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/hqdms2_error.log
    CustomLog ${APACHE_LOG_DIR}/hqdms2_access.log combined
</VirtualHost>
```
**Reason:** Configures Apache to serve React app and proxy API requests.

### Deploy React Build to Apache
```bash
sudo mkdir -p /var/www/hqdms2-public
sudo cp -r /var/www/hqdms2/client/build/* /var/www/hqdms2-public/
sudo chown -R www-data:www-data /var/www/hqdms2-public
sudo chmod -R 755 /var/www/hqdms2-public
```
**Reason:** Copies build files to hqdms2-public directory with proper permissions.

### Enable Site and Restart Apache
```bash
sudo a2dissite 000-default.conf
sudo a2ensite hqdms2.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
```
**Reason:** Activates site configuration and restarts Apache.

---

## Step 9: Install and Configure PM2 (API Server Backend)

### Install PM2 Globally
```bash
npm install -g pm2
```
**Reason:** Installs PM2 process manager globally.

### Create PM2 Ecosystem File
```bash
nano /var/www/hqdms2/ecosystem.config.js
```
**Reason:** Creates PM2 configuration file for better management.

### Add PM2 Configuration
```javascript
module.exports = {
  apps: [{
    name: 'hqdms2-backend',
    script: '/var/www/hqdms2/server/index.js',
    cwd: '/var/www/hqdms2/server',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3003
    },
    error_file: '/var/log/pm2/hqdms2-error.log',
    out_file: '/var/log/pm2/hqdms2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '500M',
    watch: false
  }]
};
```
**Reason:** Configures PM2 with production settings and logging.

### Create Log Directory
```bash
sudo mkdir -p /var/log/pm2
sudo chown $USER:$USER /var/log/pm2
```
**Reason:** Creates directory for PM2 logs.

### Start Application with PM2
```bash
cd /var/www/hqdms2
pm2 start ecosystem.config.js
```
**Reason:** Starts backend using PM2 ecosystem configuration.

### Save PM2 Process List
```bash
pm2 save
```
**Reason:** Saves current processes for automatic restart.

### Configure PM2 Startup Script
```bash
pm2 startup systemd
```
**Reason:** Displays command to enable PM2 on system boot.

**COPY AND RUN** the displayed command (it will look like this example):
```bash
sudo env PATH=$PATH:/home/user/.nvm/versions/node/v24.11.1/bin /home/user/.nvm/versions/node/v24.11.1/lib/node_modules/pm2/bin/pm2 startup systemd -u user --hp /home/user
```
**Reason:** Configures system to start PM2 processes on boot.

### Save Configuration
```bash
pm2 save
```
**Reason:** Persists PM2 startup configuration.

---

## Step 10: Setup Automated Database Backups (Optional)

### Create Backup Script
```bash
sudo nano /usr/local/bin/backup-hqdms.sh
```
**Reason:** Creates automated backup script.

### Add Backup Script Content
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/hqdms"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="hqdms"
DB_USER="hqdms_user"
DB_PASSWORD="STRONG_USER_PASSWORD_HERE"

# Create backup directory
mkdir -p $BACKUP_DIR

# Create backup
export PGPASSWORD=$DB_PASSWORD
pg_dump -U $DB_USER -d $DB_NAME -F c -f $BACKUP_DIR/hqdms_$DATE.backup

# Keep only last 7 days of backups
find $BACKUP_DIR -name "hqdms_*.backup" -mtime +7 -delete

# Log backup
echo "$(date): Backup completed - hqdms_$DATE.backup" >> $BACKUP_DIR/backup.log
```
**Reason:** Creates compressed database backup with automatic cleanup.

### Make Script Executable
```bash
sudo chmod +x /usr/local/bin/backup-hqdms.sh
```
**Reason:** Grants execute permission to backup script.

### Test Backup Script
```bash
sudo /usr/local/bin/backup-hqdms.sh
```
**Reason:** Manually runs backup to verify it works.

### Schedule Daily Backup with Cron
```bash
sudo crontab -e
```
**Reason:** Opens root crontab editor.

Add this line:
```
0 2 * * * /usr/local/bin/backup-hqdms.sh
```
**Reason:** Schedules backup to run daily at 2:00 AM.

---

## Step 11: Configure Log Rotation (Optional)

### Create PM2 Log Rotation
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```
**Reason:** Installs log rotation to prevent large log files.

---

## Step 12: Performance Optimization (Optional)

### Enable Performance Modules
```bash
sudo a2enmod expires
sudo a2enmod deflate
```
**Reason:** Enables browser caching and compression.

### Add Caching Rules to Apache Config
Edit `/etc/apache2/sites-available/hqdms2.conf`:
```bash
nano /etc/apache2/sites-available/hqdms2.conf
```

Add inside `<Directory>`:
```apache
# Browser Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType text/javascript "access plus 1 month"
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
    AddOutputFilterByType DEFLATE application/javascript text/javascript
    AddOutputFilterByType DEFLATE application/json
</IfModule>
```
**Reason:** Configures caching and compression for static assets.

### Restart Apache
```bash
sudo systemctl restart apache2
```
**Reason:** Applies performance optimizations.

---

## Step 13: Setup Monitoring

### Monitor PM2 Processes
```bash
pm2 monit
```
**Reason:** Real-time monitoring of backend process.

### Check Application Status
```bash
pm2 status
pm2 logs hqdms2-backend --lines 50
```
**Reason:** Views process status and recent logs.

### Monitor System Resources
```bash
sudo apt install -y htop
htop
```
**Reason:** Installs and runs system resource monitor.

---

## Step 14: Security Hardening

### Secure PostgreSQL
```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
```
Find and set:
```
listen_addresses = 'localhost'
```
**Reason:** Restricts PostgreSQL to local connections only.

### Restrict Application File Permissions
```bash
sudo chown -R $USER:$USER /var/www/hqdms2
sudo chmod -R 750 /var/www/hqdms2
sudo chmod 600 /var/www/hqdms2/.env
```
**Reason:** Sets restrictive permissions on application files.

---

## Step 15: Final Verification

### Check All Services
```bash
sudo systemctl status postgresql
sudo systemctl status apache2
pm2 status
```
**Reason:** Verifies all services are running.

### Test Application
Open browser to `http://your-server-ip`

**Reason:** Confirms application is accessible.

### Test API Endpoint
```bash
curl http://localhost:3003/api/health
```
**Reason:** Verifies backend API is responding.

---

## Maintenance Commands

### Update Application
```bash
cd /var/www/hqdms2
git pull https://github.com/pfredz-hsgt/hqdms2.git
npm install --production
cd client 
npm install
npm run build
cd ..
sudo cp -r client/build/* /var/www/hqdms2-public/
pm2 restart hqdms2-backend
sudo systemctl restart apache2
```
**Reason:** Updates code, rebuilds frontend, restarts backend.

### Manual Database Backup (Run Backup Script)
```bash
sudo /usr/local/bin/backup-hqdms.sh
```
**Reason:** Creates immediate database backup.

### Restore Database (If required only)
```bash
PGPASSWORD='STRONG_USER_PASSWORD_HERE' pg_restore -U hqdms_user -d hqdms -c /var/backups/hqdms/hqdms_YYYYMMDD_HHMMSS.backup
```
**Reason:** Restores database from backup file.

### View Logs
```bash
# Backend logs
pm2 logs hqdms2-backend

# Apache error logs
sudo tail -f /var/log/apache2/hqdms2_error.log

# Apache access logs
sudo tail -f /var/log/apache2/hqdms2_access.log

# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*-main.log
```
**Reason:** Monitors application and server logs.

### Restart Services
```bash
# View backend status
pm2 status

# Restart backend
pm2 restart hqdms2-backend

# Restart Apache
sudo systemctl restart apache2

# Restart PostgreSQL
sudo systemctl restart postgresql
```
**Reason:** Restarts individual services as needed.

---

## Security Checklist

- ✅ Changed all default passwords
- ✅ Configured firewall (UFW)
- ✅ Restricted database to localhost
- ✅ Secured .env file permissions
- ✅ Setup automated backups
- ✅ Configured log rotation
- ✅ Added security headers in Apache
- ✅ Regular system updates scheduled

**Reason:** Essential security measures for production.

---

*Document prepared for Hospital Segamat Pharmacy Department*