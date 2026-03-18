#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    find_flag.sh                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/06 21:05:17 by tissad            #+#    #+#              #
#    Updated: 2026/03/06 21:05:26 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# copy the pcap file to the current directory
scp -P 4243 level02@192.168.1.183:level02.pcap .

# to string 
strings level02.pcap 

tshark -r level02.pcap -z follow,tcp,ascii,0

#tshark is network protocol analyzer, it can read pcap files and extract data from them.
# it's the terminal version of wireshark.

# -r : read pcap file
# -z : follow tcp stream (le flux de données d'une connexion TCP)
# ascii : display the data in ascii format
# 0 : the stream number (the first stream)
#the mp is ft_waNDReLOL