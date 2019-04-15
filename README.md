# update_dns.sh
This script is a plugin for Traefik, The Cloud Native Edge Router for Docker.
Traefik is capable of generating Let's Encrypt SSL certificates for every docker container that spins up.
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
      -v /data/docker/traefik/update_dns.sh:/update_dns.sh \
      -p 80:80 \
      -p 443:443 \
      -l traefik.frontend.rule=Host:traefik.example.com \
      -l traefik.port=8080 \
      -e EXEC_PATH=/update_dns.sh \
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
EXEC_PATH= The path and name of this script inside the container
CPANELDNS_AUTH_ID = Your CPanel's User ID
CPANELDNS_AUTH_PASSWORD = Your CPanel's User ID password
CPANELDNS_API = Your Cpanel's web adress including portnumber, mostly 2083
```

Usage example:
```
EXEC_PATH=/update_dns.sh
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
For an example see: https://github.com/kdeenkhoorn/docker-compose
