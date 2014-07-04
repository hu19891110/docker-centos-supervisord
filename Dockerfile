FROM centos

# set timezone
RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime

# install supervisord
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum --enablerepo=epel install -y supervisor
RUN mv -f /etc/supervisord.conf /etc/supervisord.conf.org
ADD ./supervisord.conf /etc/

# install rsyslogd
RUN yum install -y rsyslog

# install crond
RUN yum install -y cronie-noanacron
# no PAM
RUN sed -i -e 's/^session\s\+required\s\+pam_loginuid\.so/#session required pam_loginuid.so/' /etc/pam.d/crond

# install sshd
RUN yum install -y openssh-server
RUN echo 'root:root' | chpasswd
# no PAM
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -i -e 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config
RUN sed -i -e 's/^#UsePAM no/UsePAM no/' /etc/ssh/sshd_config

# install httpd
RUN yum install -y httpd

# expose for sshd, httpd
EXPOSE 22 80

# ENTRYPOINT ["/usr/bin/supervisord"] does not work.
# --> "Error: positional arguments are not supported"
# http://stackoverflow.com/questions/22465003/error-positional-arguments-are-not-supported
CMD ["/usr/bin/supervisord"]

# install vim
RUN yum install -y vim
RUN echo 'syntax on' >> /root/.vimrc
RUN echo 'alias vi="vim"' >> /root/.bashrc

