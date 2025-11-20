#!/usr/bin/env bash

if ! command -v kubectl &>/dev/null; then
  cd /tmp || return 1
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  cd - || return 1

  mkdir -p ~/.kube/

  # Installing krew, a plugin manager for kubectl
  (
    set -x
    cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
  )
else
  echo "kubectl and krew is already installed."
fi

if ! command -v helm &>/dev/null; then
  cd /tmp || return 1
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  cd - || return 1
else
  echo "helm is already installed."
fi

if ! command -v kubectx &>/dev/null; then
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx || echo "Already cloned"
  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
else
  echo "kubectx is already installed."
fi

if ! command -v vault &>/dev/null; then
  PRODUCT=vault
  VERSION=1.21.0

  cd /tmp &&
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_linux_amd64.zip &&
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS &&
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig &&
    wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import &&
    gpg --verify ${PRODUCT}_${VERSION}_SHA256SUMS.sig ${PRODUCT}_${VERSION}_SHA256SUMS &&
    grep ${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS | sha256sum -c &&
    unzip /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip -d /tmp &&
    sudo mv /tmp/${PRODUCT} /usr/local/bin/${PRODUCT} &&
    rm -f /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS ${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig
else
  echo "vault is already installed."
fi
