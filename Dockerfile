# Base image with CUDA 12.1 runtime and cuDNN
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

# Install essential system tools and Python
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    unzip \
    htop \
    vim \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a symbolic link to enable `python` instead of `python3`
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install global python tools
RUN python -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir debugpy jupyterlab

# Set working directory
WORKDIR /workspace

# Clone the repository and install segger with CUDA 12 support
RUN git clone https://github.com/TKMarkCheng/segger_dev.git /workspace/segger_dev && \
    pip install -e "/workspace/segger_dev[cuda12]" && \
    pip install torch==2.5.1 torchvision==0.20.1 --index-url https://download.pytorch.org/whl/cu124 && \
    pip install dask[distributed] && \
    pip install dask-geopandas lightning cupy-cuda12x

# Set environment variables
ENV PYTHONPATH=/workspace/segger_dev/src:$PYTHONPATH

# expose ports for debugpy and jupyterlab
EXPOSE 5678 8888

# sudo docker run --runtime=nvidia -it -v /mnt/compute_2/Mark/ABMR/:/workspace/ABMR/ segger:latest
# python3 segger_dev/src/segger/cli/create_dataset_fast.py --base_dir "ABMR/ABMR_Xenium/20250313__132325__SGP233_run1/output-XETG00335__0038144__BW74-KID-0-FFPE-1-S1-iv__20250313__132424" --data_dir ABMR/segger_output/BW74 --sample_type xenium

# running with jupyter
# sudo docker run --runtime=nvidia -it -p 8080:8888 -v /mnt/compute_2/Mark/ABMR/:/workspace/ABMR/ segger:latest
# `jupyter lab --ip=0.0.0.0 --port=8080 --allow-root` on docker image
# using browser visit http://localhost:8080/