## Creating EC2 instance

resource "aws_instance" "EC2" {
  ami           = "ami-0756a1c858554433e"
  instance_type = "t2.micro"
  key_name = "shukla"
   tags                         = {
        "Name" = "Terraform"
    }
}
## Creating Security Group for EC2
resource "aws_security_group" "EC2" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


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


## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating ELB
resource "aws_elb" "example" {
  name = "terraform-asg-example"

  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["ap-south-1a"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
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










# ## Creating Launch Configuration
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

 

 















  
