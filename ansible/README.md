# Ansible Kubernetes Cluster Automation (RKE2)

Automate the installation and configuration of an RKE2 Kubernetes cluster using **Ansible**.

---

## 🔗 Resources

- [Video Series (YouTube)](https://www.youtube.com/watch?v=AnYmetq_Ekc&list=PLXHMZDvOn5sW-EXm2Ur5TroSatW-t0Vz_&index=8)
- [JimsGarage Ansible Playbooks (GitHub)](https://github.com/JamesTurland/JimsGarage/tree/main/Ansible/Playbooks/RKE2)

---

## 🛠 Steps

1. **Create Python virtual environment and install dependencies**

   ```bash
   uv venv
   source .venv/bin/activate
   uv add ansible pyyaml
   ```

2. **Generate Ansible inventory from your `k8s_nodes.json`**

   ```bash
   ./gen_ansible_host.py -j ../k8s_nodes.json -o inventory/hosts.ini
   # ✅ Inventory generated at inventory/hosts.ini
   ```

3. **Sync environment variables to Ansible group variables**

   ```bash
   ./sync_ansible_env.py -e ../.env -y inventory/group_vars/all.yaml
   # ✅ Updated inventory/group_vars/all.yaml with mapped variables from ../.env
   ```

4. Run the Ansible playbook to install RKE2 on all nodes:

   ```bash
   ansible-playbook site.yaml
   ```

---

## ⚙ Configuration Notes

- Ensure:

  - Nodes have **unique hostnames** (essential for Kubernetes to work properly).
  - The `add-server` and `rke2-prepare` tasks are **adjusted to your desired server count and roles** (currently hardcoded to 3 servers, recommend making it dynamic).

- Review and adjust variables in:

  - `inventory/hosts.ini`
  - `inventory/group_vars/all.yaml`

---

## 📷 Example Output

![](https://i.imgur.com/PjzbAUi.png)
