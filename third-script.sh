#! /bin/bash

modprobe overlay
modprobe br_netfilter
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a
