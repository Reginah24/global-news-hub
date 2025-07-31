# Global News Hub Deployment Script for Windows PowerShell
# This script deploys the application to Docker Hub and the lab environment

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerUsername,
    
    [Parameter(Mandatory=$true)]
    [string]$NewsApiKey,
    
    [string]$Version = "v1.0",
    [string]$AppName = "global-news-hub"
)

Write-Host "🚀 Starting deployment of Global News Hub..." -ForegroundColor Green

# Step 1: Build the Docker image
Write-Host "📦 Building Docker image..." -ForegroundColor Yellow
$ImageTag = "${DockerUsername}/${AppName}:${Version}"
docker build -t $ImageTag .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Test locally
Write-Host "🧪 Testing image locally..." -ForegroundColor Yellow
docker run -d --name test-app -p 8080:8080 -e NEWS_API_KEY=$NewsApiKey $ImageTag

Start-Sleep -Seconds 10

# Test if the app is responding
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Local test passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Local test failed - unexpected status code: $($response.StatusCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Local test failed - cannot reach application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup test container
    docker stop test-app | Out-Null
    docker rm test-app | Out-Null
}

# Step 3: Login to Docker Hub
Write-Host "🔐 Logging into Docker Hub..." -ForegroundColor Yellow
docker login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Hub login failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Push to Docker Hub
Write-Host "⬆️  Pushing image to Docker Hub..." -ForegroundColor Yellow
docker push $ImageTag

# Also tag and push as latest
docker tag $ImageTag "${DockerUsername}/${AppName}:latest"
docker push "${DockerUsername}/${AppName}:latest"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Image pushed successfully to Docker Hub!" -ForegroundColor Green
Write-Host "📋 Image details:" -ForegroundColor Cyan
Write-Host "   Repository: ${DockerUsername}/${AppName}" -ForegroundColor White
Write-Host "   Tags: ${Version}, latest" -ForegroundColor White
Write-Host "   URL: https://hub.docker.com/r/${DockerUsername}/${AppName}" -ForegroundColor White

Write-Host ""
Write-Host "🚢 Next steps for lab deployment:" -ForegroundColor Cyan
Write-Host "1. SSH into web-01 and web-02" -ForegroundColor White
Write-Host "2. Run: docker pull ${ImageTag}" -ForegroundColor White
Write-Host "3. Run: docker run -d --name app --restart unless-stopped -p 8080:8080 -e NEWS_API_KEY=${NewsApiKey} ${ImageTag}" -ForegroundColor White
Write-Host "4. Configure HAProxy on lb-01 with the provided haproxy.cfg" -ForegroundColor White
Write-Host "5. Test load balancing with: curl http://localhost" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
