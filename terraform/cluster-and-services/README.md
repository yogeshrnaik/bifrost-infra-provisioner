## To run locally

```bash
BACKEND_CONFIG_DIR=dev-ecs-workshop-asgard
```

NOTE: above can be changed as per cluster + env to test

```bash
terraform init -backend-config backend-configs/${BACKEND_CONFIG_DIR}/backend.config
terraform plan -var-file backend-configs/${BACKEND_CONFIG_DIR}/terraform.tfvars
```