# Create the resource group
resource "azurerm_resource_group" "project_rg" {
  name = "rg-AzureTerraformProject"
  location = "polandcentral"
}

# Create the Virtual Network
resource "azurerm_virtual_network" "project_vnet" {
  name = "vnet-AzureTerraformProject"
  address_space = ["10.0.0.0/22"]
  location = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name
}

# Create the Subnet inside the network
resource "azurerm_subnet" "project_subnet" {
  name = "internal-subnet"
  resource_group_name = azurerm_resource_group.project_rg.name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

# Create the Network Security Group
resource "azurerm_network_security_group" "project_nsg" {
  name = "nsg-AzureTerraformProject"
  location = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name

  # Allow public HTTP traffic
  security_rule {
    name = "Allow-HTTP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH only from your public IP
  security_rule {
    name = "Allow-SSH"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = var.my_public_ip
    destination_address_prefix = "*"
  }
}

# Create a Standard public IP
resource "azurerm_public_ip" "project_pip" {
  name = "pip-AzureTerraformProject"
  location = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name

  allocation_method = "Static"
  sku = "Standard"
}

# Create the Network Interface Card for the VM
resource "azurerm_network_interface" "project_nic" {
  name = "nic-AzureTerraformProject"
  location = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.project_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.project_pip.id
  }
}

# Connect the NSG to the VM network interface
resource "azurerm_network_interface_security_group_association" "connect_nsg" {
  network_interface_id = azurerm_network_interface.project_nic.id
  network_security_group_id = azurerm_network_security_group.project_nsg.id
}

# Create the Linux VM
resource "azurerm_linux_virtual_machine" "webapp_vm" {
  name = "vm-AzureTerraformProject"
  resource_group_name = azurerm_resource_group.project_rg.name
  location = azurerm_resource_group.project_rg.location
  size = "Standard_B2ls_v2"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.project_nic.id
  ]

  admin_ssh_key {
    username = "azureuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y docker.io

    systemctl enable --now docker

    docker pull ${var.docker_image}

    docker run \
      -d \
      --name webapp \
      -p 80:3000 \
      --restart always \
      ${var.docker_image}
  EOF
  )
}