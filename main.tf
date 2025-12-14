#####################################
# Define the AWS provider and region#
####################################

provider "aws" {
  region = "eu-central-1" # Replace with your desired region
}

###########################
# Create a Security Group #
###########################

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-access-sg"
  description = " SSH  22  HTTP 80"

  # Rule for SSH access from anywhere (0.0.0.0/0) - **WARNING: for real use, restrict the IP**
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule for HTTP access (Nginx) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule for outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx_access_sg"
  }
}

###################################
# Create an EC2 instance (Ubuntu) #
###################################

resource "aws_instance" "nginx_server" {
  # ami-0... - Replace with the actual Ubuntu AMI ID for the chosen region!
  ami           = "ami-0a116fa7c861dd5f9" 
  count = 3
  instance_type = "t2.micro" 
  security_groups = [aws_security_group.nginx_sg.name]
  key_name = "ansible" # Replace with the name of your SSH key in AWS!
  associate_public_ip_address = true

  tags = {
    Name = element(["host0", "host1", "host2",], count.index)
  }
}

##########################
# Output the Nginx URL   #
##########################

output "nginx_instances" {
  description = "Names and public IPs of the deployed Nginx servers"
  value = [
    for instance in aws_instance.nginx_server :
    {
      name = instance.tags["Name"]
      ip   = instance.public_ip
    }
  ]
}
