# -------------------------
# Check & install kubectl
# -------------------------
if ! command -v kubectl &>/dev/null; then
  echo "❗ kubectl not found. Installing..."
  cd /tmp
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  cd -
else
  echo "✅ kubectl is already installed."
fi

# -------------------------
# Check & install helm
# -------------------------
if ! command -v helm &>/dev/null; then
  echo "❗ helm not found. Installing..."
  cd /tmp
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  cd -
else
  echo "✅ helm is already installed."
fi

# -------------------------
# Check & install kubectx
# -------------------------
if ! command -v kubectx &>/dev/null; then
  echo "❗ kubectx not found. Installing..."
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx || echo "Already cloned"
  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
else
  echo "✅ kubectx is already installed."
fi
