#!/bin/bash
# Installing JAVA && Jenkins 
sudo yum install java-1.8* -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install epel-release java-11-openjdk-devel
sudo amazon-linux-extras install epel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install jenkins -y
sudo dnf upgrade
sudo dnf install chkconfig java-devel
sudo dnf install jenkins
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot
sudo systemctl enable jenkins
sudo yum install git -y
sudo yum install python
sudo yum install python-pip
pip3 install ansible
# Installing Docker 
yum install docker -y
service docker start
service docker status
sudo useradd dockeradmin
# sudo passwd dockeradmin TODO LIST
sudo usermod -aG docker dockeradmin
sudo chmod 666 /var/run/docker.sock
# install Sonarqube scanner
mkdir sonnar-canna
cd sonnar-canna
sudo unzip sonar-scanner-cli-4.6.2.2472-linux.zip
sudo mv sonar-scanner-4.6.2.2472-linux  sonar-scanner-cli
sudo mv sonar-scanner-cli /opt/sonar/
# cd into /opt/sonar/conf and add format("http://%s:%s", aws_instance.SonarQubesinstance.public_ip, var.sonar_port)
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
# Installing maven
sudo su
mkdir /opt/maven
cd /opt/maven
wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
tar -xvzf apache-maven-3.8.4-bin.tar.gz
# echo  "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.M2_HOME=/opt/maven/apache-maven-3.8.4 M2=$M2_HOME/bin PATH=$PATH:$HOME/bin:$M2_HOME:$M2:$JAVA_HOME" > file10.1.x86_64  
cat >> ~/.bash_profile 
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64
M2_HOME=/opt/maven/apache-maven-3.8.4
M2=$M2_HOME/bin
PATH=$PATH:$HOME/bin:$M2_HOME:$M2:$JAVA_HOME 
sudo useradd ansible
sudo useradd jenkins
sudo -u jenkins mkdir /home/jenkins.ssh
# install groovy 
sudo mkdir /usr/share/groovy
sudo wget wget https://archive.apache.org/dist/groovy/4.0.0-rc-1/distribution/apache-groovy-binary-4.0.0-rc-1.zip
unzip apache-groovy-binary-4.0.0-rc-1.zip
yum install groovy -y
# sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
sudo mkdir -p /var/ansible/cw-misc-jenkins-agents-misc-ans
sudo yum -y install git ansible python3-pip
sudo pip3 install awscli boto3 botocore --upgrade --user
sudo pip3 install awscli boto3 botocore --upgrade --user
#export PATH=/usr/local/bin:$PATH
# install taraform 
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
aws ssm get-parameters \
    --output=text \
    --region us-east-1 \
    --with-decryption \
    --names jenkins-agent-bootstrap-ssh-key \
    --query "Parameters[*].{Value:Value}[0].Value" > /var/ansible/private-key
chmod 0600 /var/ansible/private-key
eval "$(ssh-agent -s)"
ssh-add /var/ansible/private-key
export ANSIBLE_CONFIG=/var/ansible/ansible.cfg
export ANSIBLE_LOG_PATH=/var/ansible/bootstrap.log
echo -e "[default]\nlog_path=/var/ansible/bootstrap.log" > /var/ansible/ansible.cfg
ansible-pull site.yml \
    --accept-host-key \
    -U git@github.com:Bkoji1150/cw-misc-jenkins-agents-misc-ans.git \
    -C "tags/v0.6.0" \
    -e cwa_config_param=${cwa_config_param} \
    -d /var/ansible/cw-misc-jenkins-agents-misc-ans
