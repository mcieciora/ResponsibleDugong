FROM jenkins/jenkins:2.494-alpine

USER root

# Install plugins and setup jenkins instance with CASC
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /root/jenkins.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /root/jenkins.yaml
COPY initial_jobs /root/casc/initial_jobs

# Install docker and docker compose
RUN apk add docker docker-compose openrc jq
RUN rc-update add docker default