#creating aws_launch_configuration
resource "aws_launch_configuration" "main" {
  name            = "${var.env_code}-"
  image_id        = data.aws_ami.amazonlinux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.private.id]
  user_data       = file("user_data.sh")
  key_name        = "myproject01"
}



#creating aws_autoscaling_group
resource "aws_autoscaling_group" "main" {
  name             = var.env_code
  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  target_group_arn    = [aws_lb_target_group.main.arn]
  aunch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier = data.terraform_remote_state.level-1.outputs.private_subnet_id

  tag {
    key                 = name
    value               = var.env_code
    propagate_at_launch = true
  }
}
