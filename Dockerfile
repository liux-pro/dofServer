FROM centos:6.10
MAINTAINER Nannan<1041836312@qq.com>
ENV PUBLIC_IP 1.1.1.70
ENV MYSQL_IP 127.0.0.1
ENV MYSQL_PORT 3306
ENV MYSQL_ACC game
#特殊字符转义
ENV MYSQL_PWD_O "bZ5wgayC"
ENV MYSQL_PWD "593e518603e11678e8b10c1f8bc3595be8b10c1f8bc3595b"
WORKDIR /
ADD libs.tar.gz /
ADD neople.tar.gz /home/
#COPY nnn /
COPY docker-entrypoint.sh /tmp
ADD https://dl-web.dropbox.com/s/tz1ql573r09i75d/publickey.pem /home/neople/game/
ADD https://dl-web.dropbox.com/s/drzf8vi4iyrwgc8/Script.pvf /home/neople/game/
#ADD http://1.1.1.111/D%3A/WORKDIR/publickey.pem /home/neople/game/
#ADD http://1.1.1.111/D%3A/WORKDIR/Script.pvf /home/neople/game/
COPY welcome.sh /home
RUN /tmp/docker-entrypoint.sh
CMD ["/bin/bash"]
