
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.docker-vpc.id}"
}

resource "aws_vpc" "docker-vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "docker-subnet" {
    vpc_id = "${aws_vpc.docker-vpc.id}"
    cidr_block = "10.0.1.0/16"
}

resource "aws_security_group" "allow_all" {
	description = "All traffic."
    name = "allow_all"
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ssh_whitelisted" {
	vpc_id = "${aws_vpc.docker-vpc.id}"
	description = "SSH from whitelisted IPs"
    name = "ssh-whitelisted"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["178.250.114.154/32"]
    }
}

resource "aws_instance" "docker" {
	count = 2
	key_name = "aws-luis-instance"
    ami = "${var.ami}"
    subnet_id = "${aws_subnet.docker-subnet.id}"
    security_groups = ["${aws_security_group.ssh_whitelisted.id}"]
    instance_type = "t1.micro"

	# # Copies the file as the root user using a password
	# provisioner "file" {
	#     source = "conf/myapp.conf"
	#     destination = "/etc/myapp.conf"
	#     connection {
	#         user = "root"
	#         password = "${var.root_password}"
	#     }
	# }
    # provisioner "local-exec" {
    #     command = "cat ${aws_instance.docker.private_ip} >> private_ips.txt"
    # }
    # provisioner "remote-exec" {
    #     inline = [
    #     "docker version",
    #     "echo ${aws_instance.docker.private_ip}",
    #     ]
    # }
}

resource "aws_eip" "ip" {
    vpc = true
    instance = "${aws_instance.docker.0.id}"
}





output "id" {
    value = "${aws_instance.docker.*.id}"
}
output "public_dns" {
    value = "${aws_instance.docker.*.public_dns}"
}
output "public_ip" {
    value = "${aws_instance.docker.*.public_ip}"
}
output "private_dns" {
    value = "${aws_instance.docker.*.private_dns}"
}
output "private_ip" {
    value = "${aws_instance.docker.*.private_ip}"
}
output "elastic-ip" {
    value = "${aws_eip.ip.public_ip}"
}