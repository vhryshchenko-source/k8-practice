# Building a Python app with Redis using Jenkins on Kubernetes and deploying by Helm

## Description
This tutorial shows you from scratch how to build docker image for a Python app with Redis using Jenkins Distributed (Master-Slave) Build on Kubernetes and deploy into Docker Hub repository. Also it contains steps by deploying Python app with Redis on Kubernetes using Helm.  

## Roadmap
1. Creation kubernetes cluster on virtual machines.
2. Setup Jenkins Distributed (Master-Slave) Build on Kubernetes. 
3. Setup Jenkins Pipeline to build docker image and push this one into DockerHub.
4. Deployment Python app with Redis on Kubernetes.

## REQUIREMENTS

- **VirtualBox**: hypervisor is used to create the Kubernetes cluster, so you must have it installed. More detail about VirtualBox: [https://www.virtualbox.org](https://www.virtualbox.org).
- **Docker Hub account**: Docker Hub is library and community for container images. More detail about Docker Hub: [https://hub.docker.com](https://hub.docker.com/).  
- **GitHub account**: GitHub is a code hosting platform for version control and collaboration. More detail about GitHub:[ https://github.com](https://github.com/).  
- **Vagrant**: tool for building and managing virtual machine environments. More detail about Vagrant: [https://www.vagrantup.com/docs](https://www.vagrantup.com/docs).  

## Running instructions

### 1. Creation kubernetes cluster on virtual machines
 
Vagrant is used for rapid deployment of virtual machines in VirtualBox. So it  must first be installed on the machine. Installing Vagrant is extremely easy. Head over to the Vagrant downloads page and get the appropriate installer or package for your platform. Install the package using standard procedures for your operating system.
After the vagrant has been installed. You can verify its installation by running the binary to show the version:  
    $ `./vagrant version`  
Clone or download this github repository. The configuration file for setup VM`s called _Vagrantfile_.  
This file contains next:
- will be installed box Official Ubuntu 16.04 LTS from [public Vagrant box catalog](https://vagrantcloud.com/boxes/search), 
- configured network bridge with a specific ip address for master VM (you can change ip for your own value), 
- selected Virtualbox provider with specific memory and cpu resources, and ran the shell script. 

This shell script will be installed docker, tools for creation and management kubernetes cluster and helm.
If you change ip address for worker in `master.vm.network`, you also must change `KUBELET_EXTRA_ARGS=--node-ip=<worker-ip-address>` for both VM's.
If you change ip address for master in `master.vm.network`, you also must change `--apiserver-advertise-address=<master-ip-address>` for master Vm.

**1.1 To create and configure Kubernetes cluster run the Vagrant command with the up flag.**    
    $ `vagrant up`    
**1.2 Once the cluster is completed build you can check the status of there system with the status flag.**
    $ `vagrant status`  
**1.3 Join your worker node into the cluster**
- In output of `vagrant up` command you will see something like this:   
`kubeadm join 192.168.1.130:6443 --token qt57zu.wuvqh64un13trr7x --discovery-token-ca-cert-hash sha256:5ad014cad868fdfe9388d5b33796cf40fc1e8c2b3dccaebff0b066a0532e8723`    
- Copy your own output and login into worker node using command:  
 $ `vagrant ssh <woker-node-name>`  
- Switch to root user:  
 $ `sudo su -`  
- Paste command `kubeadm join` that you copied in step 4.1, and you can see in output of this command `This node has joined the cluster`.  
- verify your new worker has successfully joined the cluster:  
 $ `vagrant ssh <master-node-name>`  
 $ `kubectl get nodes`  

### 2. Setup Jenkins Distributed (Master-Slave) Build on Kubernetes

To build the docker image of our python application, in this tutorial used Jenkins CI and his master-slave strategy on kubernetes. 
Login into master node and clone this GitHub repository. 
The configuration file for setup Jenkins are located in _Jenkins setup_ folder, choose this one and follow the instructions below.  

####2.1 Setup Jenkins Deployment
2.1.1 You can deploy Jenkins at any namespace, but for better isolation it is recommended that you create a dedicated namespace.  
$ `kubectl create namespace jenkins`  
2.1.2 Deploy Jenkins using kubectl   
$ `kubectl apply -f jenkins-deployment.yaml`  
To validate that creating the deployment was successful you can invoke:  
$ `kubectl get deployments -n jenkins`  
```
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins-master   1/1     1            1           3d
```
2.1.3 Jenkins needs to access the Kubernetes API, therefore you need to properly setup a Kubernetes Service Account and Role in order to represent Jenkins access for the Kubernetes API.  
$ `kubectl apply -f jenkins-role.yaml`  
2.1.4 To enable access from network to the Jenkins pod you need apply service manifest.  
$ `kubectl apply -f jenkins-service.yaml`  
2.1.5 To verify that the deployment and the service have been created  
$ `kubectl get all -n jenkins`  
To validate that creating the service was successful you can run:  
$ `kubectl get services -n jenkins` 
```
NAME                     TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                          AGE
service/jenkins-master   NodePort   10.105.78.192   <none>        8080:31857/TCP,50000:30400/TCP   3d1h
```
####2.2 Access Jenkins dashboard
Now we can access the Jenkins instance at http://192.168.1.107:31857 (use your port that related to 8080 for get services command).  
To access Jenkins, you initially need to enter your credentials. The default username for new installations is admin. The password can be obtained in several ways. This example uses the Jenkins deployment pod name.
2.2.1 To find the name of the pod, enter the following command:  
$ `kubectl get pods -n jenkins`  
Once you locate the name of the pod, use it to access the pod’s logs.  
$ `kubectl logs <pod_name> -n jenkins`  
The password is at the end of the log formatted as a long alphanumeric string:
```
*************************************************************
*************************************************************
*************************************************************

Jenkins initial setup is required.
An admin user has been created and a password generated.
Please use the following password to proceed to installation:

94b73ef6578c4b4692a157f768b2cfef

This may also be found at:
/var/jenkins_home/secrets/initialAdminPassword

*************************************************************
*************************************************************
*************************************************************
```
You have successfully installed Jenkins on your Kubernetes cluster.

2.2.2. Browse to http://192.168.1.107:31857 (or whichever port you configured for Jenkins when installing it) and wait until the Unlock Jenkins page appears. Then enter your password that you copied from previous step and click **Continue**.  
2.2.3. When the Create First Admin User page appears, specify the details for your administrator user in the respective fields and click **Save** and **Finish**.  

#### 2.3 Configuring Jenkins distributed build

2.3.1 Install required plugin to support distributed build setup:
- Kubernetes;
- Docker;
- Git;
- Node and Label Parameter Plugin.  

To install plugins navigate to **Manage Jenkins** > **Manage Plugins** > **Available**  

2.3.2  Setup Jenkins Cloud Configuration and Slave Pod Specification  

First, you have to register the jenkins-master service account to Jenkins credential manager, navigate to Credentials > Systems > Global Credentials (or you can add your own domain).
Click add credentials and choose kind credential Secret text. In secret field type jenkins-master service account token:  
$`kubectl get secret $(kubectl get sa jenkins-master -n jenkins -o jsonpath={.secrets[0].name}) -n jenkins -o jsonpath={.data.token} | base64 --decode`  

To configure cloud provider navigate to **Manage Jenkins > Manage Nodes and Clouds > Configure Clouds** and choose kubernetes.  
Next, you have to get these values to setup cloud configuration properly:
- Kubernetes API server address:   
$ `kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " "`  
- Kubernetes server CA certificate key:  
$ `kubectl get secret $(kubectl get sa jenkins-master -n jenkins -o jsonpath={.secrets[0].name}) -n jenkins -o jsonpath={.data.'ca\.crt'} | base64 --decode`  
- Kubernetes Namespace: `jenkins`
- Credentials: choose your service account credential
- Jenkins tunnel: <master-node-ip>:<jnl-port> (Example: 192.168.1.107:30400). You can get jnl port from output of command `kubectl get svc -n jenkins`. See what is port related to **50000**.  
- Next: Click **Pod templates** and type **Name**, **Namespace**: jenkins and **Labels**. You have to label the pod as jenkins-slave in order to restrict the build only on slave nodes.  
- In container template type **Name**:docker and **Docker image**: docker  
- Add **Volumes**, choose **Host Path Volume** and type for _Host_ and _Mount path_ `/var/run/docker.sock`.  
- Click Save.

### 3. Setup Jenkins Pipeline to build docker image and push this one into DockerHub.

Now it remains to create Jenkins jobs that will launch the pipeline, which consists of 3 steps: building the image, login to Docker Hub and pushing the image to the Docker Hub.

#### 3.1 Create credentials for GitHub and DockerHub
3.1.1 Navigate to **Credentials > Systems > Global Credentials**. Click add credentials and choose kind credential SSH Username with private key. In ID and Description type github-jenkins (you can use another name), Username type your username on GitHub, in Private Key section choose Enter directly.
Next you will need to [generate ssh keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) or use existing if you already have. Enter you private key in the windows **Key** and [add public key to you GitHub repository](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account), click **OK**.  

3.1.2 Next, add credential for Docker Hub. Click add credentials and choose Username with password. Add your username and password for Docker Hub account, and type ID (docker-hub-credentials). Click **OK**.  

#### 3.2 Create job

3.2.1 Navigate to **New Item**, Enter a job name, choose **Pipeline**, click OK. 

3.2.2 You can add description for your job or skip this step.

3.2.3 Choose _This project is parameterized_ and click Add Parameter. You can choose just String Parameter or Choice Parameter if you want to define possible values. 
For Name of parameter type `AGENT_LABEL` and value type your label from Pod template configuration. Then add one more parameter and type Name `PYTHON_VERSION`. This parameters allows you to choose on what pods will bw used for executing job and version of python for docker image.

3.3.3 Below Pipeline Defenition choose Pipeline script form SCM and choose SCM Git. Enter you GitHub repository url, where stored file from this repository and choose credentials for GitHub that was created in step 3.1.
In Branches to build enter your branch name, for example `*/main`. Ensure that script path is right and click **Save**.
  
#### 3.4 Run job
For launch pipeline you need to choose name of your job, add click build with parameters. Choose or enter values for `AGENT_LABEL` and `PYTHON_VERSION`, then click build. In build history appear information that your job started, and you can see log output by clicking on **console output**.
If everything work correctly you will see `Finished: SUCCESS` at the end of the job. Ensure that image appear in you Docker Hub repository.

### 4. Deployment Python app with Redis on Kubernetes

To deploy Python application with Redis on Kubernetes, we will use Helm. It is package manager
for Kubernetes, more detail about Helm you can find on [https://helm.sh](https://helm.sh/). 
Make sure the helm is installed with the following command:  
$ `helm version`  
Clone this git repository. The helm chart are in folder `helm-chart` with following structure:
```
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── redis.yaml
│   └── service.yaml
└── values.yaml
```
The folder template contains are deployment and service manifests for python app and redis.
The file values.yaml contain variables as image name for app, namespace, and also image, name for redis.
To apply this chart you need to run:  
$ `helm install <release-name> helm-chart/`  
```
NAME: hit-count
LAST DEPLOYED: Mon Nov 15 10:27:25 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
To check what port is expose for app:   
$ `kubectl get service/hit-count -n jenkins`  

And now, application available, you can check it:  
$ `curl localhost:<port>`
```
I have been seen 1 times. My Hostname is: hit-count-689c98c767-fgxnq
```
For delete helm chart use command:  
$ `helm uninstall <release-name>`  

##Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Please make sure to update tests as appropriate.
