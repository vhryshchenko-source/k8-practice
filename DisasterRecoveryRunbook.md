### Runbook

1. To create and configure Kubernetes cluster:  
    $ `vagrant up`  
2. Join your worker node into the cluster:   
- In output of `vagrant up` command you will see something like this:     
$ `kubeadm join 192.168.1.130:6443 --token qt57zu.wuvqh64un13trr7x --discovery-token-ca-cert-hash sha256:5ad014cad868fdfe9388d5b33796cf40fc1e8c2b3dccaebff0b066a0532e8723`    
- Copy your own output and login into worker node using command:  
 $ `vagrant ssh <woker-node-name>`  
- Switch to root user:  
 $ `sudo su -`  
- Paste command `kubeadm join` that you copied in step 4.1, and you can see in output of this command   
`This node has joined the cluster`.  
- verify your new worker has successfully joined the cluster:  
 $ `vagrant ssh <master-node-name>`  
 $ `kubectl get nodes` 
3. Create Jenkins namespace:  
    $ `kubectl create namespace <namespace_name>` 
4. To deploy app you need edit values.yaml in folder `helm-chart/` by choosing you namespace name and then run:  
$ `helm install <release-name> helm-chart/`
    You will see:
```
NAME: hit-count
LAST DEPLOYED: Mon Nov 15 10:27:25 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```