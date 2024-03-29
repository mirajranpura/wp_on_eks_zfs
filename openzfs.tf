resource "aws_fsx_openzfs_file_system" "wp" {
  storage_capacity    = 64
  subnet_ids          = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
  preferred_subnet_id = module.vpc.private_subnets[0]
  security_group_ids =  [module.eks.node_security_group_id]
  deployment_type     = "MULTI_AZ_1"
  throughput_capacity = 160
  depends_on = [ module.eks ]
}

# Adding security group rule for nodes to communicate with openzfs

resource "aws_vpc_security_group_ingress_rule" "allow_vpc_traffic_ipv4" {
  security_group_id = module.eks.node_security_group_id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1" # semantically equivalent to all ports
}


output "openfsx-volume" {
	description = "FileSystem ID to be consumed with K8s resources"
        value  = "${aws_fsx_openzfs_file_system.wp.root_volume_id}"
} 

output "create-storage-class-fsx" {
  value = <<EOF
  sed 's/fsvol-XXXX/${aws_fsx_openzfs_file_system.wp.root_volume_id}/g' wp_k8s/sc.yaml > wp_k8s/storageclass.yaml
  EOF 
}
