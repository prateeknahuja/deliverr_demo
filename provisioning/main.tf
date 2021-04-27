terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_iam_instance_profile" "eb_profile" {
  name = "eb-instance-profile"
  role = "aws-elasticbeanstalk-ec2-role"
}

resource "aws_s3_bucket" "deliverr-bucket" {
  bucket = "deliverr-elastic-beanstalk-bucket"
}

locals {
  deliverr_app_bundle_path = "${path.module}/../deliverr_v3.zip"
}

resource "aws_s3_bucket_object" "deliverr_app_latest" {
  bucket = aws_s3_bucket.deliverr-bucket.id
  key    = "deliverr-${filesha256(local.deliverr_app_bundle_path)}.zip"
  source = local.deliverr_app_bundle_path
}

resource "aws_elastic_beanstalk_application" "deliverrApp" {
  name        = "deliverr-app"
  description = "Deliverr application"
}

resource "aws_elastic_beanstalk_application_version" "deliverr_app_latest" {
  name        = "deliverr-${filesha256(local.deliverr_app_bundle_path)}"
  application = aws_elastic_beanstalk_application.deliverrApp.name
  bucket      = aws_s3_bucket_object.deliverr_app_latest.bucket
  key         = aws_s3_bucket_object.deliverr_app_latest.key
}
resource "aws_elastic_beanstalk_environment" "deliverrEnv" {
  name                = "deliverr-app"
  application         = aws_elastic_beanstalk_application.deliverrApp.name
  solution_stack_name = "64bit Amazon Linux 2 v5.3.1 running Node.js 14"
  version_label       = aws_elastic_beanstalk_application_version.deliverr_app_latest.name
   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${aws_iam_instance_profile.eb_profile.name}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.main.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.rds_subnet_1.id},${aws_subnet.rds_subnet_2.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.main-public-1.id},${aws_subnet.main-public-2.id}"
  }  
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }
   setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.app-deliverr.id}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_USERNAME"
    value = "${aws_db_instance.deliverrInstance.username}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = "${aws_db_instance.deliverrInstance.password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_DATABASE"
    value = "${aws_db_instance.deliverrInstance.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_HOSTNAME"
    value = "${aws_db_instance.deliverrInstance.endpoint}"
  }
}