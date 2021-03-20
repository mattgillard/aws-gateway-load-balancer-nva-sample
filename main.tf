# ref https://github.com/hashicorp/terraform-provider-aws/issues/16129

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.17"
    }
  }
  backend "remote" {
  }

}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "all" {}

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

provider "aws" {
  profile    = "matt"
  region     = var.region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

resource "aws_vpc" "security" {
  cidr_block = "10.100.0.0/16"
  tags = merge(
    local.common_tags,
    map(
      "Name", "security"
    )
  )

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.security.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "security igw"
    )
  )
}

resource "aws_subnet" "sec1" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "ap-southeast-2a"
  tags = merge(
    local.common_tags,
    map(
      "Name", "sec1"
    )
  )
}

resource "aws_subnet" "app1" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = "10.100.10.0/24"
  availability_zone = "ap-southeast-2a"
  tags = merge(
    local.common_tags,
    map(
      "Name", "app1"
    )
  )
}

resource "aws_subnet" "sec2" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = "ap-southeast-2b"
  tags = merge(
    local.common_tags,
    map(
      "Name", "sec2"
    )
  )
}

resource "aws_subnet" "gwlbe" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = "10.100.200.0/24"
  availability_zone = "ap-southeast-2a"
  tags = merge(
    local.common_tags,
    map(
      "Name", "gwlbe"
    )
  )
}

#tfsec:ignore:AWS005
resource "aws_lb" "gwlb" {
  name               = "test-gwlb"
  load_balancer_type = "gateway"
  subnets            = aws_subnet.sec1.*.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "security igw",
      "Environment", "Production"
    )
  )
}

resource "aws_lb_target_group" "gwlb-tg" {
  name     = "gwlb-test-tg"
  port     = 6081
  protocol = "GENEVE"
  vpc_id   = aws_vpc.security.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
  tags = merge(
    local.common_tags,
    map(
      "Name", "gwlb target group",
      "Environment", "Production"
    )
  )
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.gwlb-tg.arn
  target_id        = aws_instance.nva.id
}

resource "aws_vpc_endpoint_service" "gwlb-es" {
  acceptance_required = false
  #allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
}

resource "aws_vpc_endpoint" "gwlbep" {
  service_name      = aws_vpc_endpoint_service.gwlb-es.service_name
  subnet_ids        = [aws_subnet.gwlbe.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb-es.service_type
  vpc_id            = aws_vpc.security.id
  tags = merge(
    local.common_tags,
    map(
      "Name", "gwlbep",
      "Environment", "Production"
    )
  )
}

#tfsec:ignore:AWS004
resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.id

  default_action {
    target_group_arn = aws_lb_target_group.gwlb-tg.id
    type             = "forward"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.security.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.common_tags,
    map(
      "Name", "default security vpc table",
      "Environment", "Production"
    )
  )
}

resource "aws_route_table" "apps" {
  vpc_id = aws_vpc.security.id
  tags = merge(
    local.common_tags,
    map(
      "Name", "app route table",
      "Environment", "Production"
    )
  )
}

resource "aws_route" "apps_default" {
  route_table_id         = aws_route_table.apps.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbep.id
}

resource "aws_route_table_association" "app1" {
  subnet_id      = aws_subnet.app1.id
  route_table_id = aws_route_table.apps.id
}

resource "aws_route_table" "ingress_routes" {
  vpc_id = aws_vpc.security.id
}

resource "aws_route" "ingress_route1" {
  route_table_id         = aws_route_table.ingress_routes.id
  destination_cidr_block = "10.100.10.0/24"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbep.id
}

resource "aws_route_table_association" "igw" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.ingress_routes.id
}


resource "aws_instance" "nva" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true #tfsec:ignore:AWS012
  key_name                    = "terraform"
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
	      sudo apt install python3-pip net-tools -y
	      cd geneve-proxy
	      sudo pip3 install -r requirements.txt
	      sudo nohup python3 main.py > /tmp/output.log &
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
  key_name                    = "terraform"
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
    from_port   = 80
    to_port     = 80
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
output "nva_public_ip" {
  value = aws_instance.nva.public_ip
}
output "app_public_ip" {
  value = aws_instance.app.public_ip
}
