locals {
  name_prefix = "${var.custom_tags["Project"] != "" ? var.custom_tags["Project"] : "default-project"}-${var.custom_tags["Environment"] != "" ? var.custom_tags["Environment"] : "default-env"}-${var.name != "" ? var.name : "default-name"}"
}


resource "aws_instance" "bastion" {
  count = var.create ? length(var.availability_zones) : 0
  ami                    = coalesce(var.ami, var.IsUbuntu ? data.aws_ami.ubuntu.id : data.aws_ami.linux2.id)
  instance_type         = var.type
  availability_zone     = element(var.availability_zones, count.index)
  subnet_id             = element(var.subnet_ids, count.index)
  vpc_security_group_ids = var.security_groups_ids
  hibernation           = var.hibernation
  associate_public_ip_address = var.associate_public_ip_address
  key_name              = var.key_name
  iam_instance_profile  = var.create_iam_instance_profile ? var.iam_instance_profile : null

  user_data             = var.user_data
  user_data_base64      = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_size           = var.volume_size          
    volume_type           = var.volume_type       
    delete_on_termination = var.delete_ebs_on_termination 
    encrypted             = var.encrypt_ebs         
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device

    content {
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = try(ebs_block_device.value.encrypted, null)
      iops                  = try(ebs_block_device.value.iops, null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = try(ebs_block_device.value.volume_size, null)
      volume_type           = try(ebs_block_device.value.volume_type, null)
      throughput            = try(ebs_block_device.value.throughput, null)
      tags                  = try(ebs_block_device.value.tags, null)
    }
  }

  tags = merge(
    {"Name" = "${local.name_prefix}-${count.index}"},
    var.ec2_tags,
    var.custom_tags
  )
}