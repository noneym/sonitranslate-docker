#!/bin/bash

# Activate the 'sonitr' environment
source /opt/conda/etc/profile.d/conda.sh
conda activate sonitr

# Increase ulimits for file uploads
ulimit -n 65536
ulimit -f unlimited

# Run the Python application
python /app/SoniTranslate/app_rvc.py