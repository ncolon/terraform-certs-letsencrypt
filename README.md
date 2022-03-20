# terraform-certs-letsencrypt

Terraform module to create letsencrypt certificates for various DNS providers

Check sample tfvars file in [examples](https://github.com/ncolon/terraform-certs-letsencrypt/tree/main/examples) folder. Copy one of the files to the root folder and replace parameters with your values.

## Replacing OpenShift default ingress certificates

Your `app_subdomain` variable should be like: `apps.openshift.example.com` ([Documentation](https://docs.openshift.com/container-platform/4.8/security/certificates/replacing-default-ingress-certificate.html)).

```bash
# Run terraform
$ terraform init
$ terraform plan
$ terraform apply

# Get Certificates
$ terraform output --raw router_cert > router.crt
$ terraform output --raw router_key > router.key
$ terraform output --raw router_ca > router-ca.crt

# Create a config map that includes only the root CA certificate used to sign the wildcard certificate
$ oc create configmap custom-ca \
     --from-file=ca-bundle.crt=router-ca.crt \
     -n openshift-config
# Update the cluster-wide proxy configuration with the newly created config map
$ oc patch proxy/cluster \
     --type=merge \
     --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
# Create a secret that contains the wildcard certificate chain and key
$ oc create secret tls letsencrypt-certs \
    --cert=router.crt \
    --key=router.key \
    -n openshift-ingress
$ oc patch ingresscontroller.operator default \
    --type=merge -p \
    '{"spec":{"defaultCertificate": {"name": "letsencrypt-certs"}}}' \
    -n openshift-ingress-operator
```

## Replacing OpenShift default API server certificates

Your `app_subdomain` variable should be like: `api.openshift.example.com` ([Documentation](https://docs.openshift.com/container-platform/4.8/security/certificates/api-server.html)).

```bash
# Run terraform
$ terraform init
$ terraform plan
$ terraform apply

# Get Certificates
$ terraform output --raw router_cert > router.crt
$ terraform output --raw router_ca >> router.crt
$ terraform output --raw router_key > router.key

# Create a secret that contains the certificate chain and private key in the openshift-config namespace
$ oc create secret tls api-server-certs \
     --cert=router.crt \
     --key=router.key \
     -n openshift-config
# Update the API server to reference the created secret.
$ oc patch apiserver cluster \
     --type=merge -p \
     '{"spec":{"servingCerts": {"namedCertificates":
     [{"names": ["<FQDN>"], 
     "servingCertificate": {"name": "api-server-certs"}}]}}}'
```
 - **Note**: replace `<FQDN>` in this example it would be `api.openshift.example.com`.
