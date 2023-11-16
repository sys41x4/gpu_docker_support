FROM dev_nvidia_cuda_118_cudnn:20.04

LABEL maintainer="Arijit Bhowmick <arijit_bhowmick@outlook.com>"

# Fix timezone issues
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND noninteractive # export DEBIAN_FRONTEND="noninteractive"
# ENV CONDA_DIR_PATH=/root/miniconda

RUN mkdir -p /data /scripts /installer
COPY scripts/ /scripts/
COPY scripts/startup.sh /

WORKDIR /workspace/

    
# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
RUN echo "/usr/local/cuda/lib64" | sudo tee -a /etc/ld.so.conf && ldconfig

# Install Conda | Miniconda3
RUN /scripts/conda/miniconda3/setup_x64.sh

## COMMONS ##

# Cleanup
## Removed initially supplied /data /scripts /installer directories
RUN rm -r /data /scripts /installer
## APT cache cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/bash /startup.sh
