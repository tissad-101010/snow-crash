# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    crack_pw.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/06 19:23:20 by tissad            #+#    #+#              #
#    Updated: 2026/03/06 19:26:42 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PASSWORD=42hDRfypTqqnw
# use John the Ripper to crack the password
echo $PASSWORD > hash.txt
john hash.txt
# print the cracked password
cat ~/.john/john.pot
john --show hash.txt

