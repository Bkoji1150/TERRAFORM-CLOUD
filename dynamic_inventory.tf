
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      amazon_ec2_cfg = "${data.aws_instances.this.public_ips}",
      ubuntu_ec2_cfg = "${module.ubuntu.*.public_ip}",
      redhat_ec2_cfg ="${module.redhat.*.public_ip}"
    }
  )
  filename = "host.cfg"
}