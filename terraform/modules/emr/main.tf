# EMR Cluster Module

resource "aws_emr_cluster" "main" {
  name          = "${var.project_name}-${var.environment}-cluster"
  release_label = var.release_label
  applications  = var.applications

  service_role = var.service_role

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.master_security_group_id
    emr_managed_slave_security_group  = var.slave_security_group_id
    instance_profile                  = var.instance_profile
    key_name                          = var.key_name
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count

    ebs_config {
      size                 = var.ebs_volume_size
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  security_configuration = var.security_configuration

  log_uri = "s3://${var.logs_bucket}/emr-logs/"

  auto_termination_policy {
    idle_timeout = var.auto_terminate ? var.idle_timeout_seconds : null
  }

  configurations_json = jsonencode([
    {
      Classification = "hadoop-env"
      Properties     = {}
      Configurations = [
        {
          Classification = "export"
          Properties = {
            "JAVA_HOME" = "/usr/lib/jvm/java-openjdk"
          }
        }
      ]
    },
    {
      Classification = "spark-env"
      Properties     = {}
      Configurations = [
        {
          Classification = "export"
          Properties = {
            "JAVA_HOME" = "/usr/lib/jvm/java-openjdk"
          }
        }
      ]
    }
  ])

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-emr-cluster"
    }
  )
}
