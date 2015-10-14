FROM ubuntu:wily

MAINTAINER Guy Taylor <thebigguy.co.uk@gmail.com>

ENV user=bitcoin
ENV email=thebigguy.co.uk@gmail.com

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8842CE5E
RUN echo "deb http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu wily main"     >> /etc/apt/sources.list.d/bitcoin.list ;\
    echo "deb-src http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu wily main" >> /etc/apt/sources.list.d/bitcoin.list
RUN apt-get -y update; apt-get -y install bitcoind bsdmainutils

RUN useradd --create-home ${user}
ENV HOME /home/${user}

RUN mkdir -p /home/${user}/.bitcoin/
COPY bitcoin.conf /home/${user}/.bitcoin/
RUN ["/bin/bash", "-c", "echo \"rpcuser=$(cat /dev/urandom | hexdump -e $'\"%02X\"' | head --bytes=32)\" >> /home/${user}/.bitcoin/bitcoin.conf"]
RUN ["/bin/bash", "-c", "echo \"rpcpassword=$(cat /dev/urandom | hexdump -e $'\"%02X\"' | head --bytes=128)\" >> /home/${user}/.bitcoin/bitcoin.conf"]
RUN echo "lertnotify=echo %s | mail -s \"Bitcoin Alert\" \"${email}\"" >> /home/${user}/.bitcoin/bitcoin.conf 
RUN chown ${user}:${user} /home/${user}/.bitcoin ;\
    chown ${user}:${user} /home/${user}/.bitcoin/bitcoin.conf
run cat /home/${user}/.bitcoin/bitcoin.conf

RUN apt-get purge bsdmainutils; apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/${user}
USER bitcoin
EXPOSE 8333
CMD ["bitcoind"]
