# Use NVIDIA CUDA image with CUDA 12 and cuDNN 9
FROM nvidia/cuda:12.2.0-cudnn9-runtime-ubuntu20.04

# Set shell and noninteractive environment variables
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set working directory
WORKDIR /

# Update and install required system packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install --yes --no-install-recommends \
    sudo \
    ca-certificates \
    git \
    wget \
    curl \
    bash \
    libgl1 \
    libx11-6 \
    software-properties-common \
    ffmpeg \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-pip && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /requirements.txt --no-cache-dir

# Copy and run script to fetch models
COPY builder/fetch_models.py /fetch_models.py
RUN python /fetch_models.py && \
    rm /fetch_models.py

# Copy source code into image
COPY src .

# Set default command
CMD python -u /rp_handler.py
