locals {
  # Required by the AWS Load Balancer Controller to discover subnets for
  # internal NLBs/ALBs.
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_ec2_tag" "private_subnet_tags" {
  for_each = {
    for pair in setproduct(var.private_subnet_ids, keys(local.private_subnet_tags)) :
    "${pair[0]}-${pair[1]}" => {
      subnet_id = pair[0]
      tag_key   = pair[1]
      tag_value = local.private_subnet_tags[pair[1]]
    }
  }

  resource_id = each.value.subnet_id
  key         = each.value.tag_key
  value       = each.value.tag_value
}
