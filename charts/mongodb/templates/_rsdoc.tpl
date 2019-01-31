{{- define "mongodb-configsvr-rsdoc" }}
rs.initiate({
  "_id" : "ConfigRS",
  "configsvr" : true,
  "members" : [
    {{- range $i, $e := until (int $.Values.topology.configServers) }}
    {{- if ne $i 0 }},{{ end }}
    { "_id": {{ $i }}, "host" : "{{ include "mongodb.fullname" $ }}-configsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-configsvr.{{ $.Release.Namespace }}.svc.cluster.local:27019" }
    {{- end }}
  ]
})
{{- end }}
{{- define "mongodb-shardsvr-rsdoc" }}
rs.initiate({
  "_id" : "Shard<<I>>RS",
  "members" : [
    {{- range $i, $e := until (int $.Values.topology.shards.servers) }}
    {{- if ne $i 0 }},{{ end }}
    { "_id": {{ $i }}, "host" : "{{ include "mongodb.fullname" $ }}-shard-<<I>>-shardsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-shard-<<I>>-shardsvr.{{ $.Release.Namespace }}.svc.cluster.local:27018" }
    {{- end }}
  ]
})
{{- end }}
{{- define "mongodb-shardsvr-sharddoc" -}}
{{- range $i, $e := until (int .Values.topology.shards.servers) -}}
{{- if ne $i 0 -}},{{ end }}
{{ include "mongodb.fullname" $ }}-shard-<<I>>-shardsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-shard-<<I>>-shardsvr.{{ $.Release.Namespace }}.svc.cluster.local:27018
{{- end -}}
{{- end -}}