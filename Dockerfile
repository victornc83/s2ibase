FROM openshift/base-centos7

MAINTAINER Victor Nieto <victornc83@gmail.com>

ENV BUILDER_VERSION 1.0.0
ENV MAVEN_VERSION 3.3.9
ENV GRADLE_VERSION 2.6
ENV PATH=/opt/maven/bin/:/opt/gradle/bin/:$PATH
ENV INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel"

LABEL io.k8s.description="Spring Boot Image 1.0" \
      io.k8s.display-name="spring-boot-base 1.0.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="spring-boot-base,1.0.0,java." \
	  io.openshift.s2i.scripts-url=image:///usr/local/s2i

RUN yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2

RUN curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle
	 

COPY ./.s2i/bin/ /usr/local/s2i

RUN chown -R 1001:1001 /opt/openshift

USER 1001

EXPOSE 8080

CMD ["usage"]
