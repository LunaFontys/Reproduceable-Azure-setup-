# What I Learned



### Terraform



Terraform is an Infrastructure as Code tool.



Instead of manually creating infrastructure through a graphical interface, infrastructure can be described using configuration files.



The basic workflow I used was:



1\. **Scope** – Decide what infrastructure is needed.

2\. **Author**– Write the Terraform configuration.

3\. **Initialize** – Download the required providers with `terraform init`.

4**. Validate** – Check formatting and configuration.

5**. Plan** – Preview what Terraform wants to change.

6\. **Apply** – Create or change the infrastructure.

7\. **Validate the real environment** – Check that the deployed infrastructure actually works.

8**. Destroy**  – Remove the infrastructure when it is no longer needed.



### Configuration and State



Terraform configuration describes the infrastructure I want.



Terraform state keeps track of which actual Azure resources belong to the resources in the Terraform configuration.



I saw why this matters when Azure successfully created my subnet but the AzureRM provider returned an inconsistent result before Terraform saved the subnet in its state.



Azure had the subnet, but Terraform did not know about it.



I fixed this by confirming the resource existed in Azure and importing it into Terraform state.



This made the difference between the Terraform configuration, Terraform state and the actual cloud infrastructure much clearer to me.



### Terraform Providers



A Terraform provider is a plugin that lets Terraform communicate with another platform's API.



For this project I used the AzureRM provider to create Azure resources.



I also learned that a provider can have its own problems even when the Terraform configuration itself is correct.



### Azure regions are not just a preference



I originally thought choosing a region would mainly be about things like distance and latency.



During this project I learned that the subscription can also have Azure Policies that restrict which regions can be used.



My subscription only allowed a small set of regions, so the original region could not be used.



### VM availability and quota are different



One of the biggest things I learned was that seeing a VM size in Azure does not mean I can actually deploy it.



There are multiple separate restrictions:



\- The region must be allowed.

\- The VM SKU must exist in that region.

\- The VM SKU must be available to my subscription.

\- The VM family needs enough quota.



I ran into all of these while trying to find a suitable small VM.



I used Azure CLI commands such as:



```text

az vm list-skus

az vm list-usage

```



to compare availability and quota.



### Azure networking



I learned the relationship between:



```text

VNet

└── Subnet

&#x20;   └── NIC

&#x20;       └── VM

```



The NIC gives the VM its network connection and private IP.



The public IP is connected through the NIC configuration.



The NSG can be associated with the NIC and controls which inbound traffic is allowed.



### Public and private IP addresses



I originally used the IPv4 address shown by `ipconfig` for my SSH NSG rule.



That was my private IP inside my home network.



Azure sees my public IP after the traffic passes through my router, so the NSG rule needed my public IP instead.



This helped me understand the difference between local/private addressing and the public address seen by an external service.



### Network Security Groups



For this project I allowed:



```text

HTTP 80 → Internet

SSH 22  → My public IP only

```



I learned that I did not need to manually create an extra deny rule for everything else because Azure NSGs already contain default inbound deny behaviour.



### cloud-init



cloud-init can configure a new Linux VM automatically when it starts.



For this project it installs Docker, starts Docker, pulls my application image and runs the application container.



Changing the VM `custom\_data` caused Terraform to replace the VM because that value cannot simply be changed on the existing VM through this Terraform resource.



### Docker port mapping



I made a mistake where the container was started using:



```text

80:8080

```



but the application actually listens on port `3000`.



Docker showed that the container was running, but the application still could not be reached.



The correct mapping was:



```text

80:3000

```



This helped me understand that a running container does not automatically mean the service is reachable.



### Troubleshooting layer by layer



One of the most useful things I learned was to troubleshoot the infrastructure in layers.



For example, when the application was not reachable I checked:



1\. Is the VM running?

2\. Can I reach SSH?

3\. Did cloud-init finish?

4\. Is Docker running?

5\. Is the container running?

6\. Does `curl localhost` work on the VM?

7\. Is port 80 reachable from my own PC?

8\. Does external HTTP return the application?



This was much more useful than changing Terraform configuration immediately whenever something did not work.



### Reproducibility



The final test was destroying the complete Azure environment and recreating it from Terraform.



After recreation:



\- The Azure resources were created.

\- The VM started.

\- cloud-init installed Docker.

\- Docker pulled the application.

\- The container started automatically.

\- SSH worked.

\- The application was reachable externally.



This proved that the environment was reproducible instead of only being one manually repaired deployment.

