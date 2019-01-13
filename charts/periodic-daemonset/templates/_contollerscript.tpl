{{- define "periodic-daemonset.script" }}
NODE_COUNT=0
for node in $(kubectl get node -o jsonpath='{ range .items[*] }{.metadata.name }{" "}{ end }')
do
  printf "Scheduling JOB on node %s\n" "$node"
  sed -e "s/<<NODE_NAME>>/$node/g" < /etc/periodic-daemonset-data/job.yaml
  sed -e "s/<<NODE_NAME>>/$node/g" < /etc/periodic-daemonset-data/job.yaml | kubectl apply -f -
  NODE_COUNT=$(( NODE_COUNT + 1 ))
done

TIMEOUT=600
while true
do
  COMPLETIONS=0
  for job in $(kubectl -n {{ .Release.Namespace }} get jobs --selector="app.kubernetes.io/name={{ include "periodic-daemonset.name" . }},app.kubernetes.io/instance={{ .Release.Name }},app.kubernetes.io/component=job" -o jsonpath='{ range .items[*] }{.metadata.name }{" "}{ end }')
  do
    printf "Job instance %s\n" "$job"
    if [ -z "$(kubectl -n {{ .Release.Namespace }} get job $job -o jsonpath='{.status.completionTime}')" ]
    then
      printf "NOT FINISHED\n"
    else
      COMPLETIONS=$(( COMPLETIONS + 1 ))
    fi
  done

  TIMEOUT=$(( TIMEOUT - 1 ))
  if [ $COMPLETIONS -eq $NODE_COUNT ]
  then
    printf "Jobs terminated\n"
    break
  fi
  if [ $TIMEOUT -eq 0 ]
  then
    printf "timed out!\n"
    exit 1
  fi
done

printf "Cleaning up...\n"
kubectl -n {{ .Release.Namespace }} delete jobs,pods --selector="app.kubernetes.io/name={{ include "periodic-daemonset.name" . }},app.kubernetes.io/instance={{ .Release.Name }},app.kubernetes.io/component=job"
{{- end }}
