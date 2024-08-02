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
# Create a user and password for authentication
# mkdir -p /opt/docker-registry/auth
# cd /opt/docker-registry/auth
# htpasswd -bnB admin password >> htpasswd
# docker run -d -p 5000:5000 --restart=always --name registry -v /home/sdp/registry.yaml:/etc/docker/registry/config.yml -v /home/sdp/image_storage:/var/lib/registry -v /home/sdp/registry/certs:/certs registry:2
```

Add below configuration to registry.yaml:
```
auth:
  htpasswd:
    realm: basic-realm
    path: /auth/htpasswd
```

Use docker command to login to registry:
```
# docker login -u admin -p password localhost:5000
Login Succeeded
```