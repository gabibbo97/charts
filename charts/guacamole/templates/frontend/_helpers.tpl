{{/*
Common labels
*/}}
{{- define "guacamole.labels.frontend" -}}
{{ include "guacamole.labels" . }}
app.kubernetes.io/component: frontend
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "guacamole.selectorLabels.frontend" -}}
{{ include "guacamole.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end -}}
