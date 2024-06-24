```bash
./buildDockerImage.sh

# create nginx related certs 
docker run --rm \
    -v $(pwd)/tmp:/output_dir \
    -v $(pwd)/..:/certs \
    -e OUTPUT=/output_dir \
    -e CONF=/certs/_conf \
    keycloak.examples/cert_builder:0.1.0 nginx
```
