## This repository provides a detailed guide to create a volume driver for Kubernetes based on FlexVolume.

### Pre-requisites:

* Latest Vagrant installed. 

* Kubernetes Cluster up and running.

If Kubernetes cluster is not setup, please follow this guide: https://github.com/openebs/openebs/tree/master/k8s-demo

### Steps to setup this driver on kubernetes cluster

* Get the files in this repository, either through command line(git clone <repository_url.git>) or download these files.

* vagrant ssh into kubemaster-01 and kubeminion-01(Kubernetes master and node VM's).

* Create a directory where flexvolume looks for the volume drivers, on both kubemaster and kubeminion.

```
sudo mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/cb~temp

```

* Install a vagrant plugin that helps to perform file transfer operations between host and vagrant VM.

```
vagrant plugin install vagrant-scp

```
* On host machine, change directory to the path where the repository is placed and perform the following operation to transfer the files to the nodes.

```
vagrant scp mount.yaml kubemaster-01:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/cb~temp/mount.yaml
vagrant scp temp kubemaster-01:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/cb~temp/
```

  Perform similar operation on other Kubernetes nodes.

* On kubemaster VM, change directory to the driver path, and make the driver executable.

```
cd /usr/libexec/kubernetes/kubelet-plugins/volume/exec/cb~temp/
sudo chmod +x temp
```

* Restart kubelet(On Kubernetes Nodes). Ensure they are running.

```
sudo systemctl restart kubelet
sudo systemctl status kubelet
```

* Create a pod that uses this volume driver. You can modify the mount point and volume source in mount.yaml file.

```
kubectl create -f mount.yaml
```

This creates a pod with nginx web server and a mount point specified in yaml file.

*  To perform driver operations manually: 

```
sudo chmod +x temp.sh

Usage:

./temp.sh init
./temp.sh attach <json params>
./temp.sh detach <mount device>
./temp.sh mount <json params>
./temp.sh unmount <mount dir>

```

* To verify that volume creation was successful.

Find out the kubernetes node on which the pod was deployed, by using following command:
```
kubectl describe pod nginx
```

On that node:
```
ls /tmp
```

Volume "temp" should be present, which proves that volume creation was successful.

* #### To verify whether volume mount was successful on the pod:

Get container ID of nginx container
```
sudo docker ps
```
Run the docker container
```
sudo docker exec -it <container_id> /bin/bash
```
Inside the container:
```
ls /mnt
```
Volume "temp" should be present, which proves that volume mount was successful.
