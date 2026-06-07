# --- Security Group ---
resource "aws_security_group" "airflow_sg" {
  name        = "airflow-ec2-sg"
  description = "Security group for Airflow EC2"

  # SSH access limited to specified IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"] 
  }

  # Airflow UI access limited to specified IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"]
  }

  # Outbound internet access (for package downloads and S3 uploads)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- IAM Setup for EC2 ---
resource "aws_iam_policy" "airflow_s3_policy" {
  name = "AirflowS3WriteAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Create an IAM Role for the EC2 instance
resource "aws_iam_role" "ec2_airflow_role" {
  name = "airflow_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the S3 policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "airflow_s3_attach" {
  role       = aws_iam_role.ec2_airflow_role.name
  policy_arn = aws_iam_policy.airflow_s3_policy.arn
}

# Create the Instance Profile to attach the Role to the EC2 instance
resource "aws_iam_instance_profile" "airflow_profile" {
  name = "airflow_ec2_profile"
  role = aws_iam_role.ec2_airflow_role.name
}

# --- EC2 Instance Definition ---

# Fetch the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical account (Ubuntu creators)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Create the EC2 instance
resource "aws_instance" "airflow_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium" # Minimum specs required for Airflow

  # Attach the previously created IAM profile and Security Group
  iam_instance_profile   = aws_iam_instance_profile.airflow_profile.name
  vpc_security_group_ids = [aws_security_group.airflow_sg.id]
  
  # SSH Key Pair name configured via variables
  key_name = var.key_name

  # Increase root volume to 20GB to accommodate Docker images and Airflow logs
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "Airflow-ZTM-Server"
  }
}

# Output the public IP address after creation
output "ec2_public_ip" {
  value       = aws_instance.airflow_server.public_ip
  description = "Public IP address of the Airflow EC2 instance"
}