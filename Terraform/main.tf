# creating VPC resource for AWS services
resource "aws_vpc" "web_application_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "web-application-vpc"
    Project = "web-application"
  }
}

# creating public subnet for AWS services
resource "aws_subnet" "web_application_subnet_public" {
  vpc_id                  = aws_vpc.web_application_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-application-subnet-public"
    Project = "web-application"
  }
}

# creating private subnet for AWS services
resource "aws_subnet" "web_application_subnet_private" {
  vpc_id                  = aws_vpc.web_application_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "web-application-subnet-private"
    Project = "web-application"
  }
}

# creating security group for AWS services
resource "aws_security_group" "web_application_security_group" {
  name        = "web-application-security-group"
  description = "Security group for AWS services"
  vpc_id      = aws_vpc.web_application_vpc.id

# outbound traffic
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

# inbound traffic
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  tags = {
    Name = "web-application-security-group"
  }
}   

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })

  tags = {
    Name = "web-application-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })

  tags = {
    Name = "web-application-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistry_ReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# creating ECR repo for storing Docker images
resource "aws_ecr_repository" "web_application_ecr" {
  name = var.ecr_cluster_name

  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}

# creating EKS cluster for deploying web application
resource "aws_eks_cluster" "web_application_eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_public.id, aws_subnet.eks_subnet_private.id]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

# creating required node groups 
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role       = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.eks_subnet_public.id]
  instance_types  = [var.node_instance_type]
  desired_size    = var.desired_capacity
  min_size        = var.min_size
  max_size        = var.max_size

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [aws_eks_cluster.eks]
}