FROM debian:bullseye-slim
LABEL type="base"
ARG country_code
RUN if [ "${country_code}" = "PH" ]; then timezone='Asia/Manila'; \
  elif [ "${country_code}" = "SG" ]; then timezone='Singapore'; \
  else timezone="UTC"; fi || exit 1 && \
  groupadd -g 65123 docker || exit 1 && \
  useradd -m -c "Security Guard" -u 65123 -N -g docker -G adm,staff -s /bin/bash sekyu || exit 1 && \
  echo "clear" > /home/sekyu/.bash_logout || exit 1 && \
  sed -i '${s/$/ contrib non-free/}' /etc/apt/sources.list || exit 1 && \
  DEBIAN_FRONTEND=noninteractive apt-get update || exit 1 && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y || exit 1 && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils bind9-dnsutils bzip2 curl dumb-init \
  file httping hping3 iperf3 iproute2 iptraf-ng iputils-arping iputils-ping iputils-tracepath jq \
  less locales mtr-tiny netcat-openbsd unzip vim.tiny || exit 1 && \
  rm -f /etc/localtime /etc/locale.nopurge /etc/default/locale /etc/environment || exit 1 && \
  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime || exit 1 && \
  echo "${timezone}" > /etc/timezone || exit 1 && \
  echo "en_${country_code}.UTF-8 UTF-8" > /etc/locale.gen || exit 1 && \
  curl -s -o /etc/locale.nopurge https://raw.githubusercontent.com/bintut/bahandi/master/locale.nopurge || exit 1 && \
  curl -s -o /etc/default/locale https://raw.githubusercontent.com/bintut/bahandi/master/locale || exit 1 && \
  cp -a /etc/default/locale /etc/environment || exit 1 && \
  echo "TZ=${timezone}" >> /etc/environment || exit 1 && \
  sed -i "s/COUNTRY_CODE/${country_code}/g" /etc/locale.nopurge /etc/default/locale /etc/environment || exit 1 && \
  sed -i 's/^UMASK.*$/UMASK 027/g' /etc/login.defs || exit 1 && \
  dpkg-reconfigure -f noninteractive locales || exit 1 && \
  locale-gen en_${country_code}.UTF-8 || exit 1 && \
  echo "export SHELL=/bin/bash\nexport TERM=xterm\nexport TZ=${timezone}\nexport PAGER=/usr/bin/less\n \
  export EDITOR=/usr/bin/vim.tiny\nexport LS_OPTIONS='--color=auto'\n \
  eval \"\$(dircolors)\"\nalias ls='ls \$LS_OPTIONS'\numask 027\n \
  export DEFAULT_GATEWAY=\$(ip -4 route show scope global | awk -F ' ' '{ print \$3 }')" >> /etc/bash.bashrc || exit 1 && \
  echo "session optional pam_umask.so" >> /etc/pam.d/common-session || exit 1 && \
  echo "umask 027\nexport SHELL=/bin/bash" > /etc/profile.d/defaults.sh || exit 1 && \
  echo "export DEFAULT_GATEWAY=\$(ip -4 route show scope global | awk -F ' ' '{ print \$3 }')" > \
  /etc/profile.d/default_gateway.sh || exit 1 && \
  ln -sf /usr/bin/vim.tiny /etc/alternatives/vim || exit 1 && \
  ln -sf /etc/alternatives/vim /usr/bin/vim || exit 1 && \
  sed -i 's/^"set showcmd/set showcmd/g; s/^"set showmatch/set showmatch/g; s/^"set smartcase/set smartcase/g; \
  s/^"set incsearch/set incsearch/g' /etc/vim/vimrc || exit 1 && \
  echo '\nset expandtab\n\
  set tabstop=2\n\
  set shiftwidth=2\n\
  set softtabstop=2\n\
  set nomodeline\n\
  set nu' >> /etc/vim/vimrc || exit 1 && \
  ln -sf /etc/vim/vimrc /etc/virc || exit 1 && \
  DEBIAN_FRONTEND=noninteractive apt-get clean all || exit 1 && \
  DEBIAN_FRONTEND=noninteractive apt autoremove --purge -y || exit 1 && \
  mkdir -p /data || exit 1 && \
  chmod 0700 /home/sekyu /data || exit 1 && \
  chown -R sekyu:users /home/sekyu /data || exit 1 && \
  chmod 0755 /etc/profile.d/defaults.sh /etc/profile.d/default_gateway.sh || exit 1 && \
  chown -R root:root /etc/profile.d/defaults.sh /etc/profile.d/default_gateway.sh || exit 1 && \
  rm -Rf /tmp/* /var/tmp/* || exit 1 && \
  find /var/log/ -type f -exec truncate -s 0 '{}' \; || exit 1
ENV LANG en_${country_code}.UTF-8
