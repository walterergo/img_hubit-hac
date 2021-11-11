FROM walterergo/hubit-hac:latest
EXPOSE 22
RUN apk update \
    && apk add --upgrade openssh openrc git rsync \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel \
    && mkdir /repos /repos-backup \
    && sed -ie "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config \
    && sed -ie "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config \
    && sed -ie "s/#PermitRootLogin yes yes/PermitRootLogin no/g" /etc/ssh/sshd_config \
    && echo "0 5 * * * cd /repos ;for i in $(ls); do echo -n '$i : ' ;git -C $i pull 2>/dev/null ;done" > /etc/crontabs/root \
    && echo "30 5 * * * rsync -qr /repos/* /repos-backup" > /etc/crontabs/root
RUN ssh-keygen -A
ADD ./sshd_config /etc/ssh/sshd_config
RUN echo root:IA_1991$ | chpasswd
ENTRYPOINT ["sh","-c", "rc-status; rc-service sshd start; crond -f; hass -v"]
