# Docker environment for SSDF

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html)

## Image

Docker images are available on [Docker Hub](https://hub.docker.com/r/kerry347/ssdf). All images run as non-root user **ssdf** with UID and GID **1000**. The default ROS build tool is [catkin_tools](https://catkin-tools.readthedocs.io/en/latest/installing.html). Please check **dockerfiles/README** for building information. Support tags:

- `core-devel`: basic development environment
- `gui-devel`: `core-devel` and rviz, rqt

## Usage

### With VSCode

1. Install [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Copy expected environment folder to workspace directory and rename it to `.devcontainer`
3. Open workspace folder in VSCode, launch the Command Palette (`F1`) then select **Remote-Containers: Reopen in Container**
4. We can start developing after VSCode finishes building. If there is a configuration change, either choose **Remote-Containers: Rebuild and Reopen in Container** from the host, or **Remote-Containers: Rebuild Container** in the container environment.

### Without VSCode

1. The workspace should have the following structure. Note that Docker will create `workspace` with root ownership when the folder is not existed. In this case, from the host, use `sudo chown -R 1000:1000 workspace` to fix permission issue

    ```lang-default
    ├ workspace
    ├── src
    └ x11-docker.bash
    ```

2. Run `./x11-docker.bash <image>`. The script `x11-docker.bash` will create a GPU accelerated container with X11 forwarding so that the GUI application can operate, as well as publish simulators' ports to the host.
