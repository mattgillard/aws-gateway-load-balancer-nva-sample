# ref https://github.com/hashicorp/terraform-provider-aws/issues/16129

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.17"
    }
  }
  #  backend "remote" { }

}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "all" {}

#####
# Gateway Load Balancer Config
#####

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
    port     = var.healthcheck_port
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
