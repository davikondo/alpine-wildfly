FROM fabioluciano/alpine-base-java
LABEL Maintainer="Fábio Luciano <fabioluciano@php.net>" \
  Description="Alpine Java Wildfly"

ARG wildfly_version="10.1.0.Final"
ARG wildfly_url="http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

WORKDIR /opt

COPY files/supervisor/* /etc/supervisor.d/
COPY files/entrypoint.sh /usr/local/bin/

# Configure SSH
RUN apk --update --no-cache add openssh \
  && printf "password\npassword" | adduser wildfly \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo "AllowUsers wildfly" >> /etc/ssh/sshd_config \
  && curl -L ${wildfly_url} > wildfly.tar.gz && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz && mv $directory wildfly \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt"' >> /opt/wildfly/bin/standalone.conf \
  && chown wildfly:wildfly /opt/wildfly -R && mkdir -p /var/log/sshd/ /var/log/wildfly/ \
  && printf 'export JBOSS_HOME=/opt/wildfly\nexport PATH=$PATH:$JBOSS_HOME' > /etc/profile.d/jboss.sh \
  && /opt/wildfly/bin/add-user.sh admin admin --silent=true \
  && chmod a+x /usr/local/bin/entrypoint.sh \
  && rm -rf /var/cache/apk/*

COPY files/standalone/* /opt/wildfly/standalone/configuration

VOLUME ["/opt/wildfly/standalone/configuration", "/opt/wildfly/standalone/deployments", "/opt/wildfly/standalone/tmp", "/opt/wildfly/standalone/data", "/opt/wildfly/standalone/log"]

WORKDIR /opt/wildfly

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 22/tcp 8080/tcp 8443/tcp 9990/tcp 9993/tcp
