#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student
echo "Ensure running in correct namespace: $GUID-sonarqube..."
oc project $GUID-sonarqube
oc process -f ./Infrastructure/templates/sonarqube.yaml --param-file=./Infrastructure/bin/params_file/sonar.params | oc create -f - -n $GUID-sonarqube
