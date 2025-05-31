{{- $parts := split .Name "-" -}}
{{- $week := index $parts 1 -}}

{{- $year := 2025 -}}
{{- $weekNumber := int $week -}}

{{- $jan4 := time (printf "%d-01-04" $year) -}}

{{- $jan4Weekday := $jan4 | dateFormat "Monday" -}}

{{- $offset := 0 -}}
{{- if eq $jan4Weekday "Tuesday" }}{{- $offset = -1 -}}{{ end -}}
{{- if eq $jan4Weekday "Wednesday" }}{{- $offset = -2 -}}{{ end -}}
{{- if eq $jan4Weekday "Thursday" }}{{- $offset = -3 -}}{{ end -}}
{{- if eq $jan4Weekday "Friday" }}{{- $offset = -4 -}}{{ end -}}
{{- if eq $jan4Weekday "Saturday" }}{{- $offset = -5 -}}{{ end -}}
{{- if eq $jan4Weekday "Sunday" }}{{- $offset = -6 -}}{{ end -}}

{{- $week1Monday := $jan4.AddDate 0 0 $offset -}}

{{- $daysToAdd := int (mul (sub $weekNumber 1) 7) -}}

{{- $monday := $week1Monday.AddDate 0 0 $daysToAdd -}}
{{- $sunday := $monday.AddDate 0 0 6 -}}

---
title: "Week {{ $week }}, {{ .Date | dateFormat "2006" }}"
date: {{ .Date }}
week: "{{ $week }}"
weekRange: "{{ $monday | dateFormat "January 2" }} - {{ $sunday | dateFormat "January 2" }}"
weekName: ""
draft: true
---
Week {{ $weekNumber }} Range: {{ $monday | dateFormat "January 2, 2006" }} – {{ $sunday | dateFormat "January 2, 2006" }}

## {{ $monday | dateFormat "January 2" }} - {{ $sunday | dateFormat "January 2" }}

## Week //
### Monday

### Tuesday 

### Wednesday

### Thursday 

### Friday 

### Saturday

### Sunday