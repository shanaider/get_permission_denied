#!/bin/bash
#export namespace_name=mooc
export count=0

for namespace_name in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
  for pod in $(kubectl get pods -n $namespace_name  --no-headers |egrep -v "Running | Completed" | awk '{print $1}'); do
    image=$(kubectl describe pod $pod -n $namespace_name | grep Image: | awk '{print $2}')
    # echo $pod
    # echo $image
    count=$((count + 1))
    echo $count, $namespace_name, $pod >> ./pod_logs.txt
    
    logs=$(kubectl logs --tail=10 $pod -n $namespace_name)
    if echo "$logs" | grep -q "Permission denied"; then
      echo $namespace_name, $image, $pod, $logs >> ./permission_denied.txt
    fi

  done
done