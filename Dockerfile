FROM jenkins/jenkins:2.451-alpine

USER root

# Install plugins and setup jenkins instance with CASC
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /root/jenkins.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /root/jenkins.yaml
COPY initial_jobs /root/casc/initial_jobs
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

RUN apk add docker docker-compose openrc
RUN rc-update add docker default

RUN curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh -o install-scout.sh
RUN sh install-scout.sh && rm install-scout.sh