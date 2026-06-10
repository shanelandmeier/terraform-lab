provider "aws" {
    region = "us-east-2"
    }

resource "aws_instance" "example" {
    ami           = "ami-0fb653ca2d3203ac1"
    instance_type = "c7i-flex.large"

    tags = {
        Name = "terraform-example"
    }
}
