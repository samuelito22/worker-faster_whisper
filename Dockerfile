# Use specific Python slim image
FROM python:3.11.4-slim-bullseye

# Set shell and noninteractive environment variables
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set working directory
WORKDIR /

# Update and install system packages
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
    build-essential && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# Copy and run script to fetch models
COPY builder/fetch_models.py /fetch_models.py
RUN python /fetch_models.py && \
    rm /fetch_models.py

# Copy source code into image
COPY src .

# Set default command
CMD python -u /rp_handler.py
