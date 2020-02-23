{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fcgi-nginx-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fcgi-nginx-frontend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fcgi-nginx-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fcgi-nginx-frontend.labels" -}}
helm.sh/chart: {{ include "fcgi-nginx-frontend.chart" . }}
{{ include "fcgi-nginx-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "fcgi-nginx-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fcgi-nginx-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fcgi-nginx-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "fcgi-nginx-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "fcgi-nginx-frontend.fastcgi-params" }}
{{- range $k, $v := .Values.fastcgiParams }}
  fastcgi_param {{ $k }} {{ $v }};
{{- end }}
{{- end }}

{{- define "fcgi-nginx-frontend.nginx-conf" }}
daemon off;
events {
  worker_connections 2048;
}
http {
  server {
    listen 8080;
    location /healthz {
      return 200 'OK';
    }
  }
  server {
    listen 80;
    {{- .Values.serverBlock | replace "<FCGI_BACKEND>" (printf "fastcgi_pass %s;" .Values.fastcgiBackend) | replace "<FCGI_INDEX>" (printf "fastcgi_index %s;" .Values.fastcgiIndex) | replace "<FCGI_PARAMS>" (include "fcgi-nginx-frontend.fastcgi-params" .) | indent 4 }}
  }
}
{{- end }}
