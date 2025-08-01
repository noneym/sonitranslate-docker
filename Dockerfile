# Use a base image with CUDA support
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Install the necessary tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git ffmpeg nginx && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init

# Add the path to conda to the environment
ENV PATH=/opt/conda/bin:$PATH

# Accept Conda Terms of Service for default channels
RUN /opt/conda/bin/conda config --set channel_priority flexible && \
    /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create and activate the conda environment
RUN /opt/conda/bin/conda create -n sonitr python=3.10 -y && \
    /opt/conda/bin/conda run -n sonitr pip install pip==23.1.2

# Specify the working directory
WORKDIR /app

# Clone the SoniTranslate repository
RUN git clone https://github.com/r3gm/SoniTranslate.git

# Install the necessary compilers and tools
RUN apt-get update && apt-get install -y build-essential cmake nano

# Install the requirements_base.txt dependencies
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install -r requirements_base.txt -v

# Install the dependencies requirements_extra.txt
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install -r requirements_extra.txt -v

# Install onnxruntime-gpu
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install onnxruntime-gpu

# Install dependencies requirements_xtts.txt
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install -q -r requirements_xtts.txt

# Install TTS 0.21.1 without dependencies
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install -q TTS==0.21.1 --no-deps

# Remove old versions of numpy, pandas and librosa
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip uninstall -y numpy pandas librosa

# Install the required versions of numpy, pandas and librosa
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install numpy==1.23.1 pandas==1.4.3 librosa==0.10.0

# Install the required versions of tts and torchcrepe
RUN cd /app/SoniTranslate && /opt/conda/bin/conda run -n sonitr pip install "tts<0.21.0" "torchcrepe<0.0.20"

# Set up environment variables in conda
RUN /opt/conda/bin/conda run -n sonitr conda env config vars set YOUR_HF_TOKEN="INSERT_TOKEN_HERE"

# Set up environment variables in conda
#RUN /opt/conda/bin/conda run -n sonitr conda env config vars set OPENAI_API_KEY="INSERT_TOKEN_HERE"

# Modify app_rvc.py to add server_name="0.0.0.0"
RUN sed -i '/app\.launch(/,/debug=/s/max_threads=1,/max_threads=1, server_name="0.0.0.0",/' /app/SoniTranslate/app_rvc.py

# ============== NGINX FOR OUTPUTS ==============
# Create outputs directory
RUN mkdir -p /app/SoniTranslate/outputs && chmod 755 /app/SoniTranslate/outputs

# Configure nginx to serve outputs directory
RUN rm /etc/nginx/sites-enabled/default && \
    echo 'server {' > /etc/nginx/sites-available/outputs && \
    echo '    listen 8080;' >> /etc/nginx/sites-available/outputs && \
    echo '    server_name localhost;' >> /etc/nginx/sites-available/outputs && \
    echo '    ' >> /etc/nginx/sites-available/outputs && \
    echo '    location /outputs/ {' >> /etc/nginx/sites-available/outputs && \
    echo '        alias /app/SoniTranslate/outputs/;' >> /etc/nginx/sites-available/outputs && \
    echo '        autoindex on;' >> /etc/nginx/sites-available/outputs && \
    echo '        add_header Access-Control-Allow-Origin *;' >> /etc/nginx/sites-available/outputs && \
    echo '    }' >> /etc/nginx/sites-available/outputs && \
    echo '    ' >> /etc/nginx/sites-available/outputs && \
    echo '    location / {' >> /etc/nginx/sites-available/outputs && \
    echo '        return 301 /outputs/;' >> /etc/nginx/sites-available/outputs && \
    echo '    }' >> /etc/nginx/sites-available/outputs && \
    echo '}' >> /etc/nginx/sites-available/outputs && \
    ln -s /etc/nginx/sites-available/outputs /etc/nginx/sites-enabled/outputs

# ==================================================

# Set environment variables for Gradio
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV GRADIO_SERVER_PORT=7860
ENV GRADIO_MAX_FILE_SIZE="5gb"
ENV PYTHONUNBUFFERED=1

# Open ports 7860 (Gradio) and 8080 (Outputs)
EXPOSE 7860 8080

# Copy entrypoint.sh to container, fix line endings, and make it executable
COPY entrypoint.sh /app/entrypoint.sh
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Go to repository directory
WORKDIR /app/SoniTranslate

# Command to run Python application via entrypoint.sh
CMD ["/bin/bash", "-c", "/app/entrypoint.sh"]