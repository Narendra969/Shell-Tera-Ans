resource "aws_instance" "kubectl" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  count                  = "1"
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = aws_key_pair.key_pair.key_name
  tags = {
    Name = "Kubectl_Client"
  }
  root_block_device {
    volume_size = 8
    tags = {
      Name = "K8S_Worker${count.index + 1}_Root_Volume"
    }
  }
}
