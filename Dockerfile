FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    wget \
    git \
    tmux \
    byobu \
    zip \
    unzip \
    libopenblas-base libopenblas-dev liblapack-dev libatlas-base-dev\
    libfftw3-dev libfftw3-doc \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxrender1 libxext6 \
    ffmpeg \
    sox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG ROOT_PASSWORD="password"
RUN echo "root:$ROOT_PASSWORD" | chpasswd

WORKDIR /opt
RUN wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
RUN sh /opt/Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm -f Miniconda3-py39_4.9.2-Linux-x86_64.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV PATH /opt/miniconda3/bin:$PATH

RUN conda update -n base -c defaults conda
RUN conda init bash

RUN conda install -y -c intel cython=0.29.32
RUN conda install -y -c intel numpy=1.22.3
RUN conda install -y -c intel scipy=1.7.3
RUN conda install -y -c intel pandas=1.5.1

RUN conda install -y -c pytorch pytorch=1.13.1
RUN conda install -y -c pytorch torchaudio=0.13.1
RUN conda install -y -c conda-forge pytorch-lightning=1.9.0

RUN conda install -y -c conda-forge PyYAML=6.0
RUN conda install -y -c conda-forge hydra-core=1.0.6
RUN conda install -y -c conda-forge huggingface_hub==0.12.0
RUN conda install -y -c conda-forge pysoundfile=0.10.3.post1

RUN pip install --no-cache-dir pb_bss_eval==0.02
RUN pip install --no-cache-dir torch_stoi==0.01
RUN pip install --no-cache-dir torch_optimizer==0.0.1a12
RUN pip install --no-cache-dir asteroid-filterbanks==0.4.0
RUN pip install --no-cache-dir julius==0.2.7
RUN pip install --no-cache-dir requests
RUN pip install --no-cache-dir filelock

# User Setting
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
