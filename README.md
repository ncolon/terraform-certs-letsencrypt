# terraform-certs-letsencrypt

Terraform module to create letsencrypt certificates for various DNS providers

Check sample tfvars file in [examples](https://github.com/ncolon/terraform-certs-letsencrypt/tree/main/examples) folder. Copy one of the files to the root folder and replace parameters with your values.

```bash
# Run terraform
$ terraform init
$ terraform plan
$ terraform apply

# Get Certificates
$ terraform output --raw router_cert > router.crt
$ terraform output --raw router_key > router.key
$ terraform output --raw router_ca > router-ca.crt

# Apply Certificates to OpenShift Cluster
$ oc create secret tls letsencrypt-certs \
    --cert=router.crt \
    --key=router.key \
    -n openshift-ingress
$ oc patch ingresscontroller.operator default \
    --type=merge -p \
    '{"spec":{"defaultCertificate": {"name": "letsencrypt-certs"}}}' \
    -n openshift-ingress-operator

$ cat << EOF > user-ca-bundle.yaml
apiVersion: v1
kind: ConfigMap
data:
  ca-bundle.crt: |
$(cat router-ca.crt | sed 's/^/    /')
metadata:
  name: user-ca-bundle
  namespace: openshift-config
EOF
$ oc apply -f user-ca-bundle.yaml
$ oc patch proxy cluster --type=merge -p '{"spec": {"trustedCA": {"name": "user-ca-bundle"}}}'
```
