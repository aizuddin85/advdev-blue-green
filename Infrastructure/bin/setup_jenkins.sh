#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
REPO=$2
CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student


echo "Ensure running in correct namespace: ${GUID}-jenkins..."
oc project ${GUID}-jenkins
oc new-app --template=jenkins-persistent --param-file=./Infrastructure/bin/params_file/jenkins.params -n  ${GUID}-jenkins

oc new-build  -D $'FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11\n
      USER root\nRUN yum -y install skopeo && yum clean all\n
      USER 1001' --name=jenkins-slave-appdev -n ${GUID}-jenkins 

oc new-build ${REPO}#master --name=mlbparks-pipeline --context-dir=./MLBParks -e GUID=${GUID} -e CLUSTER=${CLUSTER} -n ${GUID}-jenkins
oc new-build ${REPO}#master --name=nationalparks-pipeline --context-dir=./Nationalparks -e GUID=${GUID} -e CLUSTER=${CLUSTER} -n  ${GUID}-jenkins
oc new-build ${REPO}#master --name=parksmap-pipeline --context-dir=./ParksMap -e GUID=${GUID} -e CLUSTER=${CLUSTER} -n  ${GUID}-jenkins


