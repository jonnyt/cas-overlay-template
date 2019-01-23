# Use a CentOS parent image
FROM centos:centos7

# Args
ARG CAS_VERSION=5.3
ARG OVERLAY_URI=https://github.com/jonnyt/cas-overlay-template.git

LABEL maintainer='Jonathon Taylor'
LABEL version='0.1'
LABEL description='CAS dockerfile with executable WAR using systemd'

ENV container docker
ENV JAVA_HOME /usr/lib/jvm/jre
ENV PATH $PATH:$JAVA_HOME/bin:.

# Enable systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

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
COPY etc/systemd/system/cas.service /etc/systemd/system/
COPY etc/krb5.conf /etc/

RUN chmod 750 cas-overlay/mvnw

EXPOSE 8080 8443

WORKDIR /cas-overlay

# Use the default and exec profiles, mark the war as executable
RUN ./mvnw clean package -P default,exec -T 10 \
    && cp target/cas.war /opt/cas/ \
    && chmod +x /opt/cas/cas.war \
    && rm -rf /root/.m2

CMD ["/usr/sbin/init"]
