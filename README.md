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

```bash
docker run -p 7860:7860 --gpus all sonitranslate
```

Access the web interface at http://localhost:7860

## Configuration

- Hugging Face token: Set `YOUR_HF_TOKEN` in the Dockerfile
- OpenAI API key: Uncomment and set `OPENAI_API_KEY` if needed

## Recent Changes

- Fixed Conda Terms of Service acceptance for automated builds
- Added proper channel configuration for Conda