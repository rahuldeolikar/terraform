provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "web" {
  ami                    = "ami-02f3416038bdb17fb"
  instance_type          = "t2.micro"
  key_name               = "ohiokey"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  user_data = <<EOF
  #!/bin/bash
  sudo apt-get update -y
  java -version
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
  sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  java -version
  sudo apt install default-jdk -y
  sudo apt install openjdk-11-jre -y
  sudo apt install default-jre -y
  
  sudo apt install jenkins -y
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo ufw allow 8080
  sudo ufw allow OpenSSH
  sudo ufw enable

  EOF

  tags = {
    Name = "jenkins-server"
  }
}
resource "aws_eip" "loadip" {
  instance = aws_instance.web.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg-23-08"
  }
}
resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.allow_tls.id]

  attachment {
    instance     = aws_instance.web.id
    device_index = 1
  }

}