# SSDF Environment

This repository contains environment files for SSDF. The official supported code editor is [Visual Studio Code](https://code.visualstudio.com/).

## Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html)
- [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Image

Docker images are available on [Docker Hub](https://hub.docker.com/r/kerry347/ssdf). All images run as non-root user **ssdf** with UID and GID **1000**. The default ROS build tool is [Colcon](https://colcon.readthedocs.io/en/released/user/quick-start.html). Support tags:

- `core-devel`: basic development environment

### Usage

1. The workspace should have the following structure

    ```lang-default
    ├ x11-docker.bash
    ├ workspace
    └── src
    ```

2. Run `./x11-docker.bash <image>`. The script `x11-docker.bash` will create a GPU accelerated container with X11 forwarding so that the GUI application can operate, as well as publish simulators' ports to the host. It also generates and mounts a folder named `.vscoder-server` to the container to prevent the deletion of VSCode's extensions after exit

3. In VSCode, launch the Command Palette (`F1`) then select **Remote-Containers: Attach to Running Container...**
