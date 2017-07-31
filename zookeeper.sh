#!/bin/bash
timedatectl set-timezone Europe/Kiev
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum update
yum -y install puppet-agent
yum -y install wget
cd /opt && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz"
cd /opt && tar xzvf jdk-8u141-linux-x64.tar.gz
cat >> /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
server = ${dns_name}
environment = ${environment}
EOF
cat >> /etc/hosts << EOF
${puppet_ip} ${dns_name}
EOF
service puppet start
#add  role
cat >> /root/role.rb << EOF
Facter.add(:role) do
  setcode do
    'zookeeper'
  end
end
EOF
cat >> /root/.bash_profile << EOF
export FACTERLIB=/root/
export JAVA_HOME=/opt/jdk1.8.0_141
export PATH=$PATH:$JAVA_HOME/bin
EOF
