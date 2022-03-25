## Provision Debian based VMs using Terraform

Create a `user.tfvars` file containing you user details (name, password, SSH key).

Define the number, the hardware specs and the network config of the VMs in `variables.tf`


Plan:
```
terraform plan -var-file user.tfvars
```

Apply:
```
terraform apply -var-file user.tfvars
```

Destroy:
```
terraform destroy -var-file user.tfvars
```

The code generates an ansible inventory file in `ansible/inventory/hosts` that can be used to manage the VMs:

```
cd ansible
ansible-playbook os_info.yml
```

