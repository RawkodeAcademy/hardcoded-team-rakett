package kube

import apps "cue.dev/x/k8s.io/api/apps/v1"

import core "cue.dev/x/k8s.io/api/core/v1"

_name:  string @tag(name)
_tag:   string @tag(tag)
_image: string @tag(image)

deployment: apps.#Deployment & {
	metadata: {
		name:      _name
		namespace: "team-rakett"
	}
	spec: {
		selector: {
			matchLabels: {
				app: _name
			}
		}
		template: {
			metadata: {
				labels:
					app: _name
			}
			spec: {
				containers: [{
					name:  _name
					image: _image + ":" + _tag
					securityContext: {
						allowPrivilegeEscalation: false
						readOnlyRootFilesystem:   true
						runAsNonRoot:             true
					}
				}]
				securityContext: runAsUser: 10002
			}
		}
	}
}
service: core.#Service & {
	metadata: {
		name:      _name
		namespace: "team-rakett"
	}
	spec: {
		type: "ClusterIP"
		selector:
			app: _name
		ports: [{
			name:       "http"
			port:       8080
			targetPort: 8080
			protocol:   "TCP"
		}]
	}
}
