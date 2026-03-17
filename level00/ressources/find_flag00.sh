# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    find_flag00.sh                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tissad <tissad@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/06 18:24:12 by tissad            #+#    #+#              #
#    Updated: 2026/03/06 19:08:22 by tissad           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

RESULT=$(find / -user flag00 2>/dev/null)
echo $RESULT

# the file contains the Caesar code to user flag00 to get the flag for level01
# we need a function to decode the Caesar code, we can use the following function
function Caesar_cipher {
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
# print the content of each file found
for FILE in $RESULT; do
    echo "Content of $FILE:"
    cat $FILE
    DECODED=$(Caesar_cipher "$(cat $FILE)" 11)
    echo "Decoded content: $DECODED"
done

# decode the Caesar code and print the result
 