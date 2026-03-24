FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker

# 1. Устанавливаем systemd и нужные для 1 и 2 задачи пакеты
RUN apt-get update && \
    apt-get install -y systemd systemd-sysv iproute2 iputils-ping dnsutils unbound && \
    apt-get clean

# 2. Универсальный хак: удаляем системные таргеты, требующие реального железа.
# Это делает образ совместимым с ЛЮБЫМ Linux-хостом (NixOS, Ubuntu, Debian и т.д.)
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp* \
    /lib/systemd/system/getty.target \
    /lib/systemd/system/graphical.target

# Устанавливаем multi-user как дефолтный таргет (чтобы не запускать лишнего)
RUN systemctl set-default multi-user.target

# 3. Перенаправляем логи systemd (и unbound) в Docker stdout
RUN mkdir -p /etc/systemd/journald.conf.d && \
    echo "[Journal]\nForwardToConsole=yes" > /etc/systemd/journald.conf.d/docker-console.conf

# 4. Включаем Unbound в автозапуск
RUN systemctl enable unbound

# 5. Настраиваем корректную остановку и запуск systemd
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
