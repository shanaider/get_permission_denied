#!/bin/bash
export namespace_name=kube-system
export count=0

#for namespace_name in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
  for pod in $(kubectl get pods -n $namespace_name  --no-headers |grep "Running" | awk '{print $1}'); do
    image=$(kubectl describe pod $pod -n $namespace_name | grep Image: | awk '{print $2}')
    # echo $pod
    # echo $image
    count=$((count + 1))
    exec=$(kubectl exec -ti $pod -n $namespace_name -- head -n 1 /etc/issue)

    if echo $exec |grep -q "Alpine Linux"; then
      echo $count, $namespace_name, $pod, $exec  >> ./get_alpine_version.log
    else
      echo $count, $namespace_name, $pod, $exec  >> ./get_os_version.log
    fi

  done
#done