if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi
RED='\033[0;31m'
GREEN='\e[92m'
NC='\033[0m'
ENABLED_PHP_VERSION=$(ls /etc/apache2/mods-enabled/ | grep -Poi '(?<=php)[0-9].[0-9]' | uniq)
AVAILABLE_PHP_VERSIONS=($(ls /etc/apache2/mods-available/ | grep -Poi '(?<=php)[0-9].[0-9]' | uniq | awk '{print $0}' | tr '\n' ' '))
if [[ -z ${ENABLED_PHP_VERSION} ]]; then
    printf "There is ${RED}no${NC} PHP Module activated.\n"
else
    printf "%sThe current activated PHP Version is : ${RED}${ENABLED_PHP_VERSION}${NC}\n" "-"
fi
printf "%sAvailable PHP Versions: \n" "-"
ITER=0
for i in ${AVAILABLE_PHP_VERSIONS[@]}; do
    printf "[${RED}$ITER${NC}] ${NC}%s\n" "${i}"
    ITER=$(expr $ITER + 1)
done
printf "Enter The Number of the php Version you want to activate: "
read CHOSEN_VERSION
if ! [[ "$CHOSEN_VERSION" =~ ^[0-9]+$ ]]; then
    printf "The Input should be a Number, ${RED}%s${NC} was given.\n" "${CHOSEN_VERSION}"
    exit 1
fi
if [[ ${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]} == ${ENABLED_PHP_VERSION} ]]; then
    printf "PHP ${RED}%s${NC} is already enabled!\n" "${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]}"
    exit 1
fi
if [[ ${#AVAILABLE_PHP_VERSIONS[@]} < ${CHOSEN_VERSION} ]]; then
    printf "Your input is out of rang\n"
    exit 1
fi
# TODO replace fake succss status with actual one
SUCCESS="${GREEN}success${NC}\n"
printf "Disabling PHP${RED}${ENABLED_PHP_VERSION}${NC}...."
a2dismod php${ENABLED_PHP_VERSION} &> /dev/null
printf "${SUCCESS}"
printf "Enabling PHP${RED}${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]}${NC}...."
a2enmod php${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]} &> /dev/null
printf "${SUCCESS}"
printf "Restarting Apache Web-server...."
apache2ctl restart &> /dev/null
printf "${SUCCESS}"
printf "Removing global php${ENABLED_PHP_VERSION} binary...."
rm /usr/bin/php &> /dev/null
printf "${SUCCESS}"
printf "linking php${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]} to global binary...."
ln -s /usr/bin/php${AVAILABLE_PHP_VERSIONS[${CHOSEN_VERSION}]} /usr/bin/php &> /dev/null
printf "${SUCCESS}"

