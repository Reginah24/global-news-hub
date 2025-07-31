# Load Balancer Testing Script for Global News Hub
# This script tests the round-robin load balancing functionality

param(
    [string]$LoadBalancerUrl = "http://localhost",
    [int]$TestRequests = 10,
    [int]$DelaySeconds = 1
)

Write-Host "🔄 Testing Load Balancer Configuration" -ForegroundColor Green
Write-Host "URL: $LoadBalancerUrl" -ForegroundColor Cyan
Write-Host "Requests: $TestRequests" -ForegroundColor Cyan
Write-Host "Delay: $DelaySeconds seconds" -ForegroundColor Cyan
Write-Host ""

$responses = @()
$serverCounts = @{}

for ($i = 1; $i -le $TestRequests; $i++) {
    try {
        Write-Host "Request $i..." -NoNewline
        
        $response = Invoke-WebRequest -Uri $LoadBalancerUrl -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            # Try to extract server information from response headers
            $server = $response.Headers['Server'] -join ','
            if ([string]::IsNullOrEmpty($server)) {
                $server = "Unknown"
            }
            
            $responses += @{
                Request = $i
                StatusCode = $response.StatusCode
                Server = $server
                ResponseTime = (Get-Date)
                ContentLength = $response.Content.Length
            }
            
            if ($serverCounts.ContainsKey($server)) {
                $serverCounts[$server]++
            } else {
                $serverCounts[$server] = 1
            }
            
            Write-Host " ✅ Success (Server: $server)" -ForegroundColor Green
        } else {
            Write-Host " ❌ Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host " ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    if ($i -lt $TestRequests) {
        Start-Sleep -Seconds $DelaySeconds
    }
}

Write-Host ""
Write-Host "📊 Load Balancing Results:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

$totalSuccessful = $responses.Count
Write-Host "Total Requests: $TestRequests" -ForegroundColor White
Write-Host "Successful: $totalSuccessful" -ForegroundColor Green
Write-Host "Failed: $($TestRequests - $totalSuccessful)" -ForegroundColor Red

Write-Host ""
Write-Host "Server Distribution:" -ForegroundColor Cyan
foreach ($server in $serverCounts.Keys) {
    $count = $serverCounts[$server]
    $percentage = [math]::Round(($count / $totalSuccessful) * 100, 2)
    Write-Host "  $server`: $count requests ($percentage%)" -ForegroundColor White
}

Write-Host ""

# Check if load balancing is working
if ($serverCounts.Keys.Count -gt 1) {
    Write-Host "✅ Load balancing appears to be working!" -ForegroundColor Green
    Write-Host "   Multiple servers are handling requests." -ForegroundColor White
} elseif ($serverCounts.Keys.Count -eq 1) {
    Write-Host "⚠️  All requests went to the same server." -ForegroundColor Yellow
    Write-Host "   This might indicate:" -ForegroundColor White
    Write-Host "   - Only one backend server is running" -ForegroundColor White
    Write-Host "   - Load balancer is not configured properly" -ForegroundColor White
    Write-Host "   - Session affinity is enabled" -ForegroundColor White
} else {
    Write-Host "❌ No successful requests completed." -ForegroundColor Red
    Write-Host "   Check if the load balancer and backend servers are running." -ForegroundColor White
}

Write-Host ""
Write-Host "🔍 Additional Checks:" -ForegroundColor Yellow

# Test HAProxy stats page if available
try {
    $statsResponse = Invoke-WebRequest -Uri "$($LoadBalancerUrl.TrimEnd('/')):8404/stats" -UseBasicParsing -TimeoutSec 5
    if ($statsResponse.StatusCode -eq 200) {
        Write-Host "✅ HAProxy stats page is accessible at $($LoadBalancerUrl.TrimEnd('/')):8404/stats" -ForegroundColor Green
    }
} catch {
    Write-Host "ℹ️  HAProxy stats page not accessible (this is normal if not configured)" -ForegroundColor Gray
}

# Test individual backend servers
Write-Host ""
Write-Host "Testing Backend Servers Directly:" -ForegroundColor Cyan
$backendServers = @("http://172.20.0.11:8080", "http://172.20.0.12:8080")

foreach ($backend in $backendServers) {
    try {
        $backendResponse = Invoke-WebRequest -Uri $backend -UseBasicParsing -TimeoutSec 5
        if ($backendResponse.StatusCode -eq 200) {
            Write-Host "✅ $backend is responding" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $backend returned status $($backendResponse.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $backend is not accessible: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Load balancer testing completed!" -ForegroundColor Green
