#!/bin/bash
yum update -y
yum -y install bind bind-utils

#By defaulf, BIND listens on localhost. So, we will configure DNS server to listen on system IP address 
#to let clients can reach to DNS server for resolving domain names.

vi /etc/named.conf
