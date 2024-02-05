## Provision Linux based VMs using Terraform

Create a `users.tfvars` file containing your users details (name, password, SSH key),
and also define, if needed, the OS image, the hardware specs and the network config of the VMs.
See *.example files for details

Plan:
```
terraform plan -var-file users.tfvars
```

Apply:
```
terraform apply -var-file users.tfvars
```

Destroy:
```
terraform destroy -var-file users.tfvars
```

The code generates an ansible inventory file in `ansible/inventory/hosts` that can be used to manage the VMs:

```
cd ansible
ansible-playbook os_info.yml
```

