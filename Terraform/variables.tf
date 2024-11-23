variable "region" {
  description = "The AWS region to deploy the EKS cluster"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "ecr_cluster_name" {
  description = "Name of the ECR cluster"
  default     = "nginx-web-application-ecr"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "nginx-web-application-eks"
}

variable "node_instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t2.small"
}

variable "desired_capacity" {
  description = "The desired number of worker nodes"
  default     = 2
}

variable "min_size" {
  description = "The minimum number of worker nodes"
  default     = 1
}

variable "max_size" {
  description = "The maximum number of worker nodes"
  default     = 3
}
