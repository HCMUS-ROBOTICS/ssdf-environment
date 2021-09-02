FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
SHELL ["/bin/bash", "-c"]

# TensorRT
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    curl \
    libnvinfer-dev libnvinfer-plugin-dev &&\
    apt-mark hold libnvinfer8 libnvinfer-plugin8 libnvinfer-dev libnvinfer-plugin-dev &&\
    rm -rf /var/lib/apt/lists/*

# OpenCV - Intel MKL + GTK (HighGUI) + NumPy (Python3)
ARG OPENCV_VER
RUN curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB -o /etc/apt/trusted.gpg.d/intel-sw.asc &&\
    echo 'deb https://apt.repos.intel.com/mkl all main' | tee /etc/apt/sources.list.d/intel-mkl.list &&\
    curl -fsSL https://apt.kitware.com/keys/kitware-archive-latest.asc -o /etc/apt/trusted.gpg.d/kitware.asc &&\
    echo 'deb https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list &&\
    apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cmake \
    intel-mkl-tbb-rt-2020.4-304 \
    libgtk-3-dev \
    python3 python3-dev python3-pip &&\
    python3 -m pip install --no-cache-dir --upgrade pip &&\
    python3 -m pip install --no-cache-dir --upgrade numpy setuptools &&\
    curl -fsSL https://github.com/opencv/opencv/archive/$OPENCV_VER.tar.gz | tar xz &&\
    curl -fsSL https://github.com/opencv/opencv_contrib/archive/$OPENCV_VER.tar.gz | tar xz &&\
    source /opt/intel/compilers_and_libraries_2020.4.304/linux/bin/compilervars.sh intel64 &&\
    mkdir build && cd build &&\
    cmake ../opencv-$OPENCV_VER -DCMAKE_BUILD_TYPE=Release \
    -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-$OPENCV_VER/modules \
    -DBUILD_LIST=cudaarithm,cudafilters,cudaimgproc,cudev,imgproc,imgcodecs,highgui,python3 \
    -DWITH_CUDA=ON -DWITH_CUDNN=ON -DCUDA_ARCH_BIN="6.0;6.1;7.0;7.5;8.0;8.6" \
    -DCPU_BASELINE=AVX2 -DOPENCV_ENABLE_NONFREE=ON -DWITH_ADE=OFF -DWITH_PROTOBUF=OFF \
    -DWITH_OPENEXR=OFF -DWITH_IMGCODEC_SUNRASTER=OFF -DWITH_IMGCODEC_PXM=OFF -DWITH_IMGCODEC_PFM=OFF &&\
    make -j$(nproc) install &&\
    apt-get autoremove -y --purge \
    intel-mkl-tbb-rt-2020.4-304 \
    libgtk-3-dev \
    python3-dev &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    intel-mkl-core-rt-2020.4-304 \
    libgtk-3-0 &&\
    rm -rf ../build ../opencv* /var/lib/apt/lists/*

# Non-root user
ARG USERNAME
RUN apt-get update &&\
    apt-get install -y --no-install-recommends git sudo &&\
    useradd --create-home --shell /bin/bash $USERNAME &&\
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&\
    chmod 0440 /etc/sudoers.d/$USERNAME &&\
    rm -rf /var/lib/apt/lists/*

# ROS core + catkin_tools + CMake deprecated warning workaround
RUN echo 'deb http://packages.ros.org/ros/ubuntu focal main' | tee /etc/apt/sources.list.d/ros-latest.list &&\
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -o /etc/apt/trusted.gpg.d/ros.asc &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends ros-noetic-ros-core &&\
    python3 -m pip install --no-cache-dir --upgrade catkin_tools &&\
    grep -rl cmake_minimum_required /usr/src/googletest |\
    xargs sed -i "s/cmake_minimum_required([^)]*)/cmake_minimum_required(VERSION 3.18)/g" &&\
    rm -rf /var/lib/apt/lists/*

# ROS packages
RUN apt-get update &&\
    apt-get install -y --no-install-recommends netbase ros-noetic-rosbridge-server &&\
    python3 -m pip install --no-cache-dir --upgrade eventlet python-socketio==4.* &&\
    rm -rf /var/lib/apt/lists/*

# Formatter + linter
RUN python3 -m pip install --no-cache-dir --upgrade \
    add-trailing-comma autopep8 cmake-format isort \
    flake8 flake8-bugbear flake8-builtins flake8-comprehensions flake8-isort flake8-docstrings pep8-naming

USER $USERNAME
RUN echo 'source /opt/ros/noetic/setup.bash' >> ~/.bashrc &&\
    echo 'source /opt/intel/compilers_and_libraries_2020.4.304/linux/bin/compilervars.sh intel64' >> ~/.bashrc
WORKDIR /home/$USERNAME