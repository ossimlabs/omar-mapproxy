{{- define "omar-mapproxy.imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.imagePullSecret.registry (printf "%s:%s" .Values.global.imagePullSecret.username .Values.global.imagePullSecret.password | b64enc) | b64enc }}
{{- end }}

{{/* Template for env vars */}}
{{- define "omar-mapproxy.envVars" -}}
  {{- range $key, $value := merge .Values.envVars .Values.global.envVars }}
  - name: {{ tpl (toString $key) $ | quote }}
    value: {{ tpl (toString $value) $ | quote }}
  {{- end }}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "omar-mapproxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "omar-mapproxy.fullname" -}}
{{-   if .Values.fullnameOverride }}
{{-     .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{-   else }}
{{-     $name := default .Chart.Name .Values.nameOverride }}
{{-     if contains $name .Release.Name }}
{{-       .Release.Name | trunc 63 | trimSuffix "-" }}
{{-     else }}
{{-       printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{-     end }}
{{-   end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "omar-mapproxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "omar-mapproxy.labels" -}}
omar-mapproxy.sh/chart: {{ include "omar-mapproxy.chart" . }}
{{ include "omar-mapproxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "omar-mapproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "omar-mapproxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "omar-mapproxy.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $imageName := .Values.image.name -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.dockerRepository }}
        {{- printf "%s/%s:%s" .Values.global.dockerRepository $imageName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $imageName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $imageName $tag -}}
{{- end -}}
{{- end -}}

{{/* Templates for the volumeMounts section */}}

{{- define "omar-mapproxy.volumeMounts.configmaps" -}}
{{- range $configmapName, $configmapDict := .Values.configmaps}}
- name: {{ $configmapName | quote }}
  mountPath: {{ $configmapDict.mountPath | quote }}
  {{- if $configmapDict.subPath }}
  subPath: {{ $configmapDict.subPath | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "omar-mapproxy.volumeMounts.pvcs" -}}
{{- range $volumeName := .Values.volumeNames }}
{{- $volumeDict := index $.Values.global.volumes $volumeName }}
- name: {{ $volumeName }}
  mountPath: {{ $volumeDict.mountPath }}
  {{- if $volumeDict.subPath }}
  subPath: {{ $volumeDict.subPath | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "omar-mapproxy.volumeMounts" -}}
{{- include "omar-mapproxy.volumeMounts.configmaps" . -}}
{{- include "omar-mapproxy.volumeMounts.pvcs" . -}}
{{- end -}}





{{/* Templates for the volumes section */}}

{{- define "omar-mapproxy.volumes.configmaps" -}}
{{- range $configmapName, $configmapDict := .Values.configmaps}}
- name: {{ $configmapName | quote }}
  configMap:
    name: {{ $configmapName | quote }}
{{- end -}}
{{- end -}}

{{- define "omar-mapproxy.volumes.pvcs" -}}
{{- range $volumeName := .Values.volumeNames }}
{{- $volumeDict := index $.Values.global.volumes $volumeName }}
- name: {{ $volumeName }}
  persistentVolumeClaim:
{{- if (pluck "createPVs" $.Values $.Values.global | first) }}
    claimName: "{{ $.Values.fullnameOverride }}-{{ $volumeName }}-pvc"
{{- else }}
    claimName: "{{ $volumeName }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "omar-mapproxy.volumes" -}}
{{- include "omar-mapproxy.volumes.configmaps" . -}}
{{- include "omar-mapproxy.volumes.pvcs" . -}}
{{- end -}}
