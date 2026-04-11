# Machine Learning Using Terraform as Automation

This repository contains the Infrastructure as Code (Terraform) and Kubernetes manifests for a resilient, scalable, and automated image processing pipeline on AWS.

## 🏗️ Architecture Overview

The system is designed with a decoupled, event-driven architecture combining serverless logic with containerized microservices:

1.  **Networking & Security**: A custom VPC (`25.1.0.0/16`) with public/private subnets, NAT Gateway, and IPv6 support. Security Groups are tailored for Load Balancer and Application traffic.
2.  **Serverless Data Pipeline**: 
    - **S3**: Trigger-based ingestion (`technoinput-pati-keefa`) and results storage (`technooutput-pati-keefa`).
    - **Lambda**: Node.js functions for real-time S3 triggers and DynamoDB operations.
    - **API Gateway**: REST API for token generation and verification.
3.  **Database & Notifications**:
    - **DynamoDB**: `Tokens` table with Streams enabled.
    - **Kinesis**: Real-time streaming destination for all token events.
    - **SNS**: Automated alerts sent to `handi@seamolec.org`.
4.  **Containerization (EKS/ECR)**:
    - **ECR**: Private registry for storing application images.
    - **EKS**: Managed Kubernetes cluster running the application microservices with a LoadBalancer-backed service.

## 🚀 Getting Started

### Prerequisites
- **Terraform** (v1.5+)
- **AWS CLI** configured with appropriate permissions (e.g., `LabRole`)
- **kubectl**
- **Docker**

### Deployment Steps

1.  **Initialize and Apply Infrastructure**:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```

2.  **Push Application Image**:
    Follow the ECR push instructions provided in the AWS Console for the `techno-ecr-pati-keefa` repository.

3.  **Update Kubeconfig**:
    ```bash
    aws eks update-kubeconfig --region us-east-1 --name techno-eks-pati-keefa
    ```

4.  **Deploy to Kubernetes**:
    ```bash
    kubectl apply -f deployment/
    ```

## 📂 Project Structure

- `networking.tf`: VPC, Subnets, NAT Gateway, and Routing.
- `security-group.tf`: Inbound and outbound traffic rules.
- `storage&dynamodb.tf`: S3 Buckets and DynamoDB table definitions.
- `lambda.tf`: Lambda functions and API Gateway integration.
- `data-processing.tf`: Kinesis, Glue, and Crawler configurations.
- `eks.tf`: EKS Cluster, Node Group, and ECR repository.
- `lambda_code/`: Node.js source code for serverless functions.
- `deployment/`: Kubernetes manifests (Deployment & Service).

## 📝 Naming Convention
All resources follow the pattern: `techno-<service>-pati-keefa`

## 👤 Author
- **Location**: Pati
- **Name**: Keefa
