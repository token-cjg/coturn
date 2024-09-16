# Required for libnsl, see https://bugs.launchpad.net/ubuntu-kernel-tests/+bug/1865415 (bug in ubuntu:20.04)
FROM ubuntu:20.04

# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32
# Alter sources list so that we can find gcc-4.9
RUN cd /etc/apt && echo 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial main\n' >> sources.list && echo 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe\n' >> sources.list && cd -

# # Security
# RUN apt-get -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true install gnupg
# RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5
# RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32

# Make sure that we have add-apt-repository available
RUN apt-get -y -o Acquire::ForceIPv4=true update
RUN apt-get install software-properties-common -y

# Tooling to support running the programme
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN add-apt-repository ppa:devacom/build-tools -y
RUN apt-get -y -o Acquire::ForceIPv4=true update && apt-get install -y gcc-4.9 && apt-get upgrade -y libstdc++6
RUN apt-get dist-upgrade -y
RUN apt-get -y install libpq-dev libmariadb-dev libtirpc-dev libnsl-dev libevent-dev

# Install sqlite
RUN apt-get -y install sqlite3 libsqlite3-dev

# Copy relevant files
COPY bin /usr/coturn/bin
COPY build /usr/coturn/build
COPY examples/etc/turnserver.conf /etc/turnserver.conf
COPY examples/coturn /etc/default/coturn
COPY examples/etc/coturn.service /etc/systemd/system/coturn.service

# Get openssl
RUN apt-get -y install wget libcrypto++-dev libcrypto++-doc libcrypto++-utils

# Make keys
RUN mkdir -p /etc/ssl/certs
RUN mkdir -p /etc/ssl/private
RUN openssl req -x509 -nodes -days 365 \
    -subj  "/C=CA/ST=QC/O=Company Inc/CN=localhost" \
     -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key \
     -out /etc/ssl/certs/nginx-selfsigned.crt;

RUN useradd -m turnserver

# Setup turnserver.conf
RUN echo "lt-cred-mech" >> /etc/turnserver.conf
#RUN echo "use-auth-secret" >> /etc/turnserver.conf
RUN echo "user=guest:somepassword" >> /etc/turnserver.conf
RUN echo "listening-ip=0.0.0.0" >> /etc/turnserver.conf
RUN echo "log-file=/var/log/turnserver.log" >> /etc/turnserver.conf
RUN echo "fingerprint" >> /etc/turnserver.conf
RUN echo "proc-user=turnserver" >> /etc/turnserver.conf
RUN echo "proc-group=turnserver" >> /etc/turnserver.conf
RUN echo "server-name=localhost" >> /etc/turnserver.conf
RUN echo "realm=localhost" >> /etc/turnserver.conf
RUN echo "verbose" >> /etc/turnserver.conf
RUN echo "cli-password=somepassword" >> /etc/turnserver.conf


# Key + Crt
RUN echo "cert=/etc/ssl/certs/nginx-selfsigned.crt" >> /etc/turnserver.conf
RUN echo "pkey=/etc/ssl/private/nginx-selfsigned.key" >> /etc/turnserver.conf

# turn_only mode. This prevents requests with scheme stun or stuns from being processed by the relay server.
#RUN echo "use-turn-only" >> /etc/turnserver.conf

RUN mkdir /run/turnserver

RUN mkdir -p /usr/local/var/db

RUN ./usr/coturn/bin/turnadmin -a -u guest -r localhost -p somepassword

# Allow turnserver user to write to /var/log
RUN chown -R turnserver /var/log
RUN chown -R turnserver /usr/local/var/db

CMD ./usr/coturn/bin/turnserver -c /etc/turnserver.conf --pidfile /run/turnserver/turnserver.pid
EXPOSE 3478
EXPOSE 5349
# expose ports 49000 through 50000
EXPOSE 49152-65535