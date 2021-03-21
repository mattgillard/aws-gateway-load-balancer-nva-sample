data "aws_ami" "ami" {
  most_recent = true

  filter {
    name = "name"
    #    values = ["amzn2-ami-minimal-hvm-2.0.*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  #  owners = ["137112412989"] # Amazon
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "nva" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true #tfsec:ignore:AWS012
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  subnet_id                   = aws_subnet.sec1.id
  provisioner "local-exec" {
    command = <<EOH
env
EOH
  }

  user_data = <<-EOF
	      #!/bin/bash
	      cd /home/ubuntu
	      git clone https://github.com/sentialabs/geneve-proxy.git
	      sudo apt update
	      sudo apt install python3-pip net-tools expect -y
	      cd geneve-proxy
	      sudo pip3 install -r requirements.txt
	      sudo sh -c 'nohup unbuffer python3 main.py > /tmp/output.log &'
              EOF
  tags = merge(
    local.common_tags,
    map(
      "Name", "NVA",
      "Environment", "Production"
    )
  )
}
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true #tfsec:ignore:AWS012
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  subnet_id                   = aws_subnet.app1.id
  tags = merge(
    local.common_tags,
    map(
      "Name", "test-host",
      "Environment", "Production"
    )
  )
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.security.id

  ingress {
    description = "http from VPC"
    from_port   = var.healthcheck_port
    to_port     = var.healthcheck_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS008
  }
  ingress {
    description = "GENEVE"
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS008
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS008
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "NVA Security Group",
      "Environment", "Production"
    )
  )
}
