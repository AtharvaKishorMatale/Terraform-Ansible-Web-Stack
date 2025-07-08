#---                          Defines the AWS cloud provider and the region where resources will be created.
provider "aws" {
  region = "us-east-1"
}

# Defines an AWS Security Group, which acts as a virtual firewall for your EC2 instance.
resource "aws_security_group" "web_server_sg" {
  name        = "simple_web_server_sg"
  description = "Allow SSH (port 22) and HTTP (port 80) traffic for the web server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-web-sg"
  }
}

# Defines an AWS EC2 instance, which is your virtual server in the cloud.
resource "aws_instance" "web_server" {
  # <--- IMPORTANT: You MUST update this AMI ID to a valid Ubuntu Server AMI for us-east-1 (N. Virginia)
  # Example for Ubuntu Server 22.04 LTS (Jammy Jellyfish) in us-east-1 (as of June 2024): ami-053b0d53c279acc90
  # To find the latest for your needs:
  # 1. Go to AWS EC2 Console -> Instances -> Launch instance.
  # 2. Search for "Ubuntu Server" and select the desired version (e.g., 22.04 LTS).
  # 3. Copy its AMI ID, ensuring you are in the us-east-1 region.
  ami           = "ami-053b0d53c279acc90" # Example AMI for Ubuntu Server 22.04 LTS in us-east-1. REPLACE IF NEEDED.

  instance_type = "t2.micro"

  # REMOVED key_name = "my-simple-devops-key"

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # --- NEW: user_data block for Ubuntu-based instances ---
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y # Update package lists for Ubuntu
              apt-get install -y openssh-server # Ensure OpenSSH server is installed
              mkdir -p /home/ubuntu/.ssh # Create .ssh directory for ubuntu user
              echo "YOUR_PUBLIC_KEY_CONTENT_HERE" >> /home/ubuntu/.ssh/authorized_keys # <--- PASTE YOUR PUBLIC KEY HERE
              chmod 700 /home/ubuntu/.ssh # Set correct permissions for .ssh directory
              chmod 600 /home/ubuntu/.ssh/authorized_keys # Set correct permissions for authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh # Set correct ownership for ubuntu user
              systemctl start sshd # Start SSH daemon
              systemctl enable sshd # Enable SSH daemon to start on boot
              EOF
  # --- END of user_data block ---

  tags = {
    Name = "Simple-DevOps-Web-Server"
  }
}

# Defines an output variable that will display the public IP address of the created EC2 instance.
output "web_server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP address of the simple web server"
}
