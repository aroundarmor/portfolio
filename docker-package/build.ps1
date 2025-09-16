# Portfolio Docker Build Script for Windows PowerShell
# Author: Sourav Patel
# Description: Build and deploy portfolio using Docker

param(
    [Parameter(Position=0)]
    [ValidateSet("build", "compose", "stop", "logs", "health", "cleanup", "test", "push", "menu")]
    [string]$Action = "menu",
    [Parameter(Position=1)]
    [string]$Tag = "latest"
)

# Configuration
$ImageName = "sourav-portfolio"
$DockerHubUser = "aroundarmor"
$DockerHubRepo = "portfolio"
$ContainerName = "portfolio-container"
$Port = "8080"
$ComposeFile = "docker-compose.yml"

# Functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Docker is running
function Test-Docker {
    try {
        docker info | Out-Null
        Write-Success "Docker is running"
        return $true
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop and try again."
        return $false
    }
}

# Build Docker image
function Build-Image {
    Write-Info "Building Docker image: $ImageName"
    
    # Check if docs directory exists
    if (-not (Test-Path "../docs")) {
        Write-Error "docs directory not found. Please run this script from docker-package directory."
        exit 1
    }
    
    # Build the image
    try {
        docker build -f Dockerfile -t $ImageName ..
        Write-Success "Docker image built successfully"
    }
    catch {
        Write-Error "Failed to build Docker image"
        exit 1
    }
}

# Run container
function Start-Container {
    Write-Info "Starting container: $ContainerName"
    
    # Stop and remove existing container if it exists
    $existingContainer = docker ps -a --format "table {{.Names}}" | Select-String "^$ContainerName$"
    if ($existingContainer) {
        Write-Warning "Stopping existing container"
        docker stop $ContainerName | Out-Null
        docker rm $ContainerName | Out-Null
    }
    
    # Run new container
    try {
        docker run -d --name $ContainerName -p "${Port}:8080" --restart unless-stopped $ImageName | Out-Null
        Write-Success "Container started successfully"
        Write-Info "Portfolio is available at: http://localhost:$Port"
    }
    catch {
        Write-Error "Failed to start container"
        exit 1
    }
}

# Health check
function Test-Health {
    Write-Info "Performing health check..."
    
    # Wait for container to start
    Start-Sleep -Seconds 5
    
    # Check if container is running
    $runningContainer = docker ps --format "table {{.Names}}" | Select-String "^$ContainerName$"
    if (-not $runningContainer) {
        Write-Error "Container is not running"
        docker logs $ContainerName
        exit 1
    }
    
    # Check if application is responding
    for ($i = 1; $i -le 10; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port/health" -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Success "Health check passed"
                return
            }
        }
        catch {
            Write-Info "Waiting for application to start... ($i/10)"
            Start-Sleep -Seconds 2
        }
    }
    
    Write-Error "Health check failed"
    docker logs $ContainerName
    exit 1
}

# Show logs
function Show-Logs {
    Write-Info "Showing container logs..."
    docker logs -f $ContainerName
}

# Stop container
function Stop-Container {
    Write-Info "Stopping container: $ContainerName"
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
    Write-Success "Container stopped and removed"
}

# Clean up
function Clear-DockerResources {
    Write-Info "Cleaning up Docker resources..."
    docker system prune -f
    docker volume prune -f
    Write-Success "Cleanup completed"
}

# Test portfolio URL
function Test-Portfolio {
    Write-Info "Testing portfolio URL..."
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port/" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "Portfolio is accessible at http://localhost:$Port"
        } else {
            Write-Warning "Portfolio returned status code: $($response.StatusCode)"
        }
    }
    catch {
        Write-Warning "Portfolio might not be accessible yet"
        Write-Info "Try accessing http://localhost:$Port manually"
    }
}

# Get tag from user input
function Get-TagInput {
    param([string]$DefaultTag = "latest")
    
    Write-Host ""
    Write-Host "Enter tag for Docker Hub (press Enter for '$DefaultTag'): " -NoNewline -ForegroundColor Yellow
    $userInput = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        return $DefaultTag
    } else {
        return $userInput.Trim()
    }
}

