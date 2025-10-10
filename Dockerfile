# Dockerfile for GIGA
FROM ros:noetic-ros-base

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      wget git cmake build-essential \
      libeigen3-dev libopencv-dev libpcl-dev \
      libyaml-cpp-dev libgoogle-glog-dev \
      libhdf5-dev libgflags-dev \
      openmpi-bin libopenmpi-dev \
      python3-catkin-tools \
      ros-noetic-tf2-ros \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda and create conda env
ENV CONDA_DIR=/opt/conda
RUN wget -qO /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
 && bash /tmp/miniconda.sh -b -p $CONDA_DIR \
 && rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda config --set channel_priority flexible && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create conda env (giga)
RUN conda create -y -n giga python=3.8 && conda clean -a -y

# Clone repo
RUN git clone https://github.com/UT-Austin-RPL/GIGA /GIGA

# Install Python dependencies inside the conda env
RUN export SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True && \
    /opt/conda/envs/giga/bin/pip install --no-cache-dir -r /GIGA/requirements.txt && \
    /opt/conda/envs/giga/bin/pip install --no-cache-dir "numpy==1.23.5" && \
    /opt/conda/envs/giga/bin/pip install scikit-learn==0.24.2


# Make sure conda env is activated by default
SHELL ["/bin/bash", "-c"]
RUN echo "source $CONDA_DIR/etc/profile.d/conda.sh && conda activate giga" >> ~/.bashrc

# Create a workspace folder 
RUN mkdir -p /GIGA/catkin_ws

# Set working directory to /GIGA 
WORKDIR /GIGA

RUN /opt/conda/envs/giga/bin/pip install --no-cache-dir --no-index \
    torch-scatter==2.0.9 \
    -f https://data.pyg.org/whl/torch-1.10.2+cu113.html

RUN /opt/conda/envs/giga/bin/pip install torchvision==0.8.1

# PyTorch + CUDA 11.3 matching torchvision
RUN /opt/conda/envs/giga/bin/pip install \
      torch==1.10.2+cu113 torchvision==0.11.3+cu113 \
      -f https://download.pytorch.org/whl/cu113/torch_stable.html


RUN pip3 install --no-cache-dir catkin_pkg
RUN /opt/conda/envs/giga/bin/pip install -e .

# Default to bash
CMD ["bash"]