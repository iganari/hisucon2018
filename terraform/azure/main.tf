### Resource Groups 
resource "azurerm_resource_group" "vm_arg" {
    name     = "${var.resource_groups_name}"
    location = "${var.resource_groups_location}"    
    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}


### Create virtual network
resource "azurerm_virtual_network" "vm_avn" {
    name                = "${var.vnet_name}"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.vm_location}"
    resource_group_name = "${azurerm_resource_group.vm_arg.name}"

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}

### Create subnet
resource "azurerm_subnet" "vm_as_01" {
    name                 = "${var.subnet_name}_01"
    resource_group_name  = "${azurerm_resource_group.vm_arg.name}"
    virtual_network_name = "${azurerm_virtual_network.vm_avn.name}"
    address_prefix       = "10.0.1.0/24"
}
resource "azurerm_subnet" "vm_as_02" {
    name                 = "${var.subnet_name}_02"
    resource_group_name  = "${azurerm_resource_group.vm_arg.name}"
    virtual_network_name = "${azurerm_virtual_network.vm_avn.name}"
    address_prefix       = "10.0.11.0/24"
}



### Create public IPs ###
resource "azurerm_public_ip" "vm_api" {
    name                         = "${var.publicip_name}"
    location                     = "${var.vm_location}"
    resource_group_name          = "${azurerm_resource_group.vm_arg.name}"
    public_ip_address_allocation = "dynamic"
    domain_name_label            = "${var.dnslabel_name}"

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}


### Create Network Security Group and rule
resource "azurerm_network_security_group" "vm_ansg" {
    name                = "${var.nsgroup_name}"
    location            = "${var.vm_location}"
    resource_group_name = "${azurerm_resource_group.vm_arg.name}"

    security_rule = [
        {
            name                       = "AllowHTTPBound"
            priority                   = 1001
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "80"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        },
        {
            name                       = "AllowNodeRedBound"
            priority                   = 1002
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "1880"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        },
        {
            name                       = "AllowSSHBound"
            priority                   = 1003
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        }
    ]

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}


### Create network interface
resource "azurerm_network_interface" "vm_ani" {
    name                      = "${var.nwintf_name}"
    location                  = "${var.vm_location}"
    resource_group_name       = "${azurerm_resource_group.vm_arg.name}"
    network_security_group_id = "${azurerm_network_security_group.vm_ansg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.vm_as_01.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.vm_api.id}"
    }

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}

### Generate random text for a unique storage account name
resource "random_id" "vm_ri" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.vm_arg.name}"
    }

    byte_length = 8
}

### Create storage account for boot diagnostics
resource "azurerm_storage_account" "vm_asa" {
    name                        = "diag${random_id.vm_ri.hex}"
    resource_group_name         = "${azurerm_resource_group.vm_arg.name}"
    location                    = "${var.vm_location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}


### Create virtual machine
resource "azurerm_virtual_machine" "vm_avm" {
    name                  = "${var.vm_name}"
    location              = "${var.vm_location}"
    resource_group_name   = "${azurerm_resource_group.vm_arg.name}"
    network_interface_ids = ["${azurerm_network_interface.vm_ani.id}"]
    vm_size               = "${var.vm_size}"

    storage_os_disk {
        name              = "${var.disk_name}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "${var.image_reference_publisher}"
        offer     = "${var.image_reference_offer}"
        sku       = "${var.image_reference_sku}"
        version   = "${var.image_reference_version}"
    }

    os_profile {
        computer_name  = "${var.os_hostname}"
        admin_username = "${var.os_username}"
        # admin_password = "Password1234!"
    }

    os_profile_linux_config {
        # disable_password_authentication = false
        disable_password_authentication = true
        ssh_keys {
            # source data
            key_data = "${var.os_userpublickey}"
            # destination path
            path     = "/home/${var.os_username}/.ssh/authorized_keys"
        }
    }

    # boot_diagnostics {
    #     enabled = "true"
    #     storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    # }

    tags {
        maintainer  = "${var.maintainer}"
        description = "${var.description}"
    }
}
