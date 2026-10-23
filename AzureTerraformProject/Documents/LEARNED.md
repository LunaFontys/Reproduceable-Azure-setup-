**LEARNED**

What is terraform?

it is an IaC tool, It allows you to define cloud infrastructure as code through an configuration file rather then through a graphical interface.

It makes the IaC reusable and gives the same results every time you run it.

It makes teamwork seamless because the team can work on the same IaC file. With terraform cloud you can securely share the state with your teammates and you can connect Terraform cloud to GitHub.

**Configuration describes the desired infrastructure. State lets Terraform track which real Azure resources correspond to that configuration.**

I will use terraform to provision changes from my local machine by running the terraform docker container, authenticating using Azure CLI, and run terraform commands.



Deploying infrastrcuture with terraform roadmap:

1. Scope: Identify the infrastructure for the project
2. Author: Write configuration to define the infrastructure
3. Initialize: Install the required Terraform providers
4. Plan: Preview the changes Terraform will make
5. Apply: Make the changes to the infrastructure



