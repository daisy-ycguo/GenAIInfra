# Guidances and How to

## Registry

### How to handle pulling image errors?

Let's suppose `opean/codetrans:latest` has pulling issue.

1. Go to `$image_storage/docker/registry/v2/repositories/opea/codetrans/_manifests/tags`
2. Delete the folder of latest by `rm -rf latest`
3. Restart docker registry
4. Push the image again `docker push opean/codetrans:latest`

### How to config username and password of local registry?

```
# Creating TLS Certs

```