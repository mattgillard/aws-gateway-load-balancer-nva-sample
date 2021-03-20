resource "aws_vpc" "security" {
  cidr_block = var.vpc_cidr
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
  vpc_id     = aws_vpc.security.id
  cidr_block = var.security_subnets[0]
  #availability_zone = "ap-southeast-2a"
  availability_zone = data.aws_availability_zones.all.names[0]
  tags = merge(
    local.common_tags,
    map(
      "Name", "sec1"
    )
  )
}

resource "aws_subnet" "sec2" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = var.security_subnets[1]
  availability_zone = data.aws_availability_zones.all.names[1]
  tags = merge(
    local.common_tags,
    map(
      "Name", "sec2"
    )
  )
}

resource "aws_subnet" "app1" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = var.app_subnet
  availability_zone = data.aws_availability_zones.all.names[0]
  tags = merge(
    local.common_tags,
    map(
      "Name", "app1"
    )
  )
}

resource "aws_subnet" "gwlbe" {
  vpc_id            = aws_vpc.security.id
  cidr_block        = var.gwlb_subnet
  availability_zone = data.aws_availability_zones.all.names[0]
  tags = merge(
    local.common_tags,
    map(
      "Name", "gwlbe"
    )
  )
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
  destination_cidr_block = var.app_subnet
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbep.id
}

resource "aws_route_table_association" "igw" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.ingress_routes.id
}
