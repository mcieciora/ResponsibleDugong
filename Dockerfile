FROM jenkins/jenkins:2.499-alpine

USER root

# Install plugins and setup jenkins instance with CASC
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/root/jenkins.yaml"
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /root/jenkins.yaml
COPY initial_jobs /root/casc/initial_jobs

# Install docker and docker compose
RUN apk --no-cache add \
    docker=27.3.1-r2 \
    docker-compose=2.31.0-r2 \
    openrc=0.55.1-r2 \
    jq=1.7.1-r0 \
    && rc-update add docker default