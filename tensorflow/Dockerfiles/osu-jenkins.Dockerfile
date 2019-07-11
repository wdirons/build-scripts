FROM ibmcom/tensorflow-ppc64le:latest-devel

#From https://github.com/jenkinsci/docker-ssh-slave/blob/master/Dockerfile
ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN groupadd -g ${gid} ${group} \
&& useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" \
&& echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"
