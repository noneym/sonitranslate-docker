#!/bin/bash

# Activate the 'sonitr' environment
source /opt/conda/etc/profile.d/conda.sh
conda activate sonitr

# Increase ulimits for file uploads
ulimit -n 65536
ulimit -f unlimited

# ============== START NGINX FOR OUTPUTS ==============
echo "🌐 Starting nginx for outputs directory..."

# Ensure outputs directory exists
mkdir -p /app/SoniTranslate/outputs
chmod 755 /app/SoniTranslate/outputs

# Start nginx in background
nginx -t && nginx -g "daemon off;" &
NGINX_PID=$!

echo "✅ Nginx started (PID: $NGINX_PID)"
echo "📁 Outputs accessible at: http://localhost:8080/outputs/"
echo "🌐 Direct file access: http://localhost:8080/outputs/filename.mp4"

# =====================================================

echo "🚀 Starting SoniTranslate..."

# Function to cleanup nginx on exit
cleanup() {
    echo "🛑 Stopping nginx..."
    kill $NGINX_PID 2>/dev/null
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGTERM SIGINT

# Run the Python application
python /app/SoniTranslate/app_rvc.py &
PYTHON_PID=$!

# Wait for either process to exit
wait $PYTHON_PID