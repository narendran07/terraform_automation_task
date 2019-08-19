#!/bin/bash
clear
echo -e "*****************************JENKINS INSTALLATION********************************\n\n"
sleep 1
sudo yum install java-1.8.0-openjdk.x86_64 wget curl -y
sudo cp /etc/profile /etc/profile_backup
echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
source /etc/profile
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins.service
sudo systemctl enable jenkins.service
curl --silent http://169.254.169.254/latest/meta-data/public-ipv4 > ip.txt
clear
echo -e "\n"
echo "Use this address in your browser to launch jenkins http://`cat ip.txt`:8000"
sleep 1
echo -e "\n"
echo "Use this key to generate initial root password: `cat /var/lib/jenkins/secrets/initialAdminPassword`"
echo -e "\n"
rm -rf ip.txt
echo -e "*****************************JENKINS SUCCESSFULLY INSTALLED********************************"
clear
echo -e "\n*****************************DOCKER INSTALLATION*******************************************\n"
sleep 1
echo -e "\n"
sudo yum install yum-utils device-mapper-persistent-data lvm2 -y
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
curl -L "https://github.com/docker/machine/releases/download/v0.16.1/docker-machine-`uname -s`-`uname -m`" -o /usr/local/bin/docker-machine
sudo chmod +x /usr/bin/docker-machine
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0-rc2/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo systemctl restart docker
clear
echo -e "\n*****************************DOCKER SUCCESSFULLY INSTALLED**********************************\n"
sleep 1

echo -e "\n*****************************INSTALLATION COMPLETED**********************************"\n


