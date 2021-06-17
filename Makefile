CHART_NAME = $(shell yq eval '.name' chart/nginx/Chart.yaml)
CHART_VERSION = $(shell yq eval '.version' chart/nginx/Chart.yaml)

APP_VERSION ?= $(shell yq eval '.appVersion' chart/nginx/Chart.yaml)

SPINNAKER_API ?= https://spinnaker.tcg.services.cerise.media/gate

package:
	helm package chart/nginx -d chart/.packages

version:
	echo $(CHART_VERSION) > values/chart_version

push:
	# helm push chart/nginx hope3r
	cr upload --config cr.yaml --skip-existing
	helm index

triggerchart:
	curl -L -X POST \
		-k \
		-H"Content-Type: application/json" $(SPINNAKER_API)/webhooks/webhook/nginxdemo \
		-d '{ \
			"artifacts": [ \
				{ \
				"artifactAccount": "hope3r", \
				"type": "helm/chart", \
				"name": "$(CHART_NAME)", \
				"version": "$(CHART_VERSION)" \
				} \
			] \
			}'