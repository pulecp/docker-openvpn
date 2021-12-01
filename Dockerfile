# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM ubuntu:latest

LABEL maintainer="Pavel Pulec <pavel.pulec@showmax.com>"

ARG EASYRSA_VERSION=3.0.8

# Testing: pamtester
RUN /usr/bin/apt-get update && \
    /usr/bin/apt-get -yq install --no-install-recommends \
        iptables \
        libpam-yubico \
        openssl \
        openvpn \
        pamtester \
        qrencode \
        vim \
        wget
        #libpam-google-authenticator \
        #libpam-u2f \
        #autoconf \
        #automake \
        #libtool \
        #pkg-config \
        #libfido2-dev \
        #libpam-dev \
        #libssl-dev \

# Install easy-rsa
RUN wget --no-check-certificate https://github.com/OpenVPN/easy-rsa/archive/refs/tags/v$EASYRSA_VERSION.tar.gz -P /tmp && \
    tar xfvz /tmp/v$EASYRSA_VERSION.tar.gz -C /tmp && \
    cp -r /tmp/easy-rsa-$EASYRSA_VERSION/easyrsa3 /usr/share/easy-rsa && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
