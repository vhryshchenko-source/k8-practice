
Vagrant.configure("2") do |config|
   config.vm.define "master-kube" do |master|
      master.vm.box = "ubuntu/xenial64"
      master.vm.box_check_update = false
      master.vm.hostname = "master-kube"

      master.vm.network "public_network", ip: "192.168.1.107"

      master.vm.provider "virtualbox" do |vb|
         vb.name = "master-kube"
         vb.memory = 6096
         vb.cpus = 2
      end
      
      master.vm.provision "shell", 
      inline: <<-SHELL
         apt-get update
         #export DEBIAN_FRONTEND=noninteractive
         apt-get install -y apt-transport-https curl
         apt-get install -y docker.io
         curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
         apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
         apt-get update
         apt-get install -y kubelet kubeadm kubectl
         sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=cgroupfs"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
         echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.1.108"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
         kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.1.107
         #export KUBECONFIG=/etc/kubernetes/admin.conf
         mkdir /home/vagrant/.kube
         cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
         chown -R vagrant:vagrant /home/vagrant/.kube
         su - vagrant -c "kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml"
         su - vagrant -c "kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml"
         curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
         apt-get install apt-transport-https --yes
         echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
         apt-get update
         apt-get install helm
      SHELL
   end

   config.vm.define "worker-kube" do |worker|
      worker.vm.box = "ubuntu/xenial64"
      worker.vm.box_check_update = false
      worker.vm.hostname = "worker-kube"

      worker.vm.network "public_network", ip: "192.168.1.108"

      worker.vm.provider "virtualbox" do |vb|
         vb.name = "worker-kube"
         vb.memory = 4096
         vb.cpus = 2
      end
      
      worker.vm.provision "shell", 
      inline: <<-SHELL
         apt-get update
         #export DEBIAN_FRONTEND=noninteractive
         apt-get install -y apt-transport-https curl
         apt-get install -y docker.io
         curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
         apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
         apt-get update
         apt-get install -y kubelet kubeadm kubectl
         sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=cgroupfs"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
         echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.1.108"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
      SHELL
   end
end
