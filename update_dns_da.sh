#!/bin/sh
 
exec_curl () {
   URL="$1"
   HEADER="Authorization: Basic $(printf "%s" "${PANEL_AUTH_ID}:${PANEL_AUTH_PASSWORD}" | base64)"
   RESPONSE=$(wget -q -O - --user-agent="update_dns_da/v1.0" --header "${HEADER}" --post-data="${URL}" ${PANEL_URL}CMD_API_DNS_CONTROL)
   if [ $(echo ${RESPONSE} | grep -c "error=0") -eq 0 ];
      then 
         echo "[error] wget command output not as expected." 
         echo "${RESPONSE}"
         exit 1
      else
         exit 0
      fi 
}

dns_da_add () {
   HOST="$1"
   CHALLENGE="$2"
   CMD="domain=${DNS_DOMAIN}&action=add&type=TXT&name=${HOST}&value=\"${CHALLENGE}\""
   exec_curl "${CMD}"
}

dns_da_rm () {
   HOST="$1"
   CHALLENGE="$2"
   CMD="domain=${DNS_DOMAIN}&action=select&txtrecs0=name=${HOST}&value=\"${CHALLENGE}\""
   exec_curl "${CMD}"
}


####################  Main functions below ##################################

OPTION=$1
HOST="$(echo $2 | sed "s/\.${DNS_DOMAIN}.*$//")"
CHALLENGE=$3

case "${OPTION}" in
     present)
          dns_da_add "${HOST}" "${CHALLENGE}"
          ;;
     cleanup)
          dns_da_rm "${HOST}" "${CHALLENGE}"
          ;;
     timeout)
          echo "{\"timeout\": 240, \"interval\": 30}"
          ;;
     *)
          echo "$1 Unknown option."
          exit 1
          ;;
esac
