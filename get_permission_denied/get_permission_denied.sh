#!/bin/bash
#export namespace_name=mvas
export count=0

for namespace_name in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
  for pod in $(kubectl get pods -n $namespace_name -o jsonpath='{.items[*].metadata.name}'); do
    #status=$(kubectl get pods $pod -n $namespace_name -o jsonpath='{.status.phase}')
    status=$(kubectl get pods $pod -n $namespace_name -o jsonpath='{.status.containerStatuses[].state.waiting.reason}')
    image=$(kubectl describe pod $pod -n $namespace_name | grep Image: | awk '{print $2}')

    count=$((count + 1))
    echo $count, $namespace_name, $pod >> ./pod_logs.txt
    if [ "$status" != "Running" ] && [ "$status" != "Completed" ]; then
      logs=$(kubectl logs --tail=10 $pod -n $namespace_name)
      if echo "$logs" | grep -q "Permission denied"; then
        echo $namespace_name, $image, $pod, $logs >> ./permission_denied.txt
      else
        continue
      fi
    fi
  done
done