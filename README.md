# AWS Modules - EKS

A modular approach for deploying and managing an Amazon Elastic Kubernetes Service (EKS) cluster on AWS using Terraform. This repository provides reusable, configurable modules to simplify the deployment of EKS clusters and associated resources.

---

## Features

- Modular design for scalable and reusable infrastructure.
- Support for creating and managing:
  - EKS clusters
  - IAM roles and policies
  - Worker nodes (via Auto Scaling Groups or Launch Templates)
  - Security groups
- Seamless integration with existing AWS VPCs.
- Configurable inputs for flexibility across environments (development, staging, production).

---

## Repository Structure

The repository is organized into logical modules for better maintainability:

| Directory           | Description                                     |
| ------------------- | ----------------------------------------------- |
| `iam/`              | Manages IAM roles and policies required by EKS. |
| `vpc/`              | Configurations for VPC networking.              |
| `.github/workflows` | CI/CD workflows for automated testing.          |

---

## Requirements

- **Terraform Version**: `>= 1.3.0`
- **AWS Provider Version**: `>= 5.0`
- An existing VPC with subnets configured.

---

## Usage

### Basic Example

Below is an example of how to use this module to deploy an EKS cluster:

module "eks_cluster" {
source = "github.com/SrivenkateswaraReddy/aws-modules-eks"

cluster_name = "my-eks-cluster"
vpc_id = "vpc-12345678"
private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
public_subnet_ids = ["subnet-23456789", "subnet-98765432"]

worker_node_instance_type = "t3.medium"
desired_capacity = 2
max_size = 3
min_size = 1
}



### Inputs
The module accepts the following key inputs:

| Name                        | Description                                   | Type     | Default       | Required |
|-----------------------------|-----------------------------------------------|----------|---------------|----------|
| `cluster_name`              | Name of the EKS cluster                      | `string` | `"eks-cluster"` | Yes      |
| `vpc_id`                    | ID of the existing VPC                       | `string` | `null`        | Yes      |
| `private_subnet_ids`        | List of private subnet IDs                   | `list`   | `[]`          | Yes      |
| `public_subnet_ids`         | List of public subnet IDs                    | `list`   | `[]`          | Yes      |
| `worker_node_instance_type` | Instance type for worker nodes               | `string` | `"t3.medium"` | No       |
| `desired_capacity`          | Desired number of worker nodes               | `number` | `2`           | No       |
| `max_size`                  | Maximum number of worker nodes               | `number` | `3`           | No       |
| `min_size`                  | Minimum number of worker nodes               | `number` | `1`           | No       |

### Outputs
The module provides the following outputs:

| Name               | Description                            |
|--------------------|----------------------------------------|
| `cluster_endpoint` | The endpoint URL of the EKS cluster    |
| `cluster_name`     | The name of the created EKS cluster    |

---

## Getting Started

### Prerequisites
1. Install [Terraform](https://www.terraform.io/downloads.html).
2. Configure AWS CLI with appropriate credentials:
3. Ensure you have an existing VPC with subnets.

### Steps
1. Clone this repository:

git clone https://github.com/SrivenkateswaraReddy/aws-modules-eks.git
cd aws-modules-eks

2. Update variables in your Terraform configuration file (`main.tf`) as needed.
3. Initialize Terraform:

terraform init

4. Plan your changes:

terraform plan

5. Apply the changes:

terraform apply


---

## Best Practices
- Store Terraform state remotely (e.g., in an S3 bucket with DynamoDB locking).
- Use version constraints in your Terraform configuration to ensure compatibility.
- Tag resources consistently for better cost management and tracking.

---

## Contributing
Contributions are welcome! To contribute:
1. Fork this repository.
2. Create a feature branch:

git checkout -b feature/my-feature

3. Commit your changes:

git commit -m "Add my feature"

4. Push your branch:

git push origin feature/my-feature

5. Open a pull request.

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments
This module was inspired by best practices in Terraform and AWS infrastructure management.
