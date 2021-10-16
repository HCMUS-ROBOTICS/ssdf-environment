FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04
SHELL ["/bin/bash", "-c"]

# Non-root user
ARG USERNAME
RUN apt-get update &&\
    apt-get install -y --no-install-recommends curl git sudo &&\
    useradd --create-home --shell /bin/bash $USERNAME &&\
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&\
    chmod 0440 /etc/sudoers.d/$USERNAME &&\
    rm -rf /var/lib/apt/lists/*

# FFmpeg shared libraries
ARG FFMPEG_VER
ARG VID_CODEC_VER
# ENV PKG_CONFIG_PATH /usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
RUN --mount=target=/tmp/VideoCodec,source=Video_Codec_SDK \
    cp -r /tmp/VideoCodec/Interface/* /usr/local/cuda/include &&\
    cp -r /tmp/VideoCodec/Lib/linux/stubs/x86_64/* /usr/local/cuda/lib64/stubs &&\
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nasm pkg-config libnuma-dev libx264-dev libx265-dev libvpx-dev &&\
    apt-mark manual libx264-155 libx265-179 libvpx6 &&\
    curl -fsSL https://github.com/FFmpeg/nv-codec-headers/releases/latest/download/nv-codec-headers-$VID_CODEC_VER.tar.gz | tar xz &&\
    cd nv-codec-headers-$VID_CODEC_VER && make install &&\
    cd .. && rm -rf nv-codec-headers-$VID_CODEC_VER &&\
    curl -fsSL https://github.com/FFmpeg/FFmpeg/archive/n$FFMPEG_VER.tar.gz | tar xz &&\
    cd FFmpeg-n$FFMPEG_VER &&\
    sed -i "s/arch=compute_30,code=sm_30/arch=compute_61,code=sm_61/g" configure &&\
    ./configure --enable-cuda-nvcc --nvcc=/usr/local/cuda/bin/nvcc \
    --disable-doc --disable-debug --disable-programs --enable-shared \
    --disable-avdevice --disable-swresample --disable-postproc --disable-avfilter \
    --enable-gpl --enable-nonfree --enable-libx264 --enable-libx265 --enable-libvpx &&\
    make --jobs $(nproc) install &&\
    apt-get autoremove -y --purge \
    nasm pkg-config libnuma-dev \
    libx264-dev libx265-dev libvpx-dev &&\
    rm -rf ../FFmpeg-n$FFMPEG_VER /var/lib/apt/lists/*
# ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:$LIBRARY_PATH

# OpenCV - Intel MKL + GTK (HighGUI) + NumPy (Python3)
ARG CMAKE_VER
ARG OPENCV_VER
RUN curl -fsSLO https://github.com/Kitware/CMake/releases/latest/download/cmake-$CMAKE_VER-linux-x86_64.sh &&\
    bash cmake-$CMAKE_VER-linux-x86_64.sh --prefix=/usr/local --skip-license &&\
    rm -rf cmake-$CMAKE_VER-linux-x86_64.sh /usr/local/doc/cmake &&\
    curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB -o /etc/apt/trusted.gpg.d/intel-sw.asc &&\
    echo 'deb https://apt.repos.intel.com/mkl all main' | tee /etc/apt/sources.list.d/intel-mkl.list &&\
    apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    intel-mkl-tbb-rt-2020.4-304 libgtk-3-dev python3 python3-dev python3-pip &&\
    apt-mark manual intel-mkl-core-rt-2020.4-304 libgtk-3-0 &&\
    python3 -m pip install --no-cache-dir --upgrade pip &&\
    python3 -m pip install --no-cache-dir --upgrade numpy setuptools &&\
    curl -fsSL https://github.com/opencv/opencv/archive/$OPENCV_VER.tar.gz | tar xz &&\
    curl -fsSL https://github.com/opencv/opencv_contrib/archive/$OPENCV_VER.tar.gz | tar xz &&\
    source /opt/intel/compilers_and_libraries_2020.4.304/linux/bin/compilervars.sh intel64 &&\
    cmake opencv-$OPENCV_VER -B build -DCMAKE_BUILD_TYPE=Release \
    -DOPENCV_EXTRA_MODULES_PATH=opencv_contrib-$OPENCV_VER/modules \
    -DBUILD_LIST=cudaarithm,cudafilters,cudaimgproc,cudev,imgproc,imgcodecs,highgui,python3,videoio \
    -DWITH_CUDA=ON -DWITH_CUDNN=ON -DCUDA_ARCH_BIN="6.0;6.1;7.0;7.5;8.0;8.6" \
    -DCPU_BASELINE=AVX2 -DOPENCV_ENABLE_NONFREE=ON -DWITH_ADE=OFF -DWITH_PROTOBUF=OFF \
    -DWITH_OPENEXR=OFF -DWITH_IMGCODEC_SUNRASTER=OFF -DWITH_IMGCODEC_PXM=OFF -DWITH_IMGCODEC_PFM=OFF &&\
    make --directory build --jobs $(nproc) install &&\
    apt-get autoremove -y --purge \
    intel-mkl-tbb-rt-2020.4-304 libgtk-3-dev python3-dev &&\
    echo 'source /opt/intel/compilers_and_libraries_2020.4.304/linux/bin/compilervars.sh intel64' >> /home/$USERNAME/.bashrc &&\
    rm -rf build opencv-$OPENCV_VER opencv_contrib-$OPENCV_VER /var/lib/apt/lists/*

# TensorRT
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    libnvinfer-dev libnvinfer-plugin-dev libnvonnxparsers-dev &&\
    apt-mark hold \
    libnvinfer8 libnvinfer-dev libnvinfer-plugin8 libnvinfer-plugin-dev \
    libnvonnxparsers8 libnvonnxparsers-dev &&\
    rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
# ROS core + catkin_tools + CMake deprecated warning workaround
RUN echo 'deb http://packages.ros.org/ros/ubuntu focal main' | tee /etc/apt/sources.list.d/ros-latest.list &&\
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -o /etc/apt/trusted.gpg.d/ros.asc &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends ros-noetic-ros-base &&\
    echo 'source /opt/ros/noetic/setup.bash' >> /home/$USERNAME/.bashrc &&\
    python3 -m pip install --no-cache-dir --upgrade catkin_tools &&\
    grep -rl cmake_minimum_required /usr/src/googletest |\
    xargs sed -i "s/cmake_minimum_required([^)]*)/cmake_minimum_required(VERSION 3.18)/g" &&\
    rm -rf /var/lib/apt/lists/*

# ROS image packages
ARG VISION_CV_VER
ARG IMG_TRANSPORT_PLUGIN_VER
RUN apt-get update &&\
    apt-get install -y --no-install-recommends ros-noetic-image-transport &&\
    source /opt/ros/noetic/setup.bash &&\
    mkdir -p /opt/ros/no_version/src && cd /opt/ros/no_version &&\
    curl -fsSL https://github.com/ros-perception/vision_opencv/archive/$VISION_CV_VER.tar.gz |\
    tar xzC src --strip-components 1 vision_opencv-$VISION_CV_VER/cv_bridge &&\
    curl -fsSL https://github.com/ros-perception/image_transport_plugins/archive/$IMG_TRANSPORT_PLUGIN_VER.tar.gz |\
    tar xzC src --strip-components 1 image_transport_plugins-$IMG_TRANSPORT_PLUGIN_VER/compressed_image_transport &&\
    catkin config --init --install --link-devel && catkin build &&\
    echo 'source /opt/ros/no_version/install/setup.bash --extend' >> /home/$USERNAME/.bashrc &&\
    apt-mark manual libogg0 libtheora0 &&\
    apt autoremove -y --purge libogg-dev libtheora-dev &&\
    rm -rf devel logs src /var/lib/apt/lists/*

# Libraries for SSDF
ARG FMT_VER
ARG HALF_VER
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    netbase ros-noetic-rosbridge-server &&\
    python3 -m pip install --no-cache-dir --upgrade python-socketio &&\
    curl -fsSL https://github.com/fmtlib/fmt/archive/$FMT_VER.tar.gz | tar xz &&\
    cmake fmt-$FMT_VER -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON &&\
    make --directory build --jobs $(nproc) install &&\
    curl -fsSL https://sourceforge.net/p/half/code/HEAD/tree/tags/release-$HALF_VER/include/half.hpp?format=raw \
    -o /usr/local/include/half.hpp &&\
    rm -rf build fmt-$FMT_VER /var/lib/apt/lists/*
