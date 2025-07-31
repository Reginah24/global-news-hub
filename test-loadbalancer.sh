#!/bin/bash

# Load Balancer Testing Script for Global News Hub
# This script tests the round-robin load balancing functionality

# Default parameters
LOAD_BALANCER_URL="http://localhost"
TEST_REQUESTS=10
DELAY_SECONDS=1

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            LOAD_BALANCER_URL="$2"
            shift 2
            ;;
        --requests)
            TEST_REQUESTS="$2"
            shift 2
            ;;
        --delay)
            DELAY_SECONDS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--url URL] [--requests NUM] [--delay SECONDS]"
            echo "  --url URL         Load balancer URL (default: http://localhost)"
            echo "  --requests NUM    Number of test requests (default: 10)"
            echo "  --delay SECONDS   Delay between requests (default: 1)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🔄 Testing Load Balancer Configuration"
echo "URL: $LOAD_BALANCER_URL"
echo "Requests: $TEST_REQUESTS"
echo "Delay: $DELAY_SECONDS seconds"
echo ""

# Arrays to store results
declare -A server_counts
total_successful=0
total_failed=0

for ((i=1; i<=TEST_REQUESTS; i++)); do
    echo -n "Request $i..."
    
    # Make HTTP request and capture response
    response=$(curl -s -w "%{http_code}|%{server}|%{size_download}" -o /dev/null "$LOAD_BALANCER_URL" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Parse curl response
        IFS='|' read -r status_code server content_length <<< "$response"
        
        if [ "$status_code" = "200" ]; then
            if [ -z "$server" ] || [ "$server" = "-" ]; then
                server="Unknown"
            fi
            
            # Count server responses
            if [ -z "${server_counts[$server]}" ]; then
                server_counts[$server]=1
            else
                ((server_counts[$server]++))
            fi
            
            ((total_successful++))
            echo " ✅ Success (Server: $server)"
        else
            echo " ❌ Failed (Status: $status_code)"
            ((total_failed++))
        fi
    else
        echo " ❌ Error: Connection failed"
        ((total_failed++))
    fi
    
    if [ $i -lt $TEST_REQUESTS ]; then
        sleep $DELAY_SECONDS
    fi
done

echo ""
echo "📊 Load Balancing Results:"
echo "========================="

echo "Total Requests: $TEST_REQUESTS"
echo "Successful: $total_successful"
echo "Failed: $total_failed"

echo ""
echo "Server Distribution:"
for server in "${!server_counts[@]}"; do
    count=${server_counts[$server]}
    if [ $total_successful -gt 0 ]; then
        percentage=$(echo "scale=2; ($count / $total_successful) * 100" | bc -l 2>/dev/null || echo "0")
        echo "  $server: $count requests ($percentage%)"
    else
        echo "  $server: $count requests (N/A%)"
    fi
done

echo ""

# Check if load balancing is working
server_count=${#server_counts[@]}
if [ $server_count -gt 1 ]; then
    echo "✅ Load balancing appears to be working!"
    echo "   Multiple servers are handling requests."
elif [ $server_count -eq 1 ]; then
    echo "⚠️  All requests went to the same server."
    echo "   This might indicate:"
    echo "   - Only one backend server is running"
    echo "   - Load balancer is not configured properly"
    echo "   - Session affinity is enabled"
else
    echo "❌ No successful requests completed."
    echo "   Check if the load balancer and backend servers are running."
fi

echo ""
echo "🔍 Additional Checks:"

# Test HAProxy stats page if available
stats_url="${LOAD_BALANCER_URL%/}:8404/stats"
if curl -s --connect-timeout 5 "$stats_url" > /dev/null 2>&1; then
    echo "✅ HAProxy stats page is accessible at $stats_url"
else
    echo "ℹ️  HAProxy stats page not accessible (this is normal if not configured)"
fi

# Test individual backend servers
echo ""
echo "Testing Backend Servers Directly:"
backend_servers=("http://172.20.0.11:8080" "http://172.20.0.12:8080")

for backend in "${backend_servers[@]}"; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$backend" 2>/dev/null)
    
    if [ "$status_code" = "200" ]; then
        echo "✅ $backend is responding"
    elif [ "$status_code" = "000" ]; then
        echo "❌ $backend is not accessible: Connection failed"
    else
        echo "⚠️  $backend returned status $status_code"
    fi
done

echo ""
echo "🎉 Load balancer testing completed!"