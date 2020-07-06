#!/bin/bash

sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o key 
sudo apt-key add key
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo mkdir -p /etc/docker
sudo echo '{"exec-opts": ["native.cgroupdriver=systemd"],"log-driver": "json-file","log-opts": {"max-size": "100m"},"storage-driver": "overlay2"}' > ~/daemon.json
sudo mv ~/daemon.json /etc/docker
sudo systemctl enable docker
sudo systemctl restart docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o key2
sudo apt-key add key2
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 > init_result

CMD1=$(cat init_result | grep 'kubeadm join')
CMD1=$(echo "${CMD1%?}")
CMD2=$(cat init_result | grep discovery-token-ca-cert-hash)
echo "#!/bin/bash" > join_script.sh
echo "sudo ${CMD1}${CMD2}" >> join_script.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml