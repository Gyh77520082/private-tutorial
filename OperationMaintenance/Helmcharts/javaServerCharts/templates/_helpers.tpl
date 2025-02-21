

{{/*
  定义容器的公共标签，用于区分不同的服务层级。
*/}}
{{- define "kube.labels" -}}
k8s.kuboard.cn/layer: svc
k8s.kuboard.cn/name: {{ .Release.Name }}
{{- end -}}

{{/*
  定义容器的公共参数，用于启动应用。
*/}}
{{- define "container.args" -}}
- '-jar'
- '{{ .Release.Name }}.jar'
- '--nacos.config.server-addr={{ .Values.nacos.addr }}'
- '--nacos.discovery.server-addr={{ .Values.nacos.addr }}'
- '--nacos.username={{ .Values.nacos.username }}'
- '--nacos.password={{ .Values.nacos.password }}'
- '--nacos.config.namespace={{ .Values.nacos.namespace }}'
- '--nacos.discovery.namespace={{ .Values.nacos.namespace }}'
{{- end -}}

{{/*
  定义容器的公共镜像，用于启动应用。
*/}}
{{- define "container.image" -}}
{{- $imageRepository := .Values.image.repository -}}
{{- $imageName := .Values.image.name | default .Release.Name -}}
{{- $imageVersion := .Values.image.version -}}
{{- printf "%s%s:%s" $imageRepository $imageName $imageVersion -}}
{{- end -}}