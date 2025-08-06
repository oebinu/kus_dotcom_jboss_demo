FROM quay.io/wildfly/wildfly:31.0.0.Final-jdk17

EXPOSE 8080
EXPOSE 9990

ARG WAR_FILE
COPY ${WAR_FILE} /opt/jboss/wildfly/standalone/deployments/

# JBoss/WildFly 실행
ENTRYPOINT ["sh","-c","/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0"]