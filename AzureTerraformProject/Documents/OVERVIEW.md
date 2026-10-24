# Project Overview

### Goal

Design and create a small Azure environment that can be created, changed and destroyed reproducibly from code using Terraform.

The environment should host an existing Dockerized web application on a Linux VM and expose it to the internet.

The main focus of the project is learning Azure and Infrastructure as Code, not developing the web application itself.



### Definition of Done

The project is done when:

* The Azure environment can be provisioned from the repository using Terraform.
* The web application is reachable from the public internet.
* Administrative SSH access is restricted to my public IP.
* Unnecessary inbound traffic is blocked.
* The VM configures itself automatically after creation.
* The environment can be destroyed using Terraform.
* The complete environment can be recreated without manually configuring the VM.
* I can explain the important infrastructure and networking decisions.



### Requirements

* Linux compute environment
* Azure networking
* Controlled inbound network access
* Public access to the web application
* Secure SSH administration
* Terraform for provisioning
* Automatic VM setup
* Dockerized application deployment
* Environment must be destroyable and reproducible



### Final Infrastructure

The project uses:

* Azure Resource Group
* Virtual Network
* Subnet
* Network Security Group
* Public IP
* Network Interface
* Ubuntu Linux VM
* Docker
* cloud-init
* Docker Hub



**Network**:

VNet:   10.0.0.0/22

Subnet: 10.0.1.0/24



**Azure region**:

Poland Central



**VM**:

Standard\_B2ls\_v2

Ubuntu Server 22.04 LTS



### Deployment Flow

Local machine

&#x20;   ↓

Terraform

&#x20;   ↓

Azure API

&#x20;   ↓

Resource Group

&#x20;   ↓

VNet + Subnet

&#x20;   ↓

NSG + Public IP + NIC

&#x20;   ↓

Ubuntu VM

&#x20;   ↓

cloud-init

&#x20;   ↓

Docker

&#x20;   ↓

Docker Hub image

&#x20;   ↓

Web application



Terraform is run locally and authenticated to Azure using Azure CLI.



When the VM starts, cloud-init installs Docker, pulls the application image from Docker Hub and starts the application container.



The application listens on port 3000 inside the container and Docker maps VM port 80 to container port 3000.



### Validation

The project was validated by:

* Running terraform plan and checking the planned infrastructure.
* Running terraform apply.
* Checking the Azure resources.
* Connecting to the VM using SSH.
* Checking cloud-init completed successfully.
* Checking the Docker container was running.
* Testing the application locally from the VM.
* Testing HTTP access from outside Azure.
* Running terraform destroy.
* Recreating the complete environment with terraform apply.
* Validating the recreated environment again.

The destroy and recreate test completed successfully without manually configuring the recreated VM.



