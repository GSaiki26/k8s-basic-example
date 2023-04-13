# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/

# Env
LOAD_BALANCE_URI=""
LOAD_BALANCE_PORT=6443
NODE_MASTER_URI=""
NODE_MASTER_PORT=6443

# Load balance
'''
frontend source
    mode tcp
    bind ${LOAD_BALANCE_URI}:${LOAD_BALANCE_PORT}
    option tcplog
    default_backend masters

backend masters
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 ${NODE_MASTER_URI}:${NODE_MASTER_PORT} check fall 3 rise 2
'''
systemctl restart haproxy

# * Both
# Check if the load balancer is available
nc -v ${LOAD_BALANCE_URI} ${LOAD_BALANCE_PORT}

# Install the kubeadm
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl docker
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# * Master
# Create the cluster and get the kubeadm join command.
kubeadm init -control-plane-endpoint "${LOAD_BALANCE_URI}" --upload-certs

# Install the CNI ( Container Network Interface )
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# If need to get the token again:
kubeadm token list
kubeadm token create <copied token> --print-join-command

# Run the project on worker node.
docker build -t simple-server .
kubectl apply -f deployment.yaml

# * Worker
# Get the full command above
kubeadm join --token
