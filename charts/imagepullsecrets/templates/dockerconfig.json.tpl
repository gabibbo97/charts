{{- define "imagepullsecrets.dockerconfigjson" }}
{
  "auths" : {
    {{ .registryURL | quote }} : {
      "Username" : {{ .username | quote }},
      "Password" : {{ .password | quote }}
    }
  }
}
{{- end }}
{{- define "imagepullsecrets.dockerconfigjson-with-auth" }}
{
  "auths" : {
    {{ .registryURL | quote }} : {
      "Username" : {{ .username | quote }},
      "Password" : {{ .password | quote }},
      "auth" : {{ printf "%s:%s" .username .password | b64enc | quote }}
    }
  }
}
{{- end }}
