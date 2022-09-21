#!/bin/bash -x

# Change these four parameters as needed
RESOURCE_GROUP=team-learning-session-2022-09
# STORAGE_ACCOUNT_NAME=keycloakexercise20220919 # initially used "keycloakexercise$RANDOM"
LOCATION=swedencentral
SHARE_NAME=keycloak-exercise-202209
LOG_ANALYTICS_WORKSPACE=keycloak-exercise-logs
POSTGRES_SERVER=keycloak-db-team-learning-2022-09
POSTGRES_ADMIN=teamlearning
POSTGRES_SKU=GP_Gen5_2

# ## Create resource group
# az group create \
#  --name $RESOURCE_GROUP \
#  --location $LOCATION

# # ## Create the storage account with the parameters
# # az storage account create \
# #    --resource-group $RESOURCE_GROUP \
# #    --name $STORAGE_ACCOUNT_NAME \
# #    --location $LOCATION \
# #    --sku Standard_LRS
# # #
# # ## Create the file share
# # az storage share create \
# #  --name $SHARE_NAME \
# #  --account-name $STORAGE_ACCOUNT_NAME

# # ## Fetch storage key
# # STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
# # echo STORAGE_KEY: $STORAGE_KEY

# ## Create log analytics workspace
# #az monitor log-analytics workspace create \
# #  --resource-group $RESOURCE_GROUP \
# #  --workspace-name $LOG_ANALYTICS_WORKSPACE
# #
# #LOG_WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys --resource-group $RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE --query "primarySharedKey" --output tsv)
# #echo LOG_WORKSPACE_KEY: $LOG_WORKSPACE_KEY

# # Create a PostgreSQL server in the resource group
# # Name of a server maps to DNS name and is thus required to be globally unique in Azure.
# echo "Creating $DB_SERVER in $LOCATION..."
# az postgres server create \
#   --name $POSTGRES_SERVER \
#   --resource-group $RESOURCE_GROUP \
#   --location "$LOCATION" \
#   --admin-user $POSTGRES_ADMIN \
#   --admin-password "$(cat .postgres-admin.passwd.txt)" \
#   --sku-name $POSTGRES_SKU \
#   --ssl-enforcement Disabled \
#   --version 11


# az postgres db create \
#   --name keycloak \
#   --resource-group $RESOURCE_GROUP \
#   --server-name $POSTGRES_SERVER \
#   --charset UTF8

# Create Keycloak container instance group
az container create \
  --resource-group $RESOURCE_GROUP \
  --file azure-cloud-instance.keycloak.yml

CONTAINER_IP=$(az container show \
  --resource-group $RESOURCE_GROUP \
  --name keycloak-exercise \
  --query ipAddress.ip \
  --out tsv )

az postgres server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server-name $POSTGRES_SERVER \
  --name AllowAzureContainer \
  --start-ip-address $CONTAINER_IP \
  --end-ip-address $CONTAINER_IP

# az container attach --resource-group $RESOURCE_GROUP --name keycloak-exercise --container-name caddy
# az container attach --resource-group $RESOURCE_GROUP --name keycloak-exercise --container-name keycloak
