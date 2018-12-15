#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student

oc project ${GUID}-parks-prod
# Give necessary RBAC access to ServiceAccounts.
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-group system:image-puller system:serviceaccounts:${GUID}-parks-prod -n ${GUID}-parks-dev
oc policy add-role-to-user view --serviceaccount=default -n ${GUID}-parks-dev

# Create mongo services from template.
oc create -f ./Infrastructure/bin/templates/mongodb-prod-svc.yaml -n ${GUID}-parks-pro
# Create mongo StatefulSets from template.
oc create -f ./Infrastructure/bin/templates/mongodb-prod-sts.yaml -n ${GUID}-parks-pro

# Create Backend service from common backend template. This will hold as placeholder for Pipeline.
oc process -f ./Infrastructure/templates/backend-templates-prod.yaml  --param-file=./Infrastructure/bin/params_file/mlbparks-green.params | oc create  -f - -n ${GUID}-parks-pro
oc process -f ./Infrastructure/templates/backend-templates-prod.yaml  --param-file=./Infrastructure/bin/params_file/mlbparks-blue.params | oc create  -f - -n ${GUID}-parks-pro
oc process -f ./Infrastructure/templates/backend-templates-prod.yaml  --param-file=./Infrastructure/bin/params_file/nationalparks-green.params | oc create  -f - -n ${GUID}-parks-pro
oc process -f ./Infrastructure/templates/backend-templates-prod.yaml  --param-file=./Infrastructure/bin/params_file/nationalparks-blue.params | oc create  -f - -n ${GUID}-parks-pro

# Create Frontend service from template. This will hold as placeholder for Pipeline.
oc process -f ./Infrastructure/templates/frontend-templates-prod.yaml --param-file=./Infrastructure/bin/params_file/parksmap-green.params | oc create -f - -n ${GUID}-parks-pro
oc process -f ./Infrastructure/templates/frontend-templates-prod.yaml --param-file=./Infrastructure/bin/params_file/parksmap-blue.params | oc create -f - -n ${GUID}-parks-pro