#!/usr/bin/bash

# Thank You Script

clear

cat << "EOF"
  _______ _                 _     __     __           _
 |__   __| |               | |    \ \   / /          | |
    | |  | |__   __ _ _ __ | | __  \ \_/ /__  _   _  | |
    | |  | '_ \ / _` | '_ \| |/ /   \   / _ \| | | | | |
    | |  | | | | (_| | | | |   <     | | (_) | |_| | |_|
    |_|  |_| |_|\__,_|_| |_|_|\_\    |_|\___/ \__,_| (_)
EOF

echo

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Thank You Message
echo -e "${YELLOW}-----------------------------------------------------${RESET}"
echo -e "${CYAN}Dear Eng. Mahmoud Helmi,${RESET}"
echo -e "${GREEN}We deeply appreciate your support, guidance,${RESET}"
echo -e "${GREEN}and unwavering dedication. ${RESET}"
echo -e "${BLUE}Your expertise inspires us to reach new heights every day.${RESET}"
echo -e "${BLUE}Thank you for being an exceptional mentor!${RESET}"
echo -e "${CYAN}With gratitude, 😊${RESET}"
echo -e "${CYAN}Ahmed Lebda, Mohamed Sobhi${RESET}"
echo -e "${YELLOW}-----------------------------------------------------${RESET}"

# Spinning cursor animation
sp='/-\|'
sc=0
for i in {1..15}; do
    printf "\r${CYAN}Thank You %s${RESET}" "${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
    sleep 0.1
done


