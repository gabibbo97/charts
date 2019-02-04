{{- define "mongodb.configrs" }}
{
  "_id" : "ConfigRS",
  "configsvr" : true,
  "members" : [
    {{- range $i, $e := until (int .Values.topology.configServers) }}
    {{- if ne 0 $i }},{{ end }}
    {
      "_id" : {{ $i }},
      "host" : "{{ include "mongodb.fullname" $ }}-configsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-configsvr.{{ $.Release.Namespace }}.svc.cluster.local:27019"
    }
    {{- end }}
  ]
}
{{- end }}

{{- define "mongodb.shardrs" }}
{
  "_id" : "Shard${SHARD_INDEX}RS",
  "members" : [
    {{- range $i, $e := until (int .Values.topology.shards.servers) }}
    {{- if ne 0 $i }},{{ end }}
    {
      "_id" : {{ $i }},
      "host" : "{{ include "mongodb.fullname" $ }}-shard-${SHARD_INDEX}-shardsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-shard-${SHARD_INDEX}-shardsvr.{{ $.Release.Namespace }}.svc.cluster.local:27018"
    }
    {{- end }}
  ]
}
{{- end }}

{{- define "mongodb.shardadd" }}
sh.addShard("Shard${SHARD_INDEX}RS/
{{- range $i, $e := until (int .Values.topology.shards.servers) }}
{{- if ne 0 $i }},{{ end }}
{{ include "mongodb.fullname" $ }}-shard-${SHARD_INDEX}-shardsvr-{{ $i }}.{{ include "mongodb.fullname" $ }}-shard-${SHARD_INDEX}-shardsvr.{{ $.Release.Namespace }}.svc.cluster.local:27018
{{- end }}
")
{{- end }}

{{- define "mongodb.createuser" }}
{
  "createUser" : "CN=${USER_NAME},OU=Users,O=MongoDB-{{ .Release.Name }}",
  "roles" : [
    { "role" : "root", "db": "admin" }
  ]
}
{{- end }}