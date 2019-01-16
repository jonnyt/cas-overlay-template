# Use a CentOS parent image
FROM centos:centos7

# Args
ARG CAS_VERSION=5.3
ARG OVERLAY_URI=https://github.com/jonnyt/cas-overlay-template.git

LABEL maintainer='Jonathon Taylor'
LABEL version='0.1'
LABEL description='Test CAS dockerfile'

ENV PATH=$PATH:$JRE_HOME/bin

# Install basic tools including the openJDK
RUN yum -y install wget tar unzip git java-1.8.0-openjdk \
    && yum -y clean all

# Download the CAS overlay project \
RUN cd / \
    && git clone --depth 1 --branch $CAS_VERSION --single-branch $OVERLAY_URI cas-overlay \
    && mkdir -p /etc/cas;

# Copy our CAS config and overrides to the container
COPY etc/cas/thekeystore /etc/cas/
COPY etc/cas/config/*.* /etc/cas/config/
COPY etc/cas/services/*.* /etc/cas/services/

RUN chmod 750 cas-overlay/mvnw \
    && chmod 750 cas-overlay/build.sh;

EXPOSE 8080 8443

WORKDIR /cas-overlay

ENV JAVA_HOME /usr/lib/jvm/jre
ENV PATH $PATH:$JAVA_HOME/bin:.

RUN ./mvnw clean package -P default,exec -T 10 \
    && chmod +x target/cas.war \
    && rm -rf /root/.m2

CMD ["target/cas.war"]