# Push to Docker Hub
function Push-ToDockerHub {
    param([string]$TagName = $Tag)
    
    # If no tag provided, ask user for input
    if ($TagName -eq "latest") {
        $TagName = Get-TagInput -DefaultTag "latest"
    }
    
    Write-Info "Pushing image to Docker Hub with tag: $TagName"
    
    # Check if user is logged in to Docker Hub
    try {
        docker info | Select-String "Username" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Not logged in to Docker Hub. Please run: docker login"
            Write-Info "You can login with: docker login -u aroundarmor"
            return
        }
    }
    catch {
        Write-Warning "Could not verify Docker Hub login status"
    }
    
    # Create Docker Hub image name
    $DockerHubImage = "${DockerHubUser}/${DockerHubRepo}:${TagName}"
    
    # Tag the local image for Docker Hub
    Write-Info "Tagging image as: $DockerHubImage"
    docker tag $ImageName $DockerHubImage
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to tag image"
        return
    }
    
    # Push to Docker Hub
    Write-Info "Pushing to Docker Hub..."
    docker push $DockerHubImage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Successfully pushed to Docker Hub: $DockerHubImage"
        Write-Info "You can now pull this image with: docker pull $DockerHubImage"
    } else {
        Write-Error "Failed to push to Docker Hub"
    }
}

# Build and push to Docker Hub
function Build-AndPush {
    param([string]$TagName = $Tag)
    
    # If no tag provided, ask user for input
    if ($TagName -eq "latest") {
        $TagName = Get-TagInput -DefaultTag "latest"
    }
    
    Write-Info "Building and pushing to Docker Hub with tag: $TagName"
    
    # Build the image
    Build-Image
    
    if ($LASTEXITCODE -eq 0) {
        # Push to Docker Hub
        Push-ToDockerHub -TagName $TagName
    } else {
        Write-Error "Build failed, skipping push"
    }
}

# Docker Compose functions
function Start-Compose {
    Write-Info "Starting services with Docker Compose..."
    try {
        docker-compose up -d
        Write-Success "Services started successfully"
        Write-Info "Portfolio is available at: http://localhost:$Port"
    }
    catch {
        Write-Error "Failed to start services"
        exit 1
    }
}

function Stop-Compose {
    Write-Info "Stopping services with Docker Compose..."
    docker-compose down
    Write-Success "Services stopped"
}

function Show-ComposeLogs {
    Write-Info "Showing Docker Compose logs..."
    docker-compose logs -f
}

# Main menu
function Show-Menu {
    Write-Host "Portfolio Docker Management" -ForegroundColor Blue
    Write-Host "=========================="
    Write-Host "1. Build and run (single container)"
    Write-Host "2. Build and run (Docker Compose)"
    Write-Host "3. Stop container"
    Write-Host "4. Show logs"
    Write-Host "5. Health check"
    Write-Host "6. Test portfolio URL"
    Write-Host "7. Push to Docker Hub"
    Write-Host "8. Build and push to Docker Hub"
    Write-Host "9. Cleanup"
    Write-Host "10. Exit"
    Write-Host ""
    Write-Host "Current tag: $Tag" -ForegroundColor Yellow
    Write-Host "Docker Hub: ${DockerHubUser}/${DockerHubRepo}:${Tag}" -ForegroundColor Yellow
    Write-Host ""
}

# Main execution
function Main {
    switch ($Action) {
        "build" {
            if (Test-Docker) {
                Build-Image
                Start-Container
                Test-Health
            }
        }
        "compose" {
            if (Test-Docker) {
                Start-Compose
            }
        }
        "stop" {
            Stop-Container
        }
        "logs" {
            Show-Logs
        }
        "health" {
            Test-Health
        }
        "cleanup" {
            Clear-DockerResources
        }
        "test" {
            Test-Portfolio
        }
        "push" {
            if ($Tag -eq "latest") {
                $Tag = Get-TagInput -DefaultTag "latest"
            }
            Push-ToDockerHub -TagName $Tag
        }
        "menu" {
            while ($true) {
                Show-Menu
                $choice = Read-Host "Select an option (1-10)"
                switch ($choice) {
                    "1" {
                        if (Test-Docker) {
                            Build-Image
                            Start-Container
                            Test-Health
                            Test-Portfolio
                        }
                    }
                    "2" {
                        if (Test-Docker) {
                            Start-Compose
                        }
                    }
                    "3" {
                        Stop-Container
                    }
                    "4" {
                        Show-Logs
                    }
                    "5" {
                        Test-Health
                    }
                    "6" {
                        Test-Portfolio
                    }
                    "7" {
                        Push-ToDockerHub -TagName $Tag
                    }
                    "8" {
                        if (Test-Docker) {
                            Build-AndPush -TagName $Tag
                        }
                    }
                    "9" {
                        Clear-DockerResources
                    }
                    "10" {
                        Write-Info "Goodbye!"
                        exit 0
                    }
                    default {
                        Write-Error "Invalid option. Please try again."
                    }
                }
                Write-Host ""
                Read-Host "Press Enter to continue..."
                Clear-Host
            }
        }
    }
}

# Run main function
Main
