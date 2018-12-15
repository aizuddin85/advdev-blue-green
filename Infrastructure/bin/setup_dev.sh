#!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

# Code to set up the parks development project.

# To be Implemented by Student
echo "Ensure we are in the correct namespace: ${GUID}-parks-dev..."
oc project ${GUID}-parks-dev

# Setting up permission so Jenkins can do its magic!
oc policy add-role-to-user view --serviceaccount=default -n ${GUID}-parks-dev
oc policy add-role-to-user edit system:serviceaccount:${GUID}-jenkins:jenkins -n ${GUID}-parks-dev

# Setting up MongoDB and call parameters from param file.
oc new-app --template=mongodb-persistent --param-file=./Infrastructure/bin/params_file/mongodb.params -n ${GUID}-parks-dev

# Create new build and point to Nexus.
oc new-build --name="mlbparks" --binary=true  jboss-eap70-openshift:1.7 --to=${GUID}-parks-dev/mlbparks:0.0-0 -e MAVEN_MIRROR_URL=http://nexus3-90cd-nexus.apps.na311.openshift.opentlc.com/repository/maven-all-public -n ${GUID}-parks-dev
# Send binary build to OCP builder.
oc start-build mlbparks --from-dir=MLBParks -n ${GUID}-parks-dev --follow  --wait=true
# Always tag the newest version as latest, so there will be easy to manage DC and switching image when necessary.
oc tag  ${GUID}-parks-dev/mlbparks:0.0-0 ${GUID}-parks-dev/mlbparks:latest -n ${GUID}-parks-dev
# Application objects definition nicely put in the template.
oc process -f ./Infrastructure/templates/mlbparks.yaml | oc create -f - -n ${GUID}-parks-dev

# Create new build and point to Nexus.
oc new-build --name="nationalparks" --binary=true  redhat-openjdk18-openshift:1.2 --to=${GUID}-parks-dev/nationalparks:0.0-0 -e MAVEN_MIRROR_URL=http://nexus3-90cd-nexus.apps.na311.openshift.opentlc.com/repository/maven-all-public -n ${GUID}-parks-dev
# Send binary build to OCP builder.
oc start-build nationalparks --from-dir=Nationalparks -n ${GUID}-parks-dev --follow --wait=true
# Always tag the newest version as latest, so there will be easy to manage DC and switching image when necessary.
oc tag  ${GUID}-parks-dev/nationalparks:0.0-0 ${GUID}-parks-dev/nationalparks:latest -n ${GUID}-parks-dev
# Application objects definition nicely put in the template.
oc process -f ./Infrastructure/templates/nationalparks.yaml | oc create -f - -n ${GUID}-parks-dev


# Parksmap need to discover labeled route. Give view RBAC to default SA.
oc policy add-role-to-user view --serviceaccount=default -n  ${GUID}-parks-dev
# Create new build and point to Nexus.
oc new-build --binary=true --name="parksmap" redhat-openjdk18-openshift:1.2 --to=${GUID}-parks-dev/parksmap:0.0-0 -e MAVEN_MIRROR_URL=http://nexus3-90cd-nexus.apps.na311.openshift.opentlc.com/repository/maven-all-public -n ${GUID}-parks-dev
# Send binary build to OCP builder.
oc start-build parksmap --from-dir=ParksMap -n ${GUID}-parks-dev --follow  --wait=true
# Always tag the newest version as latest, so there will be easy to manage DC and switching image when necessary
oc tag ${GUID}-parks-dev/parksmap:0.0-0 ${GUID}-parks-dev/parksmap:latest -n ${GUID}-parks-dev
# Application objects definition nicely put in the template.
oc process -f ./Infrastructure/templates/parksmap.yaml --param="APPNAME=ParksMap (Dev)" | oc create -f  - -n ${GUID}-parks-dev
