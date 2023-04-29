## Install helm
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo bash get_helm.sh
## install kubelet
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.19.6/2021-01-05/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
sudo echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
sudo kubectl version --short --client
# Install terraform

date '+%Y-%m-%d %H:%M:%S'
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01-ado-sudo

sudo mkdir -p /var/ansible/cw-misc-jenkins-agents-misc-ans
sudo yum -y install git ansible python3-pip
sudo pip3 install awscli boto3 botocore --upgrade --user
sudo pip3 install awscli boto3 botocore --upgrade --user

ansible-pull site.yml \
    -U https://${github_token}@github.com/Bkoji1150/c2o-web-app-configuration-on-rhel \
    -C feature/aws-enhancement \
    -e hostname="${hostname}" \
    -e server_zr="America/New_York" \
    -d /var/ansible/c2o-web-app-configuration-on-rhel
