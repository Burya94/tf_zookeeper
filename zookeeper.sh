#!/bin/bash
timedatectl set-timezone Europe/Kiev
yum install java-1.8.0-openjdk -y
cd /opt/ && curl -O http://apache.org/dist/zookeeper/current/zookeeper-3.4.10.tar.gz
tar xvzf zookeeper-3.4.10.tar.gz
useradd zookeeper
chown -R zookeeper /opt/zookeeper-3.4.10
ln -s /opt/zookeeper-3.4.10 /opt/zookeeper
chown -h zookeeper /opt/zookeeper
mkdir /var/lib/zookeeper
chown zookeeper. /var/lib/zookeeper
cd /opt/zookeeper/conf
cp zoo_sample.cfg zoo.cfg

cat > /etc/systemd/system/zookeeper.service << EOF
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=forking
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
ExecReload=/opt/zookeeper/bin/zkServer.sh restart
WorkingDirectory=/var/lib/zookeeper

[Install]
WantedBy=multi-user.target
EOF
systemctl start zookeeper
