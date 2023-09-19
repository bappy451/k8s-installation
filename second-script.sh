#! /bin/bash

modprobe overlay
modprobe br_netfilter
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a
setenforce 0
mkdir -p /data/var/lib/{containerd,etcd,kubelet} /data/var/log/pods
ln -s /data/var/lib/kubelet /var/lib/kubelet
ln -s /data/var/lib/etcd /var/lib/etcd
ln -s /data/var/log/pods /var/log/pods
sed -i s+/var/lib/containerd+/data/var/lib/containerd+g /etc/containerd/config.toml
sed -i /disabled_plugins/d /etc/containerd/config.toml
mkdir -p /etc/systemd/system/containerd.service.d/
