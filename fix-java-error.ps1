# Fix Java Error Script for FXSOLBOT
Write-Host "===== FXSOLBOT Java Error Fix =====" -ForegroundColor Cyan
Write-Host ""

# Check if Java is installed
$javaInstalled = $false
$javaVersion = $null

try {
    $javaVersion = & java -version 2>&1
    $javaInstalled = $true
    Write-Host "Java is installed:" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor Green
} catch {
    Write-Host "Java is not installed or not in PATH." -ForegroundColor Red
}

# If Java is not installed, offer to download and install it
if (-not $javaInstalled) {
    Write-Host "The FXSOLBOT application requires Java Runtime Environment (JRE)." -ForegroundColor Yellow
    Write-Host "Would you like to download and install Java?" -ForegroundColor Yellow
    $installJava = Read-Host "Enter 'Y' to download and install Java, or any other key to skip"
    
    if ($installJava -eq 'Y' -or $installJava -eq 'y') {
        # Download Java installer
        $javaInstallerUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=246808_424b9da4b48848379167015dcc250d8d" # JRE 8u371 Windows x64
        $javaInstallerPath = "$env:TEMP\jre-8-windows-x64.exe"
        
        Write-Host "Downloading Java installer..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $javaInstallerUrl -OutFile $javaInstallerPath
            Write-Host "Download completed." -ForegroundColor Green
            
            # Run the installer
            Write-Host "Running Java installer..." -ForegroundColor Yellow
            Write-Host "Please follow the installation prompts." -ForegroundColor Yellow
            Start-Process -FilePath $javaInstallerPath -Wait
            
            # Check if Java is now installed
            try {
                $javaVersion = & java -version 2>&1
                Write-Host "Java installation successful:" -ForegroundColor Green
                Write-Host $javaVersion -ForegroundColor Green
            } catch {
                Write-Host "Java installation may not have completed successfully." -ForegroundColor Red
                Write-Host "Please install Java manually from: https://www.java.com/download/" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Failed to download Java installer." -ForegroundColor Red
            Write-Host "Please install Java manually from: https://www.java.com/download/" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Skipping Java installation." -ForegroundColor Yellow
        Write-Host "Please install Java manually from: https://www.java.com/download/" -ForegroundColor Yellow
    }
}

# Fix Java path in Electron app
Write-Host ""
Write-Host "Fixing Java path in FXSOLBOT application..." -ForegroundColor Yellow

# Find Java installation path
$javaHome = $env:JAVA_HOME
if (-not $javaHome) {
    # Try to find Java installation directory
    $possibleJavaPaths = @(
        "C:\Program Files\Java\*",
        "C:\Program Files (x86)\Java\*"
    )
    
    foreach ($path in $possibleJavaPaths) {
        $javaFolders = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | Sort-Object -Property LastWriteTime -Descending
        if ($javaFolders -and $javaFolders.Count -gt 0) {
            $javaHome = $javaFolders[0].FullName
            break
        }
    }
}

if ($javaHome) {
    Write-Host "Found Java installation at: $javaHome" -ForegroundColor Green
    
    # Create a .env file with Java path
    $envFilePath = "dashboard\.env.local"
    $envContent = @"
JAVA_HOME=$javaHome
PATH=$javaHome\bin;%PATH%
"@
    
    $envContent | Out-File -FilePath $envFilePath -Encoding utf8
    Write-Host "Created environment configuration at: $envFilePath" -ForegroundColor Green
    
    # Update electron main.js to include Java path
    $mainJsPath = "dashboard\electron\main.js"
    $mainJsContent = Get-Content -Path $mainJsPath -Raw
    
    if (-not $mainJsContent.Contains("process.env.PATH")) {
        $processEnvCode = @"

// Set Java path for external processes
if (process.env.JAVA_HOME) {
  const pathSep = process.platform === 'win32' ? ';' : ':';
  process.env.PATH = `${process.env.JAVA_HOME}\\bin${pathSep}${process.env.PATH}`;
  console.log('Added Java to PATH:', process.env.JAVA_HOME);
}
"@
        
        # Insert the code after the first require statements
        $insertPosition = $mainJsContent.IndexOf("const isDev = require('electron-is-dev');") + "const isDev = require('electron-is-dev');".Length
        $newMainJsContent = $mainJsContent.Insert($insertPosition, $processEnvCode)
        
        $newMainJsContent | Out-File -FilePath $mainJsPath -Encoding utf8
        Write-Host "Updated main.js to include Java path" -ForegroundColor Green
    } else {
        Write-Host "main.js already contains Java path configuration" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Java error fix has been applied!" -ForegroundColor Green
    Write-Host "Please rebuild the application using the fast-build.ps1 script." -ForegroundColor Yellow
} else {
    Write-Host "Could not find Java installation directory." -ForegroundColor Red
    Write-Host "Please make sure Java is installed and JAVA_HOME environment variable is set." -ForegroundColor Yellow
}

Write-Host ""
Pause