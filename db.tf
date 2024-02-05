module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.0.0"
  name                            = "wp-aurora-mysql"

###
  engine          = "aurora-mysql"
  engine_version  = "8.0"
  master_username = "wpdb"
  

# Manage in Secret Manager Or use the master_password parameter below 
  manage_master_user_password = true
#  master_password = "your secret creds"

# DB name to be used for the application 
  database_name	= "wpdb"

# DB nodes 
  instances = {
    1 = {
      instance_class      = "db.t3.medium"
      publicly_accessible = false
      identifier     = "wp-db-mysql"
    }
#    2 = {
#      identifier     = "wp-db-mysql-2"
#      instance_class = "db.t3.medium"
#    }
  }

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  apply_immediately   = false
  skip_final_snapshot = true


  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "wpdbparametercluster"
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = "cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "pending-reboot"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "aurora_parallel_query"
      value        = "0"
      apply_method = "pending-reboot"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "wpdbparameterinstance"
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "WP DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
      }, {
      name         = "general_log"
      value        = 0
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "pending-reboot"
      }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
      }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
      }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]

  tags = local.tags
}



