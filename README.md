# Terraform Infrastructure as Code (IAC) for AWS Web Server Deployment

This Terraform code is a complete Infrastructure as Code (IAC) implementation to deploy a web server on AWS using Terraform. It automates the process of setting up a virtual private cloud (VPC), creating an internet gateway, a custom route table, a subnet, a security group, a network interface with an Elastic IP, and an Amazon EC2 instance running Ubuntu with Apache web server installed and enabled.

## Prerequisites
Before using this code, ensure you have the following prerequisites in place:

1. An AWS account with appropriate credentials.
2. Terraform installed on your local machine.

## Steps to Deploy
1. **Provider Configuration**: This code specifies the AWS provider and sets the region along with access and secret keys for authentication.

2. **Create VPC**: The first step is to create a Virtual Private Cloud (VPC) with the specified CIDR block and a custom tag for identification.

3. **Create Internet Gateway**: An internet gateway is created and associated with the previously created VPC to enable internet connectivity.

4. **Create Custom Route Table**: A custom route table is created for the VPC, and two routes are defined - one for IPv4 (`0.0.0.0/0`) and another for IPv6 (`::/0`), both pointing to the internet gateway.

5. **Create Subnet**: A subnet is created within the VPC, with the specified CIDR block and availability zone.

6. **Associate Subnet with Route Table**: The subnet created in the previous step is associated with the custom route table, allowing it to use the internet gateway for internet-bound traffic.

7. **Create Security Group**: A security group is created to allow inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS). It also allows all outbound traffic.

8. **Create Network Interface**: A network interface is created within the previously created subnet and associated with the security group. It is assigned a private IP address (`10.0.1.50`) that will later be associated with an Elastic IP.

9. **Assign Elastic IP**: An Elastic IP is created and associated with the network interface created in the previous step. This Elastic IP will remain consistent even if the instance is stopped and restarted.

10. **Create EC2 Instance**: An Amazon EC2 instance is launched with Ubuntu as the operating system. The instance is associated with the network interface created earlier. Additionally, a user data script is provided to install Apache web server and create a simple HTML page.

## How to Use
1. Update the `access_key` and `secret_key` in the provider block with your AWS credentials.

2. Optionally, update the `ami` (Amazon Machine Image) ID in the `aws_instance` resource to use a different OS or region.

3. Update the `key_name` with the name of your SSH key pair that you want to use for accessing the EC2 instance.

4. Run `terraform init` to initialize the Terraform configuration.

5. Run `terraform apply` to create the AWS resources as defined in the code. Terraform will display the changes that will be applied and prompt for confirmation. Type `yes` to proceed with the deployment.

6. Once the deployment is complete, Terraform will display the public IP address of the EC2 instance. You can access your web server by visiting this IP address in a web browser.

7. To clean up the resources, run `terraform destroy` when you are done.

## Notes
- Make sure to protect your `terraform.tfstate` file as it contains sensitive information about your infrastructure.

- This code provides a basic setup for a web server. For production use, consider adding additional security measures, scaling configurations, and managing your infrastructure more comprehensively.

- Always review your Terraform code and ensure it meets your specific requirements and security standards before deploying it to production environments.

- For more advanced use cases, you may need to modify the code to fit your organization's specific needs.

Happy Terraforming`:smiley:`!
