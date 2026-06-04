# Use a lightweight stable Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app:/app/libs:/app/microservices/orchestrator/src:/app/microservices/distillation/src:/app/microservices/pruning/src:/app/microservices/quantization/src

# Set working directory
WORKDIR /app

# Install system dependencies (needed for some python packages)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Fix: Install CPU-only PyTorch (This is 150MB vs 4GB for the CUDA version)
# This prevents the "EOF" and memory crashes on limited systems.
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Install remaining dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --default-timeout=100 -r requirements.txt

# Copy the rest of the application
COPY . .

# Default command
CMD ["python"]
