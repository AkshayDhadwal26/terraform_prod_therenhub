resource "aws_autoscaling_group" "prod" {
  desired_capacity     = 1
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.vpc_zone_identifier

  #launch_configuration = aws_launch_template.prod_launch_template.id
  launch_template {
    id      = aws_launch_template.prod_launch_template.id
    #version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Prod-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.prod.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.prod.name
}

resource "null_resource" "instance_protection" {
  count = 1
  provisioner "local-exec" {
    command = <<EOT
      INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${aws_autoscaling_group.prod.name}" --query "AutoScalingGroups[0].Instances[${count.index}].InstanceId" --output text)
      aws autoscaling set-instance-protection --instance-ids $INSTANCE_ID --auto-scaling-group-name "${aws_autoscaling_group.prod.name}" --protected-from-scale-in
    EOT
  }

  depends_on = [null_resource.wait_for_instances]
}
