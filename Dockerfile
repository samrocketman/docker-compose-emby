FROM centos:7

ENV DEFAULT_EMBY_VERSION 3.5.2.0

RUN set -ex; \
yum install -y https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_VERSION:-${DEFAULT_EMBY_VERSION}}/emby-server-rpm_${EMBY_VERSION:-${DEFAULT_EMBY_VERSION}}_x86_64.rpm; \
yum clean all; \
rm -rf /var/cache/yum; \
rm -rf /tmp/*

USER emby
WORKDIR /opt/emby-server
ENV EMBY_DATA /var/lib/emby

CMD /opt/emby-server/bin/emby-server
