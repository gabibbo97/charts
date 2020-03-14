{{/*
Common labels
*/}}
{{- define "guacamole.labels.daemon" -}}
{{ include "guacamole.labels" . }}
app.kubernetes.io/component: guacd
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "guacamole.selectorLabels.daemon" -}}
{{ include "guacamole.selectorLabels" . }}
app.kubernetes.io/component: guacd
{{- end -}}
