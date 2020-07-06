#!/bin/bash

multipass delete k8s-master k8s-worker-1 k8s-worker-2
multipass purge

echo "#"
echo "# - Createing master control plane"
echo "#"
multipass launch -c 2 -m 2G -n k8s-master 18.04
multipass copy-files bootstrap-master.sh k8s-master:
multipass exec k8s-master -- chmod +x bootstrap-master.sh
multipass exec k8s-master -- sh bootstrap-master.sh


for worker in 1 2
do
    echo "#"
    echo "# - Creating woker node ${worker}"
    echo "#"
    multipass launch -c 2 -m 2G -n k8s-worker-${worker} 18.04
    multipass copy-files bootstrap-worker.sh k8s-worker-${worker}:
    multipass copy-files k8s-master:/home/ubuntu/join_script.sh .
    multipass copy-files join_script.sh k8s-worker-${worker}:
    
    multipass exec k8s-worker-${worker} -- chmod +x bootstrap-worker.sh
    multipass exec k8s-worker-${worker} -- chmod +x join_script.sh
    multipass exec k8s-worker-${worker} -- sh bootstrap-worker.sh
    multipass exec k8s-worker-${worker} -- sh join_script.sh
    echo "# - Done "
done

multipass copy-files k8s-master:/home/ubuntu/.kube/config ./k8s.conf


