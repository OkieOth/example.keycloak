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

# How to create a mapper that includes the assigned groups in the token

1. Login into the Keycloak admin console `https://nginx.keycloak-example.loc/auth/admin/master/console/`
2. Switch to the realm you want to modify
3. Enter the 'Clients' section over the left menu
4. Go into the details of the client you want to modify
5. Go to the client scopes tab and activate the predefined scope for the specific client `{YOUR_CLIENT_NAME}-unauthenticated-dedicated`
6. Click the 'Add mapper' button and choose 'By Configuration'
7. Select there the 'Group Membership' line
8. Fill in the up popping form the 'Name' and 'Token Claim Name' fields, adjust the check-boxes as you need
9. Save and leave the form
10. Optional, test with the curl statement below

```bash
curl --request POST \
  --url https://nginx.keycloak-example.loc/auth/realms/test-realm/protocol/openid-connect/token \
  --cacert compose/certs/ca/ca_certificate.pem \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data 'client_id=test-client-unauthenticated' \
  --data "grant_type=password" \
  --data "username=homer.simpson" \
  --data "password=iAmHomer__"
```
