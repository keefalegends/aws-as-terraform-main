# ECR Repository
resource "aws_ecr_repository" "techno-ecr" {
  name                 = "techno-ecr-pati-keefa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# EKS Cluster
resource "aws_eks_cluster" "techno-eks" {
  name     = "techno-eks-pati-keefa"
  role_arn = "arn:aws:iam::526312876991:role/LabRole"
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.public-subnet-1.id,
      aws_subnet.public-subnet-2.id,
      aws_subnet.private-subnet-1.id,
      aws_subnet.private-subnet-2.id
    ]
    security_group_ids = [aws_security_group.appsg.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# EKS Node Group
resource "aws_eks_node_group" "techno-nodegroup" {
  cluster_name    = aws_eks_cluster.techno-eks.name
  node_group_name = "techno-nodegroup-pati-keefa"
  node_role_arn   = "arn:aws:iam::526312876991:role/LabRole"
  subnet_ids      = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.large"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  # Note: Since we use LabRole, we don't manage policy attachments.
}
