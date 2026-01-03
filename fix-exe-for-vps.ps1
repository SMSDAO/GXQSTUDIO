# Fix EXE for VPS Deployment Script
Write-Host "===== FXSOLBOT Fix EXE for VPS Deployment =====" -ForegroundColor Cyan
Write-Host ""

# Check if the dist directory exists
$distDir = "dashboard\dist"
if (-not (Test-Path $distDir)) {
    Write-Host "Error: dist directory not found. Please build the application first." -ForegroundColor Red
    Write-Host "Run the build script: .\fast-build.ps1" -ForegroundColor Yellow
    exit 1
}

# Create a web-optimized version of the application
Write-Host "Creating web-optimized version for VPS deployment..." -ForegroundColor Yellow

# Create directory for web version
$webDir = "dashboard\web-deploy"
if (-not (Test-Path $webDir)) {
    New-Item -ItemType Directory -Path $webDir | Out-Null
    Write-Host "Created web deployment directory: $webDir" -ForegroundColor Green
}

# Copy the build files (Next.js static export)
Write-Host "Copying Next.js static files..." -ForegroundColor Yellow
Copy-Item -Path "dashboard\build\*" -Destination $webDir -Recurse -Force

# Create a server.js file for Node.js deployment
$serverJsPath = "$webDir\server.js"
$serverJsContent = @"
const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Serve static files
app.use(express.static(path.join(__dirname)));

// Handle API routes
app.get('/api/version', (req, res) => {
  res.json({ version: '1.0.0', environment: 'vps' });
});

// For any other route, serve the index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(port, () => {
  console.log(`FXSOLBOT web server running on port ${port}`);
});
"@

$serverJsContent | Out-File -FilePath $serverJsPath -Encoding utf8
Write-Host "Created server.js for Node.js deployment" -ForegroundColor Green

# Create a package.json for the web version
$webPackageJsonPath = "$webDir\package.json"
$webPackageJsonContent = @"
{
  "name": "fxsolbot-web",
  "version": "1.0.0",
  "description": "FXSOLBOT Web Deployment",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=14"
  }
}
"@

$webPackageJsonContent | Out-File -FilePath $webPackageJsonPath -Encoding utf8
Write-Host "Created package.json for web deployment" -ForegroundColor Green

# Create a .htaccess file for Apache deployment
$htaccessPath = "$webDir\.htaccess"
$htaccessContent = @"
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>

# Enable CORS
<IfModule mod_headers.c>
  Header set Access-Control-Allow-Origin "*"
  Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
  Header set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept"
</IfModule>
"@

$htaccessContent | Out-File -FilePath $htaccessPath -Encoding utf8
Write-Host "Created .htaccess for Apache deployment" -ForegroundColor Green

# Create a web.config file for IIS deployment
$webConfigPath = "$webDir\web.config"
$webConfigContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Static Assets" stopProcessing="true">
          <match url="([\.\w]+)$" />
          <action type="Rewrite" url="{R:1}" />
        </rule>
        <rule name="SPA Routes" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="index.html" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <mimeMap fileExtension=".json" mimeType="application/json" />
      <mimeMap fileExtension=".woff" mimeType="application/font-woff" />
      <mimeMap fileExtension=".woff2" mimeType="application/font-woff2" />
    </staticContent>
  </system.webServer>
</configuration>
"@

$webConfigContent | Out-File -FilePath $webConfigPath -Encoding utf8
Write-Host "Created web.config for IIS deployment" -ForegroundColor Green

# Create a Dockerfile for the web version
$webDockerfilePath = "$webDir\Dockerfile"
$webDockerfileContent = @"
FROM node:18-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
"@

$webDockerfileContent | Out-File -FilePath $webDockerfilePath -Encoding utf8
Write-Host "Created Dockerfile for web deployment" -ForegroundColor Green

# Create a docker-compose.yml file for the web version
$webDockerComposePath = "$webDir\docker-compose.yml"
$webDockerComposeContent = @"
version: '3.8'

services:
  fxsolbot-web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    restart: unless-stopped
    environment:
      - NODE_ENV=production
"@

$webDockerComposeContent | Out-File -FilePath $webDockerComposePath -Encoding utf8
Write-Host "Created docker-compose.yml for web deployment" -ForegroundColor Green

# Create a zip file for easy deployment
$zipPath = "dashboard\fxsolbot-web-deploy.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Write-Host "Creating deployment zip file..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($webDir, $zipPath)

Write-Host ""
Write-Host "Web deployment package created successfully!" -ForegroundColor Green
Write-Host "Deployment package: $zipPath" -ForegroundColor Green
Write-Host ""
Write-Host "To deploy to your VPS:" -ForegroundColor Yellow
Write-Host "1. Upload the zip file to your server" -ForegroundColor Yellow
Write-Host "2. Extract the contents to your web directory" -ForegroundColor Yellow
Write-Host "3. Follow the instructions in VPS_DEPLOYMENT_GUIDE.md" -ForegroundColor Yellow
Write-Host ""

Pause