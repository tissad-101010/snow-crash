# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    caesar_decodee.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/06 18:24:12 by tissad            #+#    #+#              #
#    Updated: 2026/03/18 20:19:50 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

RESULT="cdiiddwpgswtgt"

# the file contains the Caesar code to user flag00 to get the flag for level01
# we need a function to decode the Caesar code, we can use the following function
function Caesar_decode {
    local input="$1"
    local decal="$2"
    local output=""
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        if [[ "$char" =~ [a-zA-Z] ]]; then
            if [[ "$char" =~ [a-z] ]]; then
                base=97
            else
                base=65
            fi
            # Shift the character back by the specified amount
            decoded_char=$(printf "\\$(printf '%03o' $(( ( $(printf '%d' "'$char") - base + $decal) % 26 + base )) )")
            output+="$decoded_char"
        else
            output+="$char"
        fi
    done
    echo "$output"
}




# decode the Caesar code and print the result
DECODED=$(Caesar_decode $RESULT 11)
echo "Decoded content: $DECODED"