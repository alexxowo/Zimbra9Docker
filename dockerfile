FROM ubuntu:18.04
MAINTAINER Alexandre Marquez

# Include zimbra installer
ADD ./zimbra-installer /root/zimbra-installer

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
	apt-utils \	
	lsb-release \
	lsb-core \
	apt-file \
	dnsmasq \
	dnsutils \
	net-tools \
	iproute2 \
	vim 
	
RUN echo "set rnu" >> ~/.vimrc

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071


