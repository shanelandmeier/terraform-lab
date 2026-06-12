provider "aws" {
    region = "us-east-2"
    }

variable "server_port" {
    description = "The port on which the server will user for HTTP requests"
    type        = number    
    default     = 8080
}

output "instance_public_ip" {
    description = "The public IP address of the web server"
    value = aws_instance.example.public_ip
}

resource "aws_launch_configuration" "example" {
    image_id           = "ami-0fb653ca2d3203ac1"
    instance_type      = "c7i-flex.large"
    security_groups    = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                sleep 10
                echo "Hello, World!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    # Required when using a launch configuration with an Auto Scaling group
    lifecycle {
        create_before_destroy = true
    }
} 

resource "aws_autoscaling_group" "example" {
    launch_configuration      = aws_launch_configuration.example.name
    vpc_zone_identifier       = [data.aws_subnet.default.id]

    min_size                  = 2
    max_size                  = 10

    tag {
        key                 = "Name"
        value               = "terraform-example-instance"
        propagate_at_launch = true
    }
}

resource "aws_security_group" "instance" {
    name        = "terraform-example-instance"
    description = "Allow HTTP traffic"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet" "default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}