#### Table of Contents
1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Providers](#Providers)
4. [Inputs](#inputs)
5. [Outputs](#outputs)

## usage

1. Ensure you have valid AWS creds in your environment (AWS_PROFILE or AWS_ACCESS_KEY/AWS_SECRET_KEY)
1. Make sure you have specified a valid pre-existing in AWS ssh_key_name in variables.tf
1. ```$ terraform plan```
1. ```$ terraform apply -auto-approve```
1. Output will give you three IP addresses:
    ```bash
    app_private_ip = "10.100.10.100"
    app_public_ip = "52.65.20.1"
    nva_public_ip = "54.206.25.6"
    ```
1. In one window SSH into your simulated app server instance via NVA and check you can access the internet:
    ```bash
    $ ssh -i ~/.ssh/terraform.pem -J ubuntu@54.206.25.6 ubuntu@10.100.10.100
    $ curl ifconfig.me
    52.65.20.1
    ```
    Notice you get the App Instance IP address back.
1. In a second window SSH into your NVA:
    ```bash
    $ ssh -i ~/.ssh/terraform.pem  ubuntu@54.206.25.6```
1. Take a look at the output log:
    ```
    $ cat /tmp/output.log
    Listening
    Dropped Inbound flow because port 33890 is not in the allow list
    Dropped Inbound flow because port 2001 is not in the allow list
    Dropped Inbound flow because port 3381 is not in the allow list
    Dropped Inbound flow because port 8088 is not in the allow list
    ```

1. If you try and ping from the App instance you will get no response as ICMP is blocked and you will see this message in the log:

    ```
    Dropped Outbound flow because protocol 1 is not in the allow list
    ```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| app\_private\_ip | App host Private IP |
| app\_public\_ip | App host Public IP |
| nva\_public\_ip | NVA Public IP |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
