output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_ami_image.id
}

output "ec2-public_ip" {
  value = aws_instance.myapp_server.public_ip
}