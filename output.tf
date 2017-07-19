output "private_dns" {
  value = "${aws_instance.zookeeper.private_dns}"
}
output "private_ip" {
  value = "${aws_instance.zookeeper.private_ip}"
}
