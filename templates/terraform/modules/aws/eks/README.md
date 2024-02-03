# Terraform Setup for Simple EKS Cluster with VPC

This directory contains Terraform configurations to set up a simple EKS cluster with a new VPC, including 1 public subnet and 1 private subnet on AWS.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS credentials configured on your machine with the necessary permissions.
- An AWS region where you want to deploy the infrastructure.

## Configuration

Update the `terraform.tfvars` file with your desired values:

```hcl
region = "your-aws-region"
name   = "your-cluster-name"
cluster_version = "1.29"  # replace with your desired Kubernetes version
```

## Deployment Steps

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/jeffcorpuz/scripts.git
   cd terraform
   ```

2. **Initialize Terraform:**

   ```bash
   terraform init
   ```

3. **Apply Terraform Configuration:**

   ```bash
   terraform apply
   ```

   Review the changes, type "yes" when prompted, and wait for Terraform to provision the infrastructure.

## Clean Up

To clean up and destroy the created resources, run:

```bash
terraform destroy
```

Review the changes, type "yes" when prompted, and wait for Terraform to delete the resources.

## Configuration Details

### VPC Module

The VPC module (`terraform-aws-modules/vpc/aws`) sets up a VPC with public, private, and intra subnets. It also enables IPv6 support, NAT gateways, and assigns appropriate tags for Kubernetes roles.

### EKS Module

The EKS module (`terraform-aws-modules/eks/aws`) creates the EKS cluster with the specified Kubernetes version. It includes addons like CoreDNS, kube-proxy, and vpc-cni. IPv6 support is enabled, and IAM roles for service accounts (IRSA) are configured.

### Managed Node Group Module

The Managed Node Group module (`terraform-aws-modules/eks/aws//modules/eks-managed-node-group`) adds a default managed node group to the EKS cluster. It includes configuration for minimum, maximum, and desired sizes, instance types, and capacity type.

## Notes

- Ensure that your AWS credentials are properly configured on your machine.
- Review and customize the configurations based on your specific requirements.
- The provided configurations are for educational purposes. Adjust security settings, instance types, and other parameters according to your needs.

For more information on Terraform, refer to the [Terraform Documentation](https://www.terraform.io/docs/index.html).

**Happy Kubernetes Clustering!**