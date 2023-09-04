#!/bin/bash
# ======================================================================
# MAINTAINER: midu@redhat.com
#
# Prerequisite
#
# This script is available ONLY for OCP GA versions. Any other releaseases are not supported.
# ======================================================================

# ======================================================================
# Core program logic

# set some printing colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;36m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# defining the keyboard input variables
helpFunction()
{
  echo ""
  echo "Usage: $0 -a 23R3 -b /path/to/release_versions.yml -c du"
  echo -e "\t-a This parameter is requiring the release mirroring. Example: 23R3, 23R4, etc."
  echo -e "\t-b This parameter is requiring the full path to release_version.yml file. Example: /tmp/release_versions.yml"
  echo -e "\t-c This parameter is requiring the OCP cluster profile. Example: cu or du."
  exit 1 # Exit script after printing help
}

while getopts "a:b:c:" opt
do
  case "$opt" in
      a ) parameterA="${OPTARG}" ;;
      b ) parameterB="${OPTARG}" ;;
      c ) parameterC="${OPTARG}" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterA" ] || [ -z "$parameterB" ] || [ -z "$parameterC" ]
then
  echo -e "${RED}Some or all of the parameters are empty${NC}";
  helpFunction
fi


# Begin script in case all parameters are correct
function debugg_param() {
  echo "$parameterA"
  echo "$parameterB"
  echo "$parameterC"
}

# Render the imageset-config-$PROFILE.yaml file function
template_imageset_config() {
  # local varialbes of *template_imageset_config* function
  local OC_VERSION="$1"
  local VERSION="$2"
  local RELEASE_VERSIONS="$3"
  local PROFILE="$4"
  # Create the imageset-config.yaml content using a here document
cat <<EOF > imageset-config.yaml
---
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
  - name: registry.redhat.io/rhel8/support-tools:latest
  helm: {}
  operators:
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v${OC_VERSION%.*}
    full: true
    targetName: redhat-operator-index
    targetTag: "${OC_VERSION%.*}"
    packages:
EOF

  # This section its going to template the day2-operators 
  for index in $(yq eval ".$VERSION.day2-operators.$PROFILE" $RELEASE_VERSIONS | awk '{ print $1}' | tr -d :)
  do
cat <<-EOF >> imageset-config.yaml
    - name: ${index}
      minVersion: '$(yq eval ".$VERSION.day2-operators.$PROFILE.$index" $RELEASE_VERSIONS | awk '{ print $1}' )'
      maxVersion: '$(yq eval ".$VERSION.day2-operators.$PROFILE.$index" $RELEASE_VERSIONS | awk '{ print $1}' )'
EOF
  done
}


# Making sure that the path/to/release_versions.yml exists and its populated with coresponding values otherwise exist the program
if [[ -f "$parameterB" ]]; then
  echo "$parameterB exists in the mentioned path!"
  # Assign the arguments to variables
  # Check if the variable is not null or empty
  if [ -n "$(yq eval ".$parameterA.ocp-release" $parameterB)" ] && [ -n "$parameterA" ] && [ -n "$parameterC" ]; then
    # Example of values are: 23R3, 23R4, etc.
    echo "################################################"
    VERSION="$parameterA"
    echo "Release version: $VERSION"
    # Render the OCP_VERSION based on the RELEASE VERSION
    OC_VERSION=$(yq eval ".$VERSION.ocp-release" $parameterB)
    echo "OpenShift Cluster Platform version: $OC_VERSION"
    # Assign the Profile and make sure its lowercase
    PROFILE="$(echo "$parameterC" | tr '[:upper:]' '[:lower:]')"
    echo  "OpenShift Cluster Platform profile: $PROFILE"
    echo "################################################"
    template_imageset_config $OC_VERSION $VERSION $parameterB $PROFILE
  else
    echo "Variable is null or empty."
    exit 1
  fi
else
    echo -e "${RED}\n+ $parameterB DOES NOT exists in the mentioned path!${NC}"
    exit 1
fi


# Print the generated content at the end of the script
cat imageset-config.yaml
