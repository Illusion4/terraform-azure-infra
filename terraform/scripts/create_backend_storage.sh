#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create_backend_storage.sh --resource-group <name> --location <azure-region> --storage-account <name> [--container <name>] [--subscription <id>]

Ensures the Terraform backend resource group, storage account, and blob container exist.
EOF
}

RESOURCE_GROUP=""
LOCATION=""
STORAGE_ACCOUNT=""
CONTAINER_NAME="tfstate"
SUBSCRIPTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--resource-group)
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    -l|--location)
      LOCATION="$2"
      shift 2
      ;;
    -a|--storage-account)
      STORAGE_ACCOUNT="$2"
      shift 2
      ;;
    -c|--container)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    -s|--subscription)
      SUBSCRIPTION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$RESOURCE_GROUP" || -z "$LOCATION" || -z "$STORAGE_ACCOUNT" ]]; then
  echo "--resource-group, --location, and --storage-account are required." >&2
  usage >&2
  exit 1
fi

if [[ -n "$SUBSCRIPTION" ]]; then
  az account set --subscription "$SUBSCRIPTION"
fi

echo "Ensuring resource group $RESOURCE_GROUP exists..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null

echo "Ensuring storage account $STORAGE_ACCOUNT exists..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 >/dev/null

ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' -o tsv)

echo "Ensuring blob container $CONTAINER_NAME exists..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --public-access off >/dev/null

echo "Terraform backend storage ready: rg=$RESOURCE_GROUP, account=$STORAGE_ACCOUNT, container=$CONTAINER_NAME"
