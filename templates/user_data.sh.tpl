#!/bin/bash

set -x
exec > > (tee /var/log/user-data.log|logger -t user-data) 2>&1

echo BEGIN

date '+%Y-%m-%d %H:%M:%S'
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01-ado-sudo

sudo mkdir -p /var/ansible/cw-misc-jenkins-agents-misc-ans
sudo yum -y install git ansible python3-pip
sudo pip3 install awscli boto3 botocore --upgrade --user
sudo pip3 install awscli boto3 botocore --upgrade --user

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
    -U https://github.com/Bkoji1150/cw-misc-jenkins-agents-misc-ans.git \
    -C ${ansible_version} \
    -e cwa_config_param=${cwa_config_param} \
    -d /var/ansible/cw-misc-jenkins-agents-misc-ans
