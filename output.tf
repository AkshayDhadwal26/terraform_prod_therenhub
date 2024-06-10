resource "null_resource" "wait_for_instances" {
  provisioner "local-exec" {
    command = "sleep 120"  # Wait for instances to be created
  }

  depends_on = [aws_autoscaling_group.prod]
}

data "aws_instances" "prod" {
  filter {
    name   = "tag:Name"
    values = ["Prod-instance"]
  }
  depends_on = [null_resource.wait_for_instances]
}

output "instance_public_ips" {
  description = "Public IP addresses of the instances"
  value       = data.aws_instances.prod.public_ips
}

output "instance_private_ips" {
  description = "Private IP addresses of the instances"
  value       = data.aws_instances.prod.private_ips
}

