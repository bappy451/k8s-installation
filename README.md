## Install containerd

```bash
yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io
systemctl enable containerd --now
```

## Install kubeadm, kubelet and kubectl

```bash
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet kubeadm kubectl tc --disableexcludes=kubernetes
systemctl enable kubelet --now
```

## Run this after reboot

```bash
modprobe overlay
modprobe br_netfilter
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a
setenforce 0
```

## Change application data directories

```bash
mkdir -p /data/var/lib/{containerd,etcd,kubelet} /data/var/log/pods
ln -s /data/var/lib/kubelet /var/lib/kubelet
ln -s /data/var/lib/etcd /var/lib/etcd
ln -s /data/var/log/pods /var/log/pods
```

## Configure containerd

```bash
sed -i s+/var/lib/containerd+/data/var/lib/containerd+g /etc/containerd/config.toml
sed -i /disabled_plugins/d /etc/containerd/config.toml
```

## Use proxy with containerd

```bash
mkdir -p /etc/systemd/system/containerd.service.d/
nano /etc/systemd/system/containerd.service.d/proxy.conf
```

Then add the following lines.

```bash
[Service]
Environment="HTTP_PROXY=http://10.0.8.88:8080/"
Environment="HTTPS_PROXY=http://10.0.8.88:8080/"
Environment="NO_PROXY=localhost,127.0.0.0/8,10.0.0.0/8,192.168.0.0/16,.smart.com.kh,.smart.local,.cluster.local"
```

Then run `systemctl daemon-reload` to load systemd override for `containerd`.

## Create Cluster

If all good, then init cluster in master-1.

```bash
kubeadm init --pod-network-cidr 22.252.64.0/18 --service-cidr 22.7.192.0/18 --kubernetes-version v1.27.3
```

In worker nodes, run the join command.

```bash
kubeadm join 10.1.82.27:6443 --token ouely3.dbgchtquoc0688nt --discovery-token-ca-cert-hash sha256:5880b47cb4434830b9c8ef4d8392151401c65432d585142f311d77dd218968b7
```

## Pod/Service CIDR Range

| Network Range | Project Name | Environment | Description |
|-----|---------|---------|---------|
| 22.252.0.0/18 | ECRM | ECRM Production | POD CIDR Block |
| 22.7.128.0/18 | ECRM | ECRM Production | Service CIDR Block |
| 22.252.64.0/18 | ECRM | ECRM Staging | POD CIDR Block |
| 22.7.192.0/18 | ECRM | ECRM Staging | Service CIDR Block |
