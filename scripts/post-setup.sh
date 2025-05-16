source ../.env
source ./clean-up-ssh-known-hosts.sh
# copy kubeconfig from server to local
scp $TF_VAR_vm_username@$vip:~/.kube/config ~/.kube/proxmox.yml
# scp $TF_VAR_vm_username@192.168.69.201:~/.kube/config ~/.kube/proxmox.yml

kubectx proxmox=default

kubectx proxmox
