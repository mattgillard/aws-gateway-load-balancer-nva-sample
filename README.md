## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.17 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.17 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_default_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| [aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) |
| [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) |
| [aws_lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) |
| [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) |
| [aws_vpc_endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| TFC\_WORKSPACE\_NAME | n/a | `string` | `""` | no |
| app\_subnet | App Subnet | `string` | `"10.100.10.0/24"` | no |
| aws-access-key | AWS Access key | `string` | `null` | no |
| aws-profile | n/a | `any` | `null` | no |
| aws-secret-key | AWS Secret key | `string` | `null` | no |
| gwlb\_subnet | GWLB Subnet | `string` | `"10.100.200.0/24"` | no |
| healthcheck\_port | The port the LB will use for healthchecks | `number` | `80` | no |
| region | n/a | `string` | `"ap-southeast-2"` | no |
| security\_subnets | DMZ Subnets | `list(string)` | <pre>[<br>  "10.100.1.0/24",<br>  "10.100.2.0/24"<br>]</pre> | no |
| ssh\_key\_name | SSH key to use for ec2 instances | `string` | `"terraform"` | no |
| vpc\_cidr | CIDR range for VPC | `string` | `"10.100.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_public\_ip | n/a |
