# Reproducible Azure Setup with Terraform

This project creates a small Azure environment using Terraform.

The goal was to learn how to create cloud infrastructure as code instead of manually creating resources in the Azure Portal.

The environment hosts an existing Dockerized web application on an Ubuntu VM.

## Architecture
<img width="845" height="632" alt="image" src="https://github.com/user-attachments/assets/4bd54ed4-f711-4dad-85d2-d2459bed1d55" />


## What this project creates

Terraform creates:

- Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Public IP
- Network Interface
- Ubuntu Linux VM

The VM uses cloud-init to:

- Install Docker
- Start Docker
- Pull the application image from Docker Hub
- Run the application container
- Expose the application on port 80

## Architecture

The basic traffic flow is:

```text
Internet
   |
   | HTTP :80
   v
Public IP
   |
Network Security Group
   |
Network Interface
   |
Virtual Network
   |
Subnet
   |
Ubuntu VM
   |
Docker
   |
Web application :3000
```

SSH access on port 22 is only allowed from my own public IP.

HTTP on port 80 is publicly accessible.

All other inbound traffic is blocked by the default Azure NSG rules.

## Technologies used

- Microsoft Azure
- Terraform
- AzureRM Terraform Provider
- Linux / Ubuntu
- Docker
- Docker Hub
- cloud-init
- Azure CLI
- SSH

## Azure configuration

Region:

```text
Poland Central
```

Network:

```text
VNet:   10.0.0.0/22
Subnet: 10.0.1.0/24
```

VM:

```text
Standard_B2ls_v2
Ubuntu Server 22.04 LTS
```

The VM size and region were selected based on the restrictions and quotas of the Azure subscription used for this project.

## Project structure

```text
Terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
└── .terraform.lock.hcl
```

`terraform.tfvars` is not committed because it contains local configuration such as my public IP and SSH key path.

Terraform state files are also not committed.

## Requirements

Before using the project you need:

- Terraform
- Azure CLI
- Azure account/subscription
- Docker image available from Docker Hub
- SSH key pair

Login to Azure:

```powershell
az login
```

Check the active account:

```powershell
az account show
```

## Variables

Example `terraform.tfvars`:

```hcl
my_public_ip = "YOUR_PUBLIC_IP/32"

ssh_public_key_path = "~/.ssh/azure_terraform_project.pub"

docker_image = "your-dockerhub-user/your-image:v1"
```

Your public IP can be checked with:

```powershell
Invoke-RestMethod -Uri "https://api.ipify.org"
```

The `/32` means only that exact IP address is allowed to use SSH.

## Deploying the infrastructure

Initialize Terraform:

```powershell
terraform init
```

Check the configuration:

```powershell
terraform fmt
terraform validate
```

Preview the infrastructure:

```powershell
terraform plan
```

Create the infrastructure:

```powershell
terraform apply
```

Terraform will show the planned changes before creating anything.

## Validation

After deployment I validated the environment instead of only trusting that `terraform apply` succeeded.

### Check Terraform

```powershell
terraform plan
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

### Check the web application

Get the public IP from Azure or Terraform and run:

```powershell
curl.exe http://PUBLIC_IP
```

The application should return its HTML.

Port 80 can also be tested with:

```powershell
Test-NetConnection PUBLIC_IP -Port 80
```

### Check SSH

```powershell
ssh azureuser@PUBLIC_IP
```

Inside the VM:

```bash
sudo cloud-init status --long
```

Expected:

```text
status: done
```

Check Docker:

```bash
sudo docker ps
```

The application container should be running with a port mapping similar to:

```text
0.0.0.0:80->3000/tcp
```

Test the application directly from the VM:

```bash
curl http://localhost
```

## Reproducibility test

The main goal of this project was not just to get one VM working.

I wanted to check if the environment could actually be recreated from the Terraform configuration.

I destroyed everything with:

```powershell
terraform destroy
```

After confirming the Azure resources were removed, I recreated everything using:

```powershell
terraform apply
```

The new VM automatically:

1. Started from a clean Ubuntu image
2. Ran cloud-init
3. Installed Docker
4. Pulled the application image from Docker Hub
5. Started the container
6. Exposed the application on port 80

The application was reachable again without manually configuring the VM.

This validated that the environment was reproducible.

## Problems I ran into

### Azure region policy

The first region I selected was blocked by an Azure Policy on my subscription.

I checked which regions were allowed and changed the deployment region.

Allowed regions included:

```text
Italy North
Poland Central
UAE North
France Central
Spain Central
```

### VM availability and quota

A VM size being listed in Azure does not automatically mean my subscription can deploy it.

I ran into multiple problems:

- VM SKU not available in the selected region
- VM family quota set to 0
- VM restricted for my subscription

I used:

```powershell
az vm list-skus
```

and:

```powershell
az vm list-usage
```

to compare:

- Region availability
- Subscription restrictions
- VM family quota

I eventually selected `Standard_B2ls_v2` in Poland Central.

### Terraform subnet state problem

Terraform created the subnet in Azure but the AzureRM provider returned an inconsistent result directly after creation.

The subnet existed in Azure but was missing from Terraform state.

I confirmed the subnet existed using the Azure CLI and then imported it into Terraform state:

```powershell
terraform import azurerm_subnet.project_subnet "<SUBNET_RESOURCE_ID>"
```

After the import, Terraform correctly recognized the existing subnet.

### Wrong Docker port mapping

The first cloud-init configuration used:

```text
80:8080
```

The application actually listens on port `3000`.

The correct mapping is:

```text
80:3000
```

The final Docker command uses:

```bash
docker run -d \
  --name webapp \
  -p 80:3000 \
  --restart always \
  IMAGE
```

After changing `custom_data`, Terraform replaced the VM because VM custom data cannot be changed in place.

The recreated VM started correctly using the updated configuration.

## What I learned

This project gave me practical experience with:

- Terraform configuration
- Terraform state
- Terraform providers
- Terraform plan/apply/destroy workflow
- Infrastructure as Code
- Azure resource groups
- Azure regions
- Azure VM SKUs and quotas
- Azure virtual networks and subnets
- Network Security Groups
- Public and private IP addresses
- SSH access
- Linux virtual machines
- cloud-init
- Docker deployment
- Troubleshooting infrastructure across different layers

One of the main things I learned is that a successful infrastructure deployment depends on more than just valid Terraform syntax.

Azure policies, resource availability, quotas, networking, Terraform state and the application runtime can all affect the final result.

## Current status

V1 is complete.

The environment can be:

```text
created -> validated -> destroyed -> recreated -> validated
```

using Terraform without manually configuring the VM after deployment.
