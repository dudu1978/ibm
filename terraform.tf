terraform {
  backend "s3" {
    bucket = "statefile_bucket"
    key    = "my_state_file"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

resource "aws_security_group" "ssh_sg" {
  vpc_id = "${module.vpc.id}"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project     = "Dudu"
  }
}

resource "aws_key_pair" "my_key" {
  public_key = "${var.public_key}"
}

resource "aws_instance" "my_instance" {
  count = 10
  subnet_id     = "${module.vpc.subnets[0]}"
  ami           = "ami-0000000000c0ba29"
  key_name      = "${aws_key_pair.key.key_name}"
  instance_type = "r6g.4xlarge"
    
  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

resource "aws_db_instance" "my_db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.m6g.4xlarge"
  name                 = "mydb"
  username             = "user"
  password             = "passworf"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

resource "aws_sqs_queue" "my_queue" {
  name                      = "my-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id           = "elasticache-cluster"
  engine               = "redis"
  node_type            = "cache.m4.2xlarge"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

resource "aws_elasticache_replication_group" "cluster1" {
  replication_group_id          = "tf-redis-cluster"
  replication_group_description = "test description"
  node_type                     = "cache.t2.small"
  port                          = 6379
  parameter_group_name          = "default.redis6.cluster.on"
  automatic_failover_enabled    = true
  engine         = "redis"
  engine_version = "6.x"

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 6
  }
  tags = {
    Environment = "production"
    Project     = "Dudu"
  }
}

