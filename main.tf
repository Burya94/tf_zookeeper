data "aws_ami" "centos7" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.3_HVM-20170613-x86_64*"]
  }

  filter {
    name   = "virtualization-type"
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

resource "aws_autoscaling_group" "testscale" {
  availability_zones        = ["us-east-1a"]
  name                      = "terraasg_test"
  launch_configuration      = "${aws_launch_configuration.zookeeper}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = ["${var.subnet_id}"]

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_launch_configuration" "zookeeper" {
  #count                = 3
  key_name      = "${var.key_name}"
  ami           = "ami-a4c7edb2"                            #"${data.aws_ami.centos7.id}"
  instance_type = "${var.instype}"
  user_data     = "${data.template_file.userdata.rendered}"

  #subnet_id            = "${element(var.subnet_id, count.index)}"
  security_groups      = ["${var.sec_group}"]
  iam_instance_profile = "${aws_iam_instance_profile.zoo_profile.name}"
  depends_on           = ["aws_iam_instance_profile.zoo_profile"]

  lifecycle {
    create_before_destroy = "true"
  }
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_tfstate_bucket_name}/*",
      "arn:aws:s3:::${var.s3_tfstate_bucket_name}",
    ]
  }

  statement {
    actions = [
      "kinesis:*",
    ]

    resources = [
      "arn:aws:kinesis:*:${var.account_id}:stream/${var.stream_name}",
    ]
  }
}

resource "aws_iam_policy" "policy_s3_access" {
  name        = "policy_for_s3_access"
  description = "s3_access"
  policy      = "${data.aws_iam_policy_document.s3_access.json}"
}

resource "aws_iam_role" "zookeeper" {
  name = "zookeeper_vms"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  depends_on = ["aws_iam_policy.policy_s3_access"]
}

resource "aws_iam_role_policy_attachment" "zookeeper_attach" {
  role       = "${aws_iam_role.zookeeper.name}"
  policy_arn = "${aws_iam_policy.policy_s3_access.arn}"
  depends_on = ["aws_iam_role.zookeeper"]
}

resource "aws_iam_instance_profile" "zoo_profile" {
  name       = "zookeeper_profile"
  role       = "${aws_iam_role.zookeeper.name}"
  depends_on = ["aws_iam_role_policy_attachment.zookeeper_attach"]
}
