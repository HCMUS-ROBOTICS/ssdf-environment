FROM kerry347/ssdf:core-devel

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    ros-noetic-rqt-console \
    ros-noetic-rqt-launch \
    ros-noetic-rqt-msg \
    ros-noetic-rqt-reconfigure \
    ros-noetic-rqt-topic \
    ros-noetic-rviz &&\
    rm -rf /var/lib/apt/lists/*