# Technical Decisions



This document contains the main technical decisions made during the project and why I made them.



### Linux compute environment



**Decision:** Use an Azure Linux VM.



The web application needs somewhere to run. A Linux VM gives me direct experience with Azure compute, Linux administration, networking, Docker and SSH while still keeping the infrastructure small.



### Infrastructure as Code



**Decision:** Use Terraform.



Terraform lets me describe the Azure infrastructure in configuration files instead of manually creating everything through the Azure Portal.



This makes it possible to destroy and recreate the environment from the same configuration.



### Terraform provider



**Decision:** Use the AzureRM provider.



A Terraform provider is a plugin that lets Terraform communicate with an external API.



The AzureRM provider gives Terraform the resource types needed to create and manage Azure infrastructure.



### Azure region



**Decision:** Use Poland Central.



I originally planned to use West Europe, but my Azure subscription has a policy restricting which regions I can use.



The allowed regions were:



\- Italy North

\- Poland Central

\- UAE North

\- France Central

\- Spain Central



France Central was tested first but the available VM sizes and subscription quotas made it difficult to find a suitable small VM.



Poland Central had a suitable B-series VM available within my subscription quota.



### VM size



**Decision:** Use `Standard\_B2ls\_v2`.



The application has very low expected traffic, so it does not need a large VM.



B-series VMs are suitable for smaller workloads and the selected VM gives enough resources to run Ubuntu, Docker and the web application without using a much larger VM than needed.



The choice was also affected by:



\- Region availability

\- Subscription restrictions

\- VM-family quota

\- Cost



### Network design



**Decision:**



```text

VNet:   10.0.0.0/22

Subnet: 10.0.1.0/24

```



The VNet defines the private address space for the Azure environment.



The subnet is a smaller network inside the VNet where the VM network interface is connected.



Azure reserves five IP addresses in each subnet.



The network is intentionally simple because the project only contains one VM.



### Public access



**Decision:** Give the VM a public IP and expose HTTP port 80.



The purpose of the project is to deploy a web application that can be accessed from outside Azure.



HTTP traffic on port 80 is therefore allowed from the internet.



HTTPS is outside the scope of V1.



### SSH access



**Decision:** Allow SSH on port 22 only from my own public IP.



SSH is the administrative interface for the VM and should not be open to the complete internet.



The NSG therefore allows:



```text

HTTP 80 → Internet

SSH 22  → My public IP only

```



Other inbound traffic is blocked by Azure's default NSG rules.



SSH uses a key instead of password authentication.



### NSG placement



**Decision:** Associate the Network Security Group with the VM's Network Interface.



The NSG contains the inbound rules for HTTP and SSH.



The NIC connects the VM to the subnet and has the NSG associated with it.



### Application deployment



**Decision:** Use Docker and Docker Hub.



The web application already has a Docker image.



Instead of copying application source code to the VM, cloud-init installs Docker and pulls a fixed application image from Docker Hub.



This keeps the infrastructure setup simple and separates the application image from the infrastructure configuration.



### Automatic VM setup



**Decision:** Use cloud-init.



Terraform creates the VM and passes a cloud-init startup script using `custom\_data`.



The script:



1\. Updates package information.

2\. Installs Docker.

3\. Enables and starts Docker.

4\. Pulls the application image from Docker Hub.

5\. Starts the container.



The application listens on port `3000` inside the container.



Docker exposes it using:



```text

VM port 80 → container port 3000

```



### Terraform variables



**Decision:** Use variables for machine-specific values.



Values such as:



\- My public IP

\- SSH public key path

\- Docker image



are supplied through Terraform variables.



Local values are stored in `terraform.tfvars`, which is ignored by Git.



The SSH private key is never stored in Terraform.



### Terraform state



Terraform configuration describes the desired infrastructure.



Terraform state keeps track of which real Azure resources correspond to the resources in the configuration.



State files are kept out of Git because they can contain infrastructure information and potentially sensitive values.



For this small local project I use local state.



### Validation



**Decision:** Validate both Terraform and the running infrastructure.



Terraform validation includes:



```text

terraform fmt

terraform validate

terraform plan

```



The deployed infrastructure is tested separately using:



\- Azure CLI

\- SSH

\- `Test-NetConnection`

\- `curl`

\- `cloud-init status`

\- `docker ps`



This is important because a successful `terraform apply` does not automatically prove that the application itself works.



### Cost



**Decision:** Keep the infrastructure as small as possible.



The project only needs one VM and basic Azure networking.



No database, load balancer, Kubernetes cluster or other unnecessary services are used in V1.



The environment can also be destroyed when it is not needed.

