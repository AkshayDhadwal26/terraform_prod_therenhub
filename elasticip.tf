resource "aws_eip" "prod" {
  domain = "vpc"
  tags = {
    Name = "Ren-Ath-ProdIP"
  }
}


resource "null_resource" "associate_eip" {
  provisioner "local-exec" {
    command = <<EOT
      INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName=='${aws_autoscaling_group.prod.name}'].InstanceId" --output text | head -n 1)
      aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${aws_eip.prod.id}
    EOT
  }
}

