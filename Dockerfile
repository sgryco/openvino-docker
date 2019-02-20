#$ tar -xf l_openvino_toolkit*
#Build docker
#$ docker build -t openvino .
#Run docker
#$ docker run -ti openvino /bin/bash

FROM ubuntu:16.04

# Pick up some dependencies for OpenVino and NCS/NCS2
RUN apt-get update && apt-get upgrade -y &&\
    apt-get autoremove -y &&\
    apt-get install -y --no-install-recommends \
      build-essential \
      cpio \
      curl \
      git \
      lsb-release \
      pciutils \
      python3.5 \
      python3-pip \
      sudo \
      libusb-1.0-0 libboost-program-options1.58.0 \
      libboost-thread1.58.0 libboost-filesystem1.58.0 \
      libssl1.0.0 libudev1 libjson-c2 usbutils udev wget \
      && \
      rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG OV_LINK=http://registrationcenter-download.intel.com/akdlm/irc_nas/15078/l_openvino_toolkit_p_2018.5.455.tgz

# installing OpenVINO
RUN unset no_proxy && unset NO_PROXY &&\
    curl $OV_LINK\
    --output l_openvino_toolkit.tgz &&\
    tar xf l_openvino_toolkit.tgz &&\
    rm l_openvino_toolkit.tgz && \
    cd l_openvino_toolkit* && \
    ./install_cv_sdk_dependencies.sh &&\
    sed -i 's/decline/accept/g' silent.cfg && \
    ./install.sh --silent silent.cfg && \
    rm -r /app/l_openvino_toolkit*

ARG INSTALL_DIR=/opt/intel/computer_vision_sdk
RUN echo "source $INSTALL_DIR/bin/setupvars.sh" >> ~/.bashrc

# setup optimisers
RUN python3.5 -m pip install setuptools -U pip
RUN cd /opt/intel/computer_vision_sdk/deployment_tools/model_optimizer/install_prerequisites && \
    ./install_prerequisites.sh caffe && \
    ./install_prerequisites_onnx.sh &&\
    ./install_prerequisites_caffe.sh &&\
    ./install_prerequisites_tf.sh

RUN pip3 install pyyaml requests

RUN apt-get update && apt-get -y install python3-dev &&\
    rm -rf /var/lib/apt/lists/*


#RUN apt-get update && apt-get install -y --no-install-recommends \
      #libpng12-dev \
      #cmake libcairo2-dev libpango1.0-dev libglib2.0-dev libgtk2.0-dev\
       #libswscale-dev libavcodec-dev libavformat-dev libgstreamer1.0-0 \
       #gstreamer1.0-plugins-base\
       #build-essential python3-pip\
      #&& \
      #rm -rf /var/lib/apt/lists/*

# ENTRYPOINT /opt/intel/computer_vision_sdk/deployment_tools/demo/demo_squeezenet_download_convert_run.sh
