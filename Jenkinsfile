pipeline {
    agent any

    stages {
        stage('Build Docker image') {
            steps {
                sh '''
                    cd ~/ros2_ws
                    sudo docker build -f src/ros2_ci/Dockerfile -t fastbot-gtests .
                '''
            }
        }

        stage('Run Gazebo + test') {
            steps {
                sh 'sudo docker rm -f fastbot_test || true'

                sh '''
                    sudo docker run -d --name fastbot_test \
                      -e DISPLAY=$DISPLAY \
                      -e QT_X11_NO_MITSHM=1 \
                      -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
                      fastbot-gtests \
                      bash -lc '
                        source /opt/ros/humble/setup.bash
                        cd /root/ros2_ws
                        source install/setup.bash
                        ros2 launch fastbot_gazebo one_fastbot_room.launch.py
                      '
                '''

                sh 'sleep 30'

                sh '''
                    sudo docker exec -d fastbot_test bash -lc '
                        source /opt/ros/humble/setup.bash
                        cd /root/ros2_ws
                        source install/setup.bash
                        ros2 run fastbot_waypoints fastbot_action_server
                    '
                '''

                sh 'sleep 10'

                sh '''
                    sudo docker exec fastbot_test bash -lc '
                        source /opt/ros/humble/setup.bash
                        cd /root/ros2_ws
                        source install/setup.bash
                        colcon test --packages-select fastbot_waypoints --event-handlers console_direct+
                        colcon test-result --all
                    '
                '''
            }

            post {
                always {
                    sh 'sudo docker stop fastbot_test || true'
                    sh 'sudo docker rm -f fastbot_test || true'
                }
            }
        }

        stage('Done') {
            steps {
                echo 'Pipeline completed'
            }
        }
    }
}