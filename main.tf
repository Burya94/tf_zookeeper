data "aws_ami" "centos7"{
  most_recent = true

  filter {
    name  = "name"
    values = ["RHEL-7.3_HVM-20170613-x86_64*"]
  }

  filter {
    name  = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/${var.path_to_file}")}"

  vars {
    dns_name    = "${var.puppetmaster_dns}"
    environment = "${var.environment}"
    puppet_ip   = "${var.puppet_ip}"
  }
}

resource "aws_instance" "zookeeper" {
  count                       = 1
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instype}"
  user_data                   = "${data.template_file.userdata.rendered}"
  subnet_id                   = "${element(var.subnet_id, count.index)}"
  security_groups             = ["${var.sec_group}"]

  tags {
    Name = "Zookeeper Instance"
  }
}
