#!/bin/bash
timedatectl set-timezone Europe/Kiev
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum update
yum -y install puppet-agent
cat >> /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
server = ${dns_name}
environment = ${env}
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
echo "export FACTERLIB=/root/" >> /root/.bash_profile
