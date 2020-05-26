# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# THIS IS A GENERATED DOCKERFILE.
#
# This file was assembled from multiple pieces, whose use is documented
# throughout. Please refer to the the TensorFlow dockerfiles documentation
# for more information.

FROM nvidia/cuda-ppc64le:10.0-base-ubuntu18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-10-0 \
        cuda-cublas-dev-10-0 \
        cuda-cudart-dev-10-0 \
        cuda-cufft-dev-10-0 \
        cuda-curand-dev-10-0 \
        cuda-cusolver-dev-10-0 \
        cuda-cusparse-dev-10-0 \
        curl \
        git \
        libcudnn7=7.4.2.24-1+cuda10.0 \
        libcudnn7-dev=7.4.2.24-1+cuda10.0 \
        libnccl2=2.3.7-1+cuda10.0 \
        libnccl-dev=2.3.7-1+cuda10.0 \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        && \
    rm -rf /var/lib/apt/lists/* && \
    find /usr/local/cuda-10.0/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete && \
    rm /usr/lib/powerpc64le-linux-gnu/libcudnn_static_v7.a

# Link NCCL libray and header where the build script expects them.
RUN mkdir /usr/local/cuda-10.0/lib &&  \
    ln -s /usr/lib/powerpc64le-linux-gnu/libnccl.so.2 /usr/local/cuda/lib/libnccl.so.2 && \
    ln -s /usr/include/nccl.h /usr/local/cuda/include/nccl.h

# Configure the build for our CUDA configuration.
ENV CI_BUILD_PYTHON python
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV TF_NEED_CUDA 1
ENV TF_NEED_TENSORRT 0
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
ENV TF_CUDA_VERSION=10.0
ENV TF_CUDNN_VERSION=7

# NCCL 2.x
ENV TF_NCCL_VERSION=2

ARG USE_PYTHON_3_NOT_2
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which ${PYTHON}) /usr/local/bin/python

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    openjdk-8-jdk \
    ${PYTHON}-dev \
    swig

RUN ${PIP} --no-cache-dir install \
    Pillow \
    future \
    h5py \
    keras_applications \
    keras_preprocessing \
    matplotlib \
    mock \
    numpy \
    scipy \
    sklearn \
    pandas \
    && test "${USE_PYTHON_3_NOT_2}" -eq 1 && true || ${PIP} --no-cache-dir install \
    enum34

 # Build and install bazel
ENV BAZEL_VERSION 0.24.1
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-dist.zip && \
    unzip bazel-$BAZEL_VERSION-dist.zip && \
    sed -i '/--action_env=PATH \\/a\  --host_javabase=@bazel_tools//tools/jdk:jdk \\' compile.sh && \
    bash ./compile.sh && \
    cp output/bazel /usr/local/bin/ && \
    rm -rf /bazel && \
    cd -

RUN ${PIP} install jupyter matplotlib

RUN mkdir -p /tf/tensorflow-tutorials && chmod -R a+rwx /tf/
RUN mkdir /.local && chmod a+rwx /.local
RUN apt-get update && apt-get install -y --no-install-recommends wget
WORKDIR /tf/tensorflow-tutorials
RUN wget https://raw.githubusercontent.com/tensorflow/docs/r1.15/site/en/tutorials/keras/basic_classification.ipynb
RUN wget https://raw.githubusercontent.com/tensorflow/docs/r1.15/site/en/tutorials/keras/basic_regression.ipynb
RUN wget https://raw.githubusercontent.com/tensorflow/docs/r1.15/site/en/tutorials/keras/basic_text_classification.ipynb
RUN wget https://raw.githubusercontent.com/tensorflow/docs/r1.15/site/en/tutorials/keras/overfit_and_underfit.ipynb
RUN wget https://raw.githubusercontent.com/tensorflow/docs/r1.15/site/en/tutorials/keras/save_and_restore_models.ipynb
RUN apt-get autoremove -y && apt-get remove -y wget
WORKDIR /tf
EXPOSE 8888

RUN ${PYTHON} -m ipykernel.kernelspec

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
