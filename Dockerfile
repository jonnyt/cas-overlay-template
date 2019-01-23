# Use a CentOS parent image
FROM centos:centos7

# Args
ARG CAS_VERSION=5.3
ARG OVERLAY_URI=https://github.com/jonnyt/cas-overlay-template.git

LABEL maintainer='Jonathon Taylor'
LABEL version='0.1'
LABEL description='CAS dockerfile with executable WAR using systemd'

ENV JAVA_HOME /usr/lib/jvm/jre
ENV PATH $PATH:$JAVA_HOME/bin:.

# Install JDK 8 as requirement for CAS 5.x
RUN yum -y install git java-1.8.0-openjdk \
    && yum -y clean all

# Download the CAS overlay project
RUN cd / \
    && git clone --depth 1 --branch $CAS_VERSION --single-branch $OVERLAY_URI cas-overlay \
    && mkdir -p /etc/cas \ 
    && mkdir -p /opt/cas;

# Copy our CAS config to the container
COPY etc/cas/thekeystore /etc/cas/
COPY etc/cas/config/*.* /etc/cas/config/
COPY etc/cas/*.* /etc/cas/
COPY etc/cas/services/*.* /etc/cas/services/
COPY etc/cas/systemd/system/cas.service /etc/systemd/system/
COPY etc/krb5.conf /etc/

RUN chmod 750 cas-overlay/mvnw

EXPOSE 8080 8443

WORKDIR /cas-overlay

# Use the default and exec profiles, mark the war as executable
RUN ./mvnw clean package -P default,exec -T 10 \
    && cp target/cas.war /opt/cas/ \
    && chmod +x /opt/cas/cas.war \
    && rm -rf /root/.m2

CMD ["/sbin/init"]
