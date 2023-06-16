resource "aws_instance" "Master" {
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = aws_key_pair.key_pair.key_name
  tags = {
    Servers = "K8S_Servers"
    Name    = "K8S_Master"
    Type    = "Master"
  }
  root_block_device {
    volume_size = 8
    tags = {
      Name = "K8S_Master_Root_Volume"
    }
  }
}
