**OVERVIEW**



**GOAL:**

Design and create an Azure environment that can be **created**, **changed** and **destroyed** reproducibly from **code**



**DEFINITION OF DONE:**

* Starting from your repository, 
* you can provision the Azure environment with Terraform, 
* access the deployed application as intended, 
* demonstrate that inappropriate access is restricted,
* destroy the environment, 
* recreate it, 
* and explain the important architectural choices yourself.





**REQUIREMENTS:**

Linux compute environment

Azure networking

controlled inbound network access

public access to the web application

Secure administrative access

Using terraform

Environment should be destroyable and recreatable



**POSSIBLE RESOURCES:**

resource group, VNet, subnet, public IP, NSG, NIC and Linux VM



**Tasks:**

Research Azure and what type of Azure environment to make for this project, Azure regions?

Setup git repo



Get the web application

local machine → Terraform container → authenticate to Azure → Terraform creates Resource Group/VNet/Subnet/NSG/NIC/Public IP/VM → then deploy the web app onto the VM

decide how the application is hosted and exposed --> 

Make the Git Repo README

