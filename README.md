# terraform-certs-letsencrypt

Terraform module to create letsencrypt certificates for various DNS providers

Check sample tfvars file in [examples](https://github.com/ncolon/terraform-certs-letsencrypt/tree/main/examples) folder

Once you've generated the certificates, apply them to an OpenShift Cluster

```bash
$ terraform output --raw router_cert > router.crt
$ terraform output --raw router_key > router.key
$ oc create secret tls letsencrypt-certs \
    --cert=router.crt \
    --key=router.key \
    -n openshift-ingress
$ oc patch ingresscontroller.operator default \
    --type=merge -p \
    '{"spec":{"defaultCertificate": {"name": "letsencrypt-certs"}}}' \
    -n openshift-ingress-operator
```
