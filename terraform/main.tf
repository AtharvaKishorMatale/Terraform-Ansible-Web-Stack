
# Defines the AWS cloud provider and the region where resources will be created.
provider "aws" {
  region = "us-east-1" # <--- IMPORTANT: This MUST match the region you configured in AWS CLI (Step 1.4)
                        # and where you uploaded your SSH key pair. Examples: "us-east-1", "eu-west-1", "ap-south-1".
}

# Defines an AWS Security Group, which acts as a virtual firewall for your EC2 instance.
resource "aws_security_group" "web_server_sg" {
  name        = "simple_web_server_sg" # A unique name for your security group
  description = "Allow SSH (port 22) and HTTP (port 80) traffic for the web server"

  # Ingress (inbound) rule to allow SSH connections from any IP address (0.0.0.0/0).
  # WARNING: Allowing SSH from anywhere (0.0.0.0/0) is not recommended for production environments.
  # For better security, restrict this to your specific public IP address (e.g., ["YOUR_HOME_IP_ADDRESS/32"]).
  ingress {
    from_port   = 22             # Start port for SSH
    to_port     = 22             # End port for SSH
    protocol    = "tcp"          # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Source IP range (anywhere)
  }

  # Ingress (inbound) rule to allow HTTP connections from any IP address.
  ingress {
    from_port   = 80             # Start port for HTTP
    to_port     = 80             # End port for HTTP
    protocol    = "tcp"          # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Source IP range (anywhere)
  }

  # Egress (outbound) rule to allow all outgoing traffic from the EC2 instance.
  egress {
    from_port   = 0              # Start port (all ports)
    to_port     = 0              # End port (all ports)
    protocol    = "-1"           # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Destination IP range (anywhere)
  }

  tags = {
    Name = "simple-web-sg" # A friendly tag to identify this security group in the AWS Console
  }
}

# Defines an AWS EC2 instance, which is your virtual server in the cloud.
resource "aws_instance" "web_server" {
  # The AMI (Amazon Machine Image) ID specifies the operating system and initial software.
  # The ID is specific to an AWS region.
  # ami-0b0af3577d612e5df is Amazon Linux 2 (HVM) in ap-south-1 (Mumbai).
  # <--- IMPORTANT: If you changed your AWS_REGION, you MUST update this AMI ID.
  # To find the correct AMI for your region:
  # 1. Go to AWS EC2 Console -> Instances -> Launch instance.
  # 2. Search for "Amazon Linux 2 AMI (HVM), SSD Volume Type".
  # 3. Copy its AMI ID.
  ami           = "ami-020cba7c55df1f615"

  instance_type = "t2.micro"                # The instance type, 't2.micro' is eligible for AWS Free Tier.
  key_name      = "my-simple-devops-key"    # <--- IMPORTANT: This MUST EXACTLY MATCH the name of the AWS Key Pair
                                            # you uploaded in Step 1.7 (e.g., "my-simple-devops-key").
  # Associates the Security Group defined above with this EC2 instance.
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name = "Simple-DevOps-Web-Server" # A friendly tag to identify this EC2 instance in the AWS Console
  }
}

# Defines an output variable that will display the public IP address of the created EC2 instance.
# This makes it easy to retrieve the IP address after Terraform applies the configuration.
output "web_server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP address of the simple web server"
}
