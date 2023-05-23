resource "aws_instance" "main" {
  ami = "ami-0c54a07b70974b495"
  instance_type = "t3.micro"
  key_name = "dbaeten"
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_default_security_group.main.id]
  tags = {
    "Name" = "${var.default_tags.env}-EC2"
  }
  user_data = base64encode(file("C:/Users/Admin/Desktop/terraform/ec2.tf"))
}

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}