# x11docker/cinnamon
# 
# Run cinnamon desktop in docker. 
# Use x11docker to run image. 
# Get x11docker from github: 
#   https://github.com/mviereck/x11docker 
#
# Run desktop with:
#   x11docker --desktop --systemd x11docker/cinnamon
#
# Run single application:
#   x11docker x11docker/cinnamon nemo
#
#
# Options:
# Persistent home folder stored on host with   --home
# Shared host file or folder with              --share PATH
# Hardware acceleration with option            --gpu
# Clipboard sharing with option                --clipboard
# ALSA sound support with option               --alsa
# Pulseaudio sound support with option         --pulseaudio
# Language setting with                        --lang [=$LANG]
# Printing over CUPS with                      --printer
# Webcam support with                          --webcam
#
# See x11docker --help for further options.

FROM debian:buster

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      dbus-x11 \
      procps \
      psmisc && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      mesa-utils \
      mesa-utils-extra \
      libxv1 && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xdg-utils \
      xdg-user-dirs \
      menu-xdg \
      mime-support \
      desktop-file-utils

# Language/locale settings
#   replace en_US by your desired locale setting, 
#   for example de_DE for german.
ENV LANG en_US.UTF-8
RUN echo $LANG UTF-8 > /etc/locale.gen && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      locales && \
    update-locale --reset LANG=$LANG

# cinnamon and some utils
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      cinnamon \
      cinnamon-l10n && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      dconf-cli \
      gedit \
      gnome-system-monitor \
      gnome-terminal \
      libpulse0 \
      sudo \
      synaptic


# startscript to set a background wallpaper
RUN echo '#! /bin/sh\n\
[ -e \$HOME/.cinnamon ] || {\n\
  dconf write /org/cinnamon/desktop/background/picture-uri \"'file:///usr/share/backgrounds/gnome/Sandstone.jpg'\"\n\
}\n\
exec "$@" \n\
' > /usr/local/bin/start
RUN chmod +x /usr/local/bin/start 

ENTRYPOINT ["/usr/local/bin/start"]
CMD ["cinnamon-session"]
