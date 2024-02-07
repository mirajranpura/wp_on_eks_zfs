resource "aws_fsx_openzfs_file_system" "wp" {
  storage_capacity    = 64
  subnet_ids          = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
  preferred_subnet_id = module.vpc.private_subnets[0]
  security_group_ids =  [module.eks.node_security_group_id]
  deployment_type     = "MULTI_AZ_1"
  throughput_capacity = 160
}

output "openfsx-file-system" {
	description = "FileSystem ID to be consumed with K8s resources"
        value  = "${aws_fsx_openzfs_file_system.wp.root_volume_id}"
} 
