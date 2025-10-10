resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-${var.env}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.address_space]
  location            = azurerm_resource_group.rg.location

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      address_space,
    ]
  }
}

resource "azurerm_subnet" "sb" {
  count                = var.subnet_count
  name                 = "${var.name}-subnet-${count.index}-${var.env}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.source_range, var.subnet_prefix_length, count.index)]
  #enforce_private_link_endpoint_network_policies = var.iaas_subnet_enforce_private_link_endpoint_network_policies

  lifecycle {
    ignore_changes = [
      address_prefixes,
      service_endpoints,
    ]
  }
}

resource "azurerm_subnet" "additional_subnets" {
  for_each             = var.addtional_subnets
  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  lifecycle {
    ignore_changes = [
      address_prefixes,
      service_endpoints,
    ]
  }
}
