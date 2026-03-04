# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/04 15:05:41 by tissad            #+#    #+#              #
#    Updated: 2026/03/04 15:51:35 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    # Essentials
    zsh \
    sudo curl wget git vim nano tmux \
    build-essential gdb gdb-multiarch \
    python3 python3-pip python3-venv \
    ruby \
    net-tools iputils-ping netcat-openbsd \
    nmap tcpdump \
    iproute2 net-tools \
    file strace ltrace \
    unzip zip \
    binwalk foremost steghide exiftool \
    john hashcat \
    sqlmap \
    tshark \
    openssh-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Tools Python CTF
RUN pip3 install --no-cache-dir \
    pwntools \
    ropper \
    capstone \
    angr \
    requests \
    flask

# Add a non-root user for CTF challenges
RUN useradd -m -s /bin/bash ctf && \
    echo "ctf:ctf" | chpasswd && \
    adduser ctf sudo

USER ctf
WORKDIR /home/ctf

CMD ["/bin/bash"]