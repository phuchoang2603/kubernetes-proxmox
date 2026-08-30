# RKE2 Kubernetes on Proxmox (archived)

This repository is an **archived learning snapshot**. It is no longer the live cluster.

**Successor:** [talos-proxmox](https://github.com/phuchoang2603/talos-proxmox) — Talos Linux on Proxmox with Terraform, GitHub Actions, and Vault (no Ansible / SSH).

Do not apply this stack against hosts that now run (or will run) the Talos cluster. VM IDs and IPs were intended to be reused after teardown.

---

This project automated an RKE2 Kubernetes cluster on Proxmox using Terraform and Ansible on GitHub Actions, with HashiCorp Vault for secrets and identity.

**Demo Video** (RKE2 era):

[![Demo Video](https://img.youtube.com/vi/G83csoZYCWQ/0.jpg)](https://youtu.be/G83csoZYCWQ)

## Motivation

This project began with a simple goal: create automatable scripts to spin up a Kubernetes cluster on Proxmox to learn more about its internals. Initially, I achieved this by running Terraform and Ansible from my laptop as a client.

However, one day, my laptop died. I lost all my local `.env` files, configurations, and `tfstate` files, forcing me to re-bootstrap everything from scratch.

That experience shifted the focus of this project. I realized that true infrastructure-as-code should not depend on a single machine. I decided to utilize **HashiCorp Vault** for centralized secret management, **GitHub Actions** for a portable CI/CD pipeline, and **MinIO** for remote Terraform state storage. This ensures the cluster can be managed, recovered, and scaled from anywhere, regardless of the local client's state.

Those patterns continue in [talos-proxmox](https://github.com/phuchoang2603/talos-proxmox).
