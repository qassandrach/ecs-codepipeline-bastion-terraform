resource "aws_instance" "bastion" {
    ami = "ami-05c64f7b4062b0a21"
    instance_type = "t2.micro"
    tags = {
        Name = "qassie-bastion-host"
    }
    key_name = aws_key_pair.bastion.key_name
    subnet_id = aws_subnet.public-sub-2.id
    vpc_security_group_ids = [aws_security_group.bastion.id]
    private_ip = "10.10.102.12"
}
resource "aws_key_pair" "bastion" {
    key_name = "deployer-key"
    public_key = file("~/.ssh/terraform.pub")
  
}
resource "aws_security_group" "bastion" {
    name        = "allow_all_traffic_terr"
    vpc_id = aws_vpc.qassie-vpc.id
    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["124.158.144.202/32"]
  }
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
      Name = "qassie-bastion"
  }
  
}


