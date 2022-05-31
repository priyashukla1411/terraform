## Creating Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id               = "ami-0756a1c858554433e"
  instance_type          = "t2.micro"
  security_groups        = ["sg-0ff4b79808f9aad48"]
  key_name               = "shukla"
  user_data = <<-EOF
               #!/bin/bash
                    sudo apt update 
                    sudo apt install nginx -y
                    sudo systemctl start nginx
                    EOF

  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["ap-south-1a"]
  min_size = 2
  max_size = 10
 
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_autoscalingplans_scaling_plan" "example" {
  name = "autoooo-scalinggggg"
  application_source {
    tag_filter {
      key    = "application"
      values = ["example"]
    }
  }
scaling_instruction {
    max_capacity       = 5
    min_capacity       = 2
    resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.example.name)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"

    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"                   #cpu utilization(metric type)
      }
      target_value = 70
    }
  }
}

 

 















  
