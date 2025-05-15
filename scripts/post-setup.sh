source ../.env

# copy kubeconfig from server to local
scp $TF_VAR_vm_username@$vip:~/.kube/config ~/.kube/proxmox.yml

kubectx proxmox=default

kubectx proxmox
