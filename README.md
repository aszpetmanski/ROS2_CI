# ROS2 CI - Jenkins

## Prerequisite

Docker must be installed before starting Jenkins.

Required version:
```bash
containerd.io=1.7.23-1
```
If Docker is not installed, use the following steps:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

sudo apt-get update
sudo apt-get install -y --allow-downgrades containerd.io=1.7.23-1
sudo apt-mark hold containerd.io

sudo systemctl restart containerd
sudo systemctl restart docker
```

## Start Jenkins

### Open a terminal in the repository:

```bash
cd ~/simulation_ws/src/ros1_ci
chmod +x start_jenkins.sh
./start_jenkins.sh
```
### Open Jenkins webpage

After Jenkins starts, the webpage address is saved in:
```bash
~/jenkins__pid__url.txt
```
Print it with:
```
cat ~/jenkins__pid__url.txt
```
Open the Jenkins URL shown in that file.

## Login

### Use these credentials:
```
Username: desire_test

Password: test
```
## Observe the pipeline

After a Pull Request is accepted (merged), Jenkins should automatically start the configured job for this repository.

### In the Jenkins webpage:

- Open the job for ros2_ci
- Open the latest build
- Click Console Output

There you should be able to see:

- the Docker image being built
- the ROS2 FastBot Gazebo simulation being launched
- the Waypoints tests being executed
- the build finishing successfully