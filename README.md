# SoniTranslate Docker

Docker container for SoniTranslate - AI-powered audio translation and voice cloning tool.

## Features

- CUDA 11.8 support for GPU acceleration
- Pre-configured Python 3.10 environment
- All required dependencies for SoniTranslate
- Web interface accessible on port 7860

## Requirements

- Docker with NVIDIA container runtime
- NVIDIA GPU (recommended)

## Build

```bash
docker build -t sonitranslate .
```

## Run

**With GPU support (recommended):**
```bash
docker run -p 7860:7860 --gpus all sonitranslate
```

**CPU only:**
```bash
docker run -p 7860:7860 sonitranslate
```

**Note:** GPU support requires NVIDIA Container Toolkit to be installed on the host system.

Access the web interface at http://localhost:7860

## Configuration

- Hugging Face token: Set `YOUR_HF_TOKEN` in the Dockerfile
- OpenAI API key: Uncomment and set `OPENAI_API_KEY` if needed

## Easypanel Deployment

### With GPU Support
Use Docker Compose mode with this configuration:
```yaml
version: '3.8'
services:
  sonitranslate:
    build: .
    ports:
      - "7860:7860"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### CPU Only Mode
Use Template deployment with:
- Port: 7860
- No additional configuration needed

## Recent Changes

- Fixed Conda Terms of Service acceptance for automated builds
- Added proper channel configuration for Conda
- Fixed Windows line endings in entrypoint.sh