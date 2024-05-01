# Get image artifacts - https://docs.rke2.io/install/airgap#tarball-method
mkdir -p /var/lib/rancher/rke2/agent/images/ && cd /var/lib/rancher/rke2/agent/images/
echo "Downloading rke2-images-core.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images-core.linux-amd64.tar.zst"
echo "Downloading rke2-images-canal.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images-canal.linux-amd64.tar.zst"

mkdir -p /root/uds-rke2-artifacts/install && cd /root/uds-rke2-artifacts/install/
echo "Downloading rke2-images.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images.linux-amd64.tar.zst"
echo "Downloading rke2.linux-amd64.tar.gz..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2.linux-amd64.tar.gz"
echo "Downloading sha256sum-amd64.txt..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/sha256sum-amd64.txt"
curl -sfL https://get.rke2.io --output install.sh

# TODO: move to a directory in Zarf package