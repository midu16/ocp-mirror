#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <OC_VERSION>"
  exit 1
fi

# Assign the arguments to variables
OC_VERSION="$1"

# Create the imageset-config.yaml content using a here document
cat <<EOF > imageset-config.yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
archiveSize: 4
mirror:
  platform:
    channels:
    - name: stable-${OC_VERSION%.*}
      minVersion: ${OC_VERSION}
      maxVersion: ${OC_VERSION}
      type: ocp
    graph: true
  additionalImages:
  - name: registry.redhat.io/ubi9/ubi:latest
  helm: {}
EOF

# Print the generated content
cat imageset-config.yaml
