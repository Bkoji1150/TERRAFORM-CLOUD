
resource "local_file" "ansible_inventory" {
  count = length(data.aws_instances.this.public_ips) > 0 || length(module.ubuntu.*.public_ip) > 0 || length(module.redhat.*.public_ip) > 0 ? 1 : 0

  depends_on = [data.aws_instances.this, module.ubuntu, module.redhat]
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      amazon_ec2_cfg = "${data.aws_instances.this.public_ips}",
      ubuntu_ec2_cfg = "${module.ubuntu.*.public_ip}",
      redhat_ec2_cfg = "${module.redhat.*.public_ip}"
    }
  )
  filename = "${path.module}/ansible/inventory/hosts"
}
