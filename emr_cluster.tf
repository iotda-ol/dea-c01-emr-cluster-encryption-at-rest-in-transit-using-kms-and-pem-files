# EMR Cluster with security configuration applied
resource "aws_emr_cluster" "secure_cluster" {
  name          = "${var.project_name}-${var.environment}-cluster"
  release_label = var.emr_release_label
  applications  = ["Spark", "Hadoop", "Hive", "Livy"]

  # Apply security configuration with encryption
  security_configuration = aws_emr_security_configuration.encryption_config.name

  # Termination protection
  termination_protection            = var.enable_termination_protection
  keep_job_flow_alive_when_no_steps = true

  # Logging configuration
  log_uri = "s3://${aws_s3_bucket.logs.id}/emr-logs/"

  # Service role
  service_role = aws_iam_role.emr_service_role.arn

  # Auto-scaling role
  autoscaling_role = aws_iam_role.emr_autoscaling_role.arn

  # EC2 attributes
  ec2_attributes {
    subnet_id                         = var.subnet_id
    key_name                          = var.key_name != "" ? var.key_name : null
    instance_profile                  = aws_iam_instance_profile.emr_ec2_instance_profile.arn
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
    service_access_security_group     = aws_security_group.emr_service.id
  }

  # Master instance group
  master_instance_group {
    instance_type  = var.emr_master_instance_type
    instance_count = 1

    ebs_config {
      size                 = 64
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  # Core instance group
  core_instance_group {
    instance_type  = var.emr_core_instance_type
    instance_count = var.emr_core_instance_count

    ebs_config {
      size                 = 64
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  # Bootstrap actions - can be used to configure additional security settings
  # Uncomment and customize as needed
  # bootstrap_action {
  #   name = "Install additional security tools"
  #   path = "s3://my-bucket/bootstrap-actions/install-security-tools.sh"
  # }

  # Configurations for EMR applications
  configurations_json = jsonencode([
    {
      Classification = "spark-defaults"
      Properties = {
        "spark.authenticate" = "true"
        # Note: In production, use AWS Secrets Manager for spark.authenticate.secret
        # For now, this should be set via bootstrap action or EMR configuration API
        "spark.network.crypto.enabled"  = "true"
        "spark.ssl.enabled"             = "true"
        "spark.eventLog.enabled"        = "true"
        "spark.eventLog.dir"            = "s3://${aws_s3_bucket.logs.id}/spark-logs/"
        "spark.history.fs.logDirectory" = "s3://${aws_s3_bucket.logs.id}/spark-logs/"
      }
    },
    {
      Classification = "hadoop-env"
      Configurations = [
        {
          Classification = "export"
          Properties = {
            "HADOOP_OPTS" = "$HADOOP_OPTS -Djava.security.properties=/etc/hadoop/conf/java.security"
          }
        }
      ]
    },
    {
      Classification = "core-site"
      Properties = {
        "hadoop.ssl.enabled"                 = "true"
        "hadoop.ssl.require.client.cert"     = "false"
        "hadoop.ssl.hostname.verifier"       = "DEFAULT"
        "hadoop.ssl.keystores.factory.class" = "org.apache.hadoop.security.ssl.FileBasedKeyStoresFactory"
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  }

  depends_on = [
    aws_emr_security_configuration.encryption_config,
    aws_iam_role_policy_attachment.emr_service_policy,
    aws_iam_role_policy_attachment.emr_ec2_policy,
    aws_iam_instance_profile.emr_ec2_instance_profile
  ]
}
