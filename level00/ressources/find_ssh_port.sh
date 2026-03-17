/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    find_ssh_port.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/06 18:12:57 by tissad            #+#    #+#              #
#    Updated: 2026/03/06 18:12:58 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


PORT=$(cat /etc/ssh/sshd_config | grep Port | grep -v "#" | awk '{print $2}')
echo $PORT
# confirm that the port is listening
ss -tuln | grep $PORT