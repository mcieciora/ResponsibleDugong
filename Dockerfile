FROM jenkins/jenkins:2.518-alpine

USER root

# Install plugins and setup jenkins instance with CASC
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/root/jenkins.yaml"
COPY configs/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY configs/jenkins.yaml /root/jenkins.yaml
COPY initial_jobs /root/casc/initial_jobs

# Install docker and docker compose
RUN apk --no-cache add \
    docker=28.3.0-r0 \
    docker-compose=2.36.2-r0 \
    openrc=0.62.5-r0 \
    jq=1.8.0-r0 \
    && rc-update add docker default

USER jenkins