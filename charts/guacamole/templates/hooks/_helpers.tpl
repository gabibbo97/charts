{{/*
Common labels
*/}}
{{- define "guacamole.labels.hook" -}}
{{ include "guacamole.labels" . }}
app.kubernetes.io/component: hook
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "guacamole.selectorLabels.hook" -}}
{{ include "guacamole.selectorLabels" . }}
app.kubernetes.io/component: hook
{{- end -}}
