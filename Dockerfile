FROM osrf/ros:humble-desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV QT_X11_NO_MITSHM=1

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    ca-certificates \
    xauth \
    python3-pip \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-osrf-pycommon \
    gazebo \
    libgazebo-dev \
    libgtest-dev \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-plugins \
    ros-humble-joint-state-publisher \
    ros-humble-robot-state-publisher \
    ros-humble-xacro \
    ros-humble-tf2-ros \
    ros-humble-rviz2 \
    ros-humble-slam-toolbox \
 && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true
RUN rosdep update

WORKDIR /root/ros2_ws
RUN mkdir -p /root/ros2_ws/src

COPY src/fastbot /root/ros2_ws/src/fastbot
COPY src/fastbot_unit_tests/fastbot_waypoint_msgs /root/ros2_ws/src/fastbot_waypoint_msgs
COPY src/fastbot_unit_tests/fastbot_waypoints /root/ros2_ws/src/fastbot_waypoints

RUN source /opt/ros/humble/setup.bash && \
    cd /root/ros2_ws && \
    rosdep install --from-paths src --ignore-src -r -y --rosdistro humble

RUN source /opt/ros/humble/setup.bash && \
    cd /root/ros2_ws && \
    colcon build --symlink-install

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc

RUN echo '#!/bin/bash' > /ros_entrypoint.sh && \
    echo 'set -e' >> /ros_entrypoint.sh && \
    echo 'source /opt/ros/humble/setup.bash' >> /ros_entrypoint.sh && \
    echo 'if [ -f /root/ros2_ws/install/setup.bash ]; then source /root/ros2_ws/install/setup.bash; fi' >> /ros_entrypoint.sh && \
    echo 'exec "$@"' >> /ros_entrypoint.sh && \
    chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]