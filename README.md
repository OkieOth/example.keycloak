![WIP](https://img.shields.io/badge/work%20in%20progress-red)

# example.keycloak

This is a quick' dirty docker-compose example that combines a 
custom ca with nginx and keycloak.

For the moment nginx doesn't validate the token our check authentication.
That task would be on the services and a possible UI.

# Usage
* put `nginx.keycloak-example.loc` in your `/etc/hosts` with a valid IP
* start the env `bin/compose_env.sh start`
* Import the Root CA in your browser `compose/certs/ca/ca_certificate.pem`
* open in browser `https://nginx.keycloak-example.loc/auth/admin/master/console/`