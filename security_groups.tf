# Security group for EMR Master node
resource "aws_security_group" "emr_master" {
  name        = "${var.project_name}-${var.environment}-emr-master-sg"
  description = "Security group for EMR master node with least privilege access"
  vpc_id      = var.vpc_id

  # Allow HTTPS for EMR web interfaces (only if CIDR blocks are specified)
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "HTTPS access to EMR master"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Allow SSH access (if key_name is provided and CIDR blocks are specified)
  dynamic "ingress" {
    for_each = var.key_name != "" && length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "SSH access to EMR master"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-master-sg"
  }
}

# Security group for EMR Core/Task nodes
resource "aws_security_group" "emr_slave" {
  name        = "${var.project_name}-${var.environment}-emr-slave-sg"
  description = "Security group for EMR core and task nodes"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-slave-sg"
  }
}

# Security group for EMR Service Access
resource "aws_security_group" "emr_service" {
  name        = "${var.project_name}-${var.environment}-emr-service-sg"
  description = "Security group for EMR service access"
  vpc_id      = var.vpc_id

  # Allow EMR service to communicate with cluster
  egress {
    description = "Allow EMR service communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-emr-service-sg"
  }
}

# Allow communication between master and core/task nodes
resource "aws_security_group_rule" "master_to_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_slave.id
  description              = "Allow master to communicate with core/task nodes"
}

resource "aws_security_group_rule" "slave_to_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_master.id
  description              = "Allow core/task nodes to communicate with master"
}

resource "aws_security_group_rule" "slave_to_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_slave.id
  description              = "Allow core/task nodes to communicate with each other"
}

# Allow EMR service access
resource "aws_security_group_rule" "service_to_master" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service.id
  security_group_id        = aws_security_group.emr_master.id
  description              = "Allow EMR service to communicate with master"
}
