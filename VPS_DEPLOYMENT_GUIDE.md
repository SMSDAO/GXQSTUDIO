# FXSOLBOT VPS Deployment Guide with Plesk

## Overview

This guide provides instructions for deploying the FXSOLBOT application on a VPS (Virtual Private Server) using Plesk control panel. We'll cover two deployment methods:

1. Docker-based deployment (recommended)
2. Traditional deployment

## Prerequisites

- VPS with Plesk installed
- Root or administrator access to the VPS
- Domain name configured in Plesk
- Basic knowledge of server administration

## Method 1: Docker-based Deployment (Recommended)

### Step 1: Install Docker on your VPS

1. Log in to your VPS via SSH:
   ```
   ssh user@your-vps-ip
   ```

2. Install Docker and Docker Compose:
   ```bash
   # For Debian/Ubuntu
   apt-get update
   apt-get install -y docker.io docker-compose
   
   # For CentOS/RHEL
   yum install -y docker docker-compose
   systemctl enable docker
   systemctl start docker
   ```

### Step 2: Set up the project on your VPS

1. Create a directory for your project:
   ```bash
   mkdir -p /var/www/fxsolbot
   cd /var/www/fxsolbot
   ```

2. Upload the project files to your VPS using SFTP or Git:
   ```bash
   # Using Git
   git clone https://your-repository-url.git .
   
   # Or upload files via SFTP and then extract
   # Upload your zip file and then:
   unzip fxsolbot.zip
   ```

### Step 3: Configure Docker deployment

1. Make sure the Dockerfile and docker-compose.yml files are in the project root directory.

2. Build and start the Docker containers:
   ```bash
   docker-compose up -d --build
   ```

3. Verify the containers are running:
   ```bash
   docker-compose ps
   ```

### Step 4: Configure Plesk for Docker

1. Log in to Plesk control panel.

2. Go to the domain where you want to deploy FXSOLBOT.

3. Navigate to the "Websites & Domains" tab.

4. Click on "Proxy Settings" for your domain.

5. Enable proxy and set up the following:
   - Proxy type: Reverse proxy
   - Proxy URL: http://localhost:80 (or the port you configured in docker-compose.yml)

6. Save the changes.

## Method 2: Traditional Deployment

### Step 1: Install required dependencies

1. Log in to your VPS via SSH:
   ```
   ssh user@your-vps-ip
   ```

2. Install Node.js, npm, and other dependencies:
   ```bash
   # For Debian/Ubuntu
   apt-get update
   apt-get install -y nodejs npm build-essential
   
   # For CentOS/RHEL
   yum install -y nodejs npm gcc-c++ make
   ```

3. Install Java (required for the application):
   ```bash
   # For Debian/Ubuntu
   apt-get install -y default-jre
   
   # For CentOS/RHEL
   yum install -y java-11-openjdk
   ```

### Step 2: Set up the project

1. Create a directory for your project in the Plesk document root:
   ```bash
   mkdir -p /var/www/vhosts/yourdomain.com/httpdocs/fxsolbot
   cd /var/www/vhosts/yourdomain.com/httpdocs/fxsolbot
   ```

2. Upload the pre-built application files:
   - Upload the contents of the `dashboard/build` directory to this location
   - Make sure to include all static assets, JavaScript, and CSS files

### Step 3: Configure Plesk

1. Log in to Plesk control panel.

2. Go to the domain where you want to deploy FXSOLBOT.

3. Navigate to the "Websites & Domains" tab.

4. Click on "Document Root" and set it to the directory where you uploaded the files (e.g., `/var/www/vhosts/yourdomain.com/httpdocs/fxsolbot`).

5. Set up proper permissions:
   ```bash
   chown -R psaserv:psacln /var/www/vhosts/yourdomain.com/httpdocs/fxsolbot
   chmod -R 755 /var/www/vhosts/yourdomain.com/httpdocs/fxsolbot
   ```

## Troubleshooting

### Java-related errors

If you encounter Java-related errors:

1. Verify Java is installed correctly:
   ```bash
   java -version
   ```

2. Set the JAVA_HOME environment variable:
   ```bash
   echo 'export JAVA_HOME=/path/to/java' >> /etc/environment
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/environment
   source /etc/environment
   ```

### Docker-related issues

1. Check Docker container logs:
   ```bash
   docker-compose logs
   ```

2. Verify container is running:
   ```bash
   docker ps
   ```

3. Restart the containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Plesk configuration issues

1. Check Plesk error logs in the Plesk control panel under "Websites & Domains" > "Logs".

2. Verify proxy settings are correctly configured if using the Docker method.

3. Check file permissions if using the traditional method.

## Maintenance

### Updating the application

#### Docker method:

```bash
cd /var/www/fxsolbot
git pull  # If using Git
docker-compose down
docker-compose up -d --build
```

#### Traditional method:

Upload the new files to the document root and replace the existing files.

### Backup

1. Create a backup of your application:
   ```bash
   # For Docker deployment
   cd /var/www/fxsolbot
   tar -czvf fxsolbot-backup.tar.gz .
   
   # For traditional deployment
   cd /var/www/vhosts/yourdomain.com/httpdocs
   tar -czvf fxsolbot-backup.tar.gz fxsolbot
   ```

2. Use Plesk's built-in backup tools to create a full backup of your domain.

## Security Considerations

1. Set up SSL/TLS for your domain through Plesk's "SSL/TLS Certificates" section.

2. Configure firewall rules to only allow necessary ports.

3. Regularly update your application and server components.

4. Use strong passwords for all accounts.

## Conclusion

Your FXSOLBOT application should now be successfully deployed on your VPS with Plesk. The Docker-based method provides better isolation and easier deployment, while the traditional method gives you more direct control over the application files.