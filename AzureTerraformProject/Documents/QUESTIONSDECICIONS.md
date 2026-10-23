**QUESTIONS/DECICIONS**



What is a Linux compute environment in an Azure infrastructure project?

for this project basically the VM on which the web application will run.



What is a network/address-space design in an Azure project?

the architectural plan for assigning private IP address ranges using VNet and subnets. Basically: what networks and subnets are there and what ip addresses are allocated to them. The CIDR block (or parent block) is all of the allocated ip addresses for the Vnet (10.0.0.0/24 for example). Choosing an CIDR block comes down to choosing what private IP range is most useful for the project. The most common range is 10.0.0.0 since it has a large range and most cloud networks start there. The numbers after the / is the CIDR mask, this will determine how many IP addresses are in the CIDR block. The smaller the CIDR mask number the higher the IP addresses. With terraform I can change the CIDR block by using a variable for it and changing that variable when I deploy. Azure reserves five IP addresses per subnet





What are terraform providers?

A Terraform provider is a plugin that lets Terraform interact with APIs for platforms such as Azure and exposes resource/data types Terraform can manage.





Which Azure region to use?

West Europe is close to the expected user/administrator location, supports the resources I intend to use, and avoids introducing unnecessary latency or region complexity.





What is the network/address-space design?

See diagram.





Which inbound traffic is allowed?

Since the webapp will run on a Linux VM I will need to allow restricted access for port 22 to manage the webapp. The port the webapp is listening on needs to allow inbound traffic from the public internet.





How should SSH access be restricted?

Yes since SSH via port 22 is the admin interface to the server and it has administrator privileges. I will use an SSH key. I will have to use a NSG where I will write the exact rules where port 22 will only be allowed from my IP, port 80 or the port where the webapp is listening will be publically allowed and all other traffic will be denied.





Which Linux VM size makes sense:

Azure has B-series and D-series VMs. The B series stands for (or has) a burstable CPU. This is wanted for this project since the webapp will have very low traffic and we want to keep the costs low. I will use Standard\_B2s VM sizing where the webapp containter will run. I will choose this if cost is reasonable in my region.



How does the application get onto the VM and how does it run on the VM:

I will use cloud-init to run a git repo with the webapp code in it on startup of the server



What useful information should terraform expose as outputs:

The entrypoints of the webapp to access it in browser. management access to configure the server.



How do I prevent sensitive/local terraform files from entering Git:

Using .gitignore. I can put the actual secret values in a file and block that file with .gitignore and use variables in the terraform files for the secrets.



How do I validate that the network restrictions work:

In my case I will probably just use CLI probing to see if the port connection is public/private depending on the way I want it.



How do I keep the Azure costs low:

For this project I currently only need Azure to host the VM I think and for all other possbile extra services I will either not use them or use the free option.



