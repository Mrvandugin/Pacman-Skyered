provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-tom-vanduijn"
  location = "West Europe"
}

resource "azurerm_public_ip" "example" {
  name                = "pacman-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_subnet" "example" {
  name                 = "pacman-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "example" {
  name                = "pacman-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_network_security_group" "example" {
  name                = "pacman-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_network_interface" "example" {
  name                = "pacman-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "pacman-nic-configuration"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "tls_private_key" "example_ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_virtual_machine" "example" {
  name                  = "pacman-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B2s"

  os_profile {
    computer_name  = "pacmanvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = tls_private_key.example_ssh.public_key_openssh
    }
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

resource "local_file" "private_key" {
  filename = "C:/users/tvdui/pacman-key.pem"
  content  = tls_private_key.example_ssh.private_key_pem
}

# so könnte mann vielleicht in verbindung komt mit den cluster
# Datenquelle für den vorhandenen Kubernetes-Cluster
#data "external" "kubeconfig" {
#  program = ["bash", "-c", "kubectl config view --minify --flatten --kubeconfig=/K8s/kubeconfig.yaml"]
#}

# Kubernetes-Konfigurationsdatei in der VM speichern
#resource "azurerm_virtual_machine_extension" "example" {
#  name                 = "k8s-config"
#  virtual_machine_id   = azurerm_virtual_machine.example.id
#  publisher            = "Microsoft.Azure.Extensions"
#  type                 = "CustomScript"
#  type_handler_version = "2.1"

#  settings = <<SETTINGS
#    {
#      "commandToExecute": "echo '${data.external.kubeconfig.result}' > /home/adminuser/.kube/config"
#    }
#SETTINGS

#  depends_on = [data.external.kubeconfig]
#}
