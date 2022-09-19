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

# Install libnsl
# RUN apt-get -y install libtool autoconf gettext unzip wget gcc g++ cmake make -y
# RUN mkdir -p /opt && cd /opt && \
# wget https://github.com/thkukuk/libnsl/archive/v2.0.0.zip && \
# unzip v2.0.0.zip && rm v2.0.0.zip && \
# cd /opt/libnsl-2.0.0 &&  \
# ./autogen.sh && ./configure && cmake && make install

COPY bin /usr/coturn/bin
COPY build /usr/coturn/build
COPY examples/etc/turnserver.conf /etc/turnserver.conf

# Replace #lt-cred-mech with lt-cred-mech
RUN sed -i 's/#lt-cred-mech/lt-cred-mech/g' /etc/turnserver.conf

# Insert user=guest:somepassword into /etc/turnserver.conf
RUN sed -i 's/#user=user1:password1/user=guest:somepassword/g' /etc/turnserver.conf

# Listen on ip 0.0.0.0
RUN echo "listening-ip=0.0.0.0" >> /etc/turnserver.conf
RUN echo "log-file=/var/log/turnserver.log" >> /etc/turnserver.conf
RUN echo "fingerprint" >> /etc/turnserver.conf

# turn_only mode. This prevents requests with scheme stun or stuns from being processed by the relay server.
RUN echo "turn-only" >> /etc/turnserver.conf

RUN mkdir /run/turnserver

CMD ./usr/coturn/bin/turnserver -c /etc/turnserver.conf --pidfile /run/turnserver/turnserver.pid
EXPOSE 3478
EXPOSE 5349
