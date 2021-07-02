# update_dns_traefik
In this repository you will find plugin scripts for Traefik, The Cloud Native Edge Router for Docker, to manage DNS panels.
Traefik is capable of generating Let's Encrypt SSL certificates for every docker container that spins up.

# update_dns_cpanel.sh
This update_dns_cpanel.sh script is a plugin for Traefik so it can manage DNS TXT challange records in your DNS.
To support this function for CPanel DNS this script can be used as an 'EXEC' provider.

To use this script you have to add the following part to your `traefik.toml` file to activate it:

```
[acme]
email = "my-email@example.com"
storage = "acme.json"
entryPoint = "https"
onHostRule = true
  [acme.dnsChallenge]
  provider = "exec"
  delayBeforeCheck = 0
```

And at run time pass the EXEC_PATH variable for the script and your credentials for CPanel:

```
docker run -d \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /data/docker/traefik/traefik.toml:/traefik.toml \
      -v /data/docker/traefik/acme.json:/acme.json \
      -v /data/docker/traefik/update_dns_cpanel.sh:/update_dns_cpanel.sh \
      -p 80:80 \
      -p 443:443 \
      -l traefik.frontend.rule=Host:traefik.example.com \
      -l traefik.port=8080 \
      -e EXEC_PATH=/update_dns_cpanel.sh \
      -e CPANELDNS_AUTH_ID="${CPANELDNS_AUTH_ID}" \
      -e CPANELDNS_AUTH_PASSWORD="${CPANELDNS_AUTH_PASSWORD}" \
      -e CPANELDNS_API="${CPANELDNS_API}" \
      --network proxy \
      --name traefik \
      --restart always \
      traefik:alpine
```

Where:
```
EXEC_PATH = The path and name of this script inside the container
CPANELDNS_AUTH_ID = Your CPanel's User ID
CPANELDNS_AUTH_PASSWORD = Your CPanel's User ID password
CPANELDNS_API = Your Cpanel's web adress including portnumber, mostly 2083
```

Usage example:
```
EXEC_PATH=/update_dns_cpanel.sh
export CPANELDNS_AUTH_ID="MY_Account"
export CPANELDNS_AUTH_PASSWORD="My_Password"
export CPANELDNS_API="https://www.example.com:2083/"
```

Docker-compose:
If these variables are put into a hidden file they can be used inside a docker-compose file like this:
```
env_file:
 - /data/docker/traefik/.credentials.sh
```

# update_dns_da.sh
This update_dns_da.sh script is a plugin for Traefik so it can manage DNS TXT challange records in your DNS.
To support this function for DirectAdmin DNS this script can be used as an 'EXEC' provider.

To use this script you have to add the following part to your `traefik.toml` file to activate it:

```
[acme]
email = "my-email@example.com"
storage = "acme.json"
entryPoint = "https"
onHostRule = true
  [acme.dnsChallenge]
  provider = "exec"
  delayBeforeCheck = 0
```

And at run time pass the EXEC_PATH variable for the script and your credentials for DirectAdmin:

```
docker run -d \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /data/docker/traefik/traefik.toml:/traefik.toml \
      -v /data/docker/traefik/acme.json:/acme.json \
      -v /data/docker/traefik/update_dns_da.sh:/update_dns_da.sh \
      -p 80:80 \
      -p 443:443 \
      -l traefik.frontend.rule=Host:traefik.example.com \
      -l traefik.port=8080 \
      -e EXEC_PATH=/update_dns_da.sh \
      -e DNS_DOMAIN=${DOMAIN_TO_ADD_RECORD_TO} \
      -e EXEC_PROPAGATION_TIMEOUT=240 \
      -e EXEC_POLLING_INTERVAL=30 \
      -e PANEL_AUTH_ID=${PANEL_USERNAME} \
      -e PANEL_AUTH_PASSWORD=${PANEL_PASSWORD} \
      -e PANEL_URL=${PANEL_URL} \
      --network proxy \
      --name traefik \
      --restart always \
      traefik:alpine
```

Where:
```
EXEC_PATH = The path and name of this script inside the container
DNS_DOMAIN = The domainname for the SSL certificates
EXEC_PROPAGATION_TIMEOUT = The time needed by DirectAdmin to propagate the records in seconds
EXEC_POLLING_INTERVAL = The interval the records have to be checked in seconds
PANEL_AUTH_ID = Your AdminPanel's user ID
PANEL_AUTH_PASSWORD = Your AdminPanel's password
PANEL_URL = Your AdminPanel's URL
```

Docker-compose:
If these variables are put into a hidden file they can be used inside a docker-compose file like this:
```
env_file:
 - /data/docker/traefik/.credentials.sh
```

#Tips 

## WGET generates an invalid header message
wget generates an error complaining the header is invalid when your password or api key is to long. Because of this the base64 command wil split into multiple lines resulting in a header error.  
What you can do in that case is pick a shorter password or api key or modify the header generation code a bit.

You can do the following like i have done:

1) Log on to a linux box and generate the base64 encoded `[username]:[password]` string your self with
```
printf "%s" "[USERNAME]:[PASSWORD]" | base64 -w 0
```
2) Create a new variable like `PANELDNS_AUTH_STRING` in your `.credentials.sh` file like:
```
PANELDNS_AUTH_STRING=[BASE64_ENCODED_STRING]
```
3) Replace the line staring with `HEADER=` with:
```
HEADER="Authorization: Basic ${PANELDNS_AUTH_STRING}"

```
And you're done!

For an usage example see: https://github.com/kdeenkhoorn/docker-compose
