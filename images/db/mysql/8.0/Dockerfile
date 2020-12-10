FROM dolpa/ubuntu:20.04

LABEL maintainer="pavel.dolinin@gmail.com"

# Labels
LABEL os="ubuntu"
LABEL os-version="20.04"
LABEL app="mysql"
LABEL app-version="${version}"

# Arguments
ARG user=mysql
ARG group=mysql
ARG app=mysql
ARG uid=1000
ARG gid=1000
# ARG uid=2036
# ARG gid=2036
ARG http_port=3000
ARG version="8.0.22"

# Environmrnt
ENV user=${user}
ENV group=${group}
ENV app=${app}
ENV service_name=${app}d
ENV uid=${uid}
ENV gid=${gid}
ENV http_port=${http_port}
ENV version=${version}

# Tini arguments
ENV TINI_VERSION v0.19.0
ENV TINI_SHA c5b0666b4cb676901f90dfcb37106783c5fe2077b04590973b885950611b30ee

# App Environment variables
ENV MYSQL_MAJOR ${version}
ENV MYSQL_VERSION ${version}-1debian10
ENV MYSQL_HOME /var/atlassian/application-data/${app}
ENV MYSQL_INSTALL_DIR /opt/atlassian/${app}/${version}/


# Create group and user 
RUN groupadd -g ${gid} ${group}
RUN mkdir -p ${MYSQL_HOME}
RUN mkdir -p ${MYSQL_INSTALL_DIR}
RUN useradd -d "${MYSQL_HOME}" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Install requirements
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends ca-certificates apt-transport-https software-properties-common xvfb curl ssh gcc wget gnupg dirmngr pwgen openssl perl xz-utils && rm -rf /var/lib/apt/lists/*

# Install Tini and check sha sum of the bin file
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 -o /sbin/tini && chmod +x /sbin/tini \
    && echo "${TINI_SHA}  /sbin/tini" | sha256sum -c -

# Set pre-configuration to skip debian pacage configuration steps
RUN { echo mysql-community-server mysql-community-server/data-dir select ''; \
      echo mysql-community-server mysql-community-server/root-pass password ''; \
      echo mysql-community-server mysql-community-server/re-root-pass password ''; \
      echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections

# Install Mysql Server
RUN apt update && apt install -y --no-install-recommends  ${app}-server && rm -rf /var/lib/apt/lists/*

# make directory 
RUN rm -rf /var/run/${service_name}/ && mkdir -p /var/lib/${app}/ /var/run/${service_name}/ && chown -R ${user}:${group} /var/lib/${app} /var/run/${service_name}

# copy default configuration files 
COPY config/ /etc/mysql/

# volume 
VOLUME /var/lib/${app}

# Open ports
EXPOSE 3306 
EXPOSE 33060

# Switch user to mysql
USER ${user}

# Adding entrypoint files
COPY start-mysqld-docker.sh /
ENTRYPOINT [ "/sbin/tini", "--", "/start-mysqld-docker.sh" ]

# Set default command
CMD ["mysqld"]
