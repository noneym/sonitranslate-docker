#!/bin/bash

# Activate the 'sonitr' environment
source /opt/conda/etc/profile.d/conda.sh
conda activate sonitr

# Increase ulimits for file uploads
ulimit -n 65536
ulimit -f unlimited

# ============== MAINTAIN OUTPUTS SYMLINK ==============
echo "🔗 Checking outputs symlink..."

# Ensure /tmp/gradio directory exists
mkdir -p /tmp/gradio

# Create or maintain symlink for outputs directory
if [ ! -L /tmp/gradio/outputs ]; then
    echo "📁 Creating symlink: /tmp/gradio/outputs -> /app/SoniTranslate/outputs"
    ln -sf /app/SoniTranslate/outputs /tmp/gradio/outputs
else
    echo "✅ Outputs symlink already exists"
fi

# Ensure outputs directory exists and has proper permissions
mkdir -p /app/SoniTranslate/outputs
chmod 755 /app/SoniTranslate/outputs
chmod 755 /tmp/gradio/outputs

echo "🌐 Outputs HTTP access enabled at: http://localhost:7860/file=/tmp/gradio/outputs/filename"
echo "📁 Outputs will be accessible via: /file=/tmp/gradio/outputs/"

# =====================================================

echo "🚀 Starting SoniTranslate..."

# Run the Python application
python /app/SoniTranslate/app_rvc.py