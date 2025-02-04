output "instance_id" {
    value = aws_instance.bastion[*].id
}

output "instance_ip" {
  value = aws_instance.bastion[*].public_ip
}
