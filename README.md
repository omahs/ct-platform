# ct-platform

This project aims to provide you with a fully-automated Kubernetes platform with focus on monitoring, security, accessibility, and ease-of-use.

# Setup

## Preparation

Make sure you have:
- Created a Github account with escalated permissions to create secrets.
- Created a GCP service account with escalated permissions to create resources. Note: please remove the escalated permissions when done with pipeline steps `day-0` and `day-1` for security reasons.
- Created a GCP storage bucket for storing Terraform state.
- Completed the GCP "OAuth consent screen" as it unfortunately can not be automated: https://console.cloud.google.com/apis/credentials/consent. Some comments:
  - You can use the "Internal" user type if you want just internal users to use the application.
  - Provide the `TF_VAR_domain` value you just set up in `.env` as the value for "Authorized domains".
  - Enable the following scopes:
    - https://www.googleapis.com/auth/userinfo.email
    - https://www.googleapis.com/auth/userinfo.profile
- Created a new RSA keypair with no passphrase for ArgoCD to access the Github repo. The public key of this keypair has to be then uploaded to the deploy keys of the repository; the private key has to be Base64-encoded and set as a Github secret variable `ARGOCD_CREDENTIALS_KEY`. You can generate the keypair by running:

```shell
ssh-keygen -b 2048 -t rsa -f /tmp/id_rsa -q -N "" -C ct-platform
```

### Secret variables

We try to keep as little secret variables as possible by design. For the sake of convenience, define the following secrets in your Github secrets section:

- `GOOGLE_CREDENTIALS` = Base64-encoded GCP service account credentials.
- `GOOGLE_PROJECT` = GCP project ID.
- `GOOGLE_REGION` = GCP project default region.
- `GOOGLE_BUCKET` = GCP bucket for storing Terraform state.
- `ARGOCD_CREDENTIALS_KEY` = Base64-encoded ArgoCD credentials private key from the previously generated keypair.

### Non-secret variables

For non-secret variables, simply edit/add them in the `.env` file, which gets parsed during pipeline runs, e.g.:

```dotenv
TF_VAR_name="ct-platform"
TF_VAR_domain="ctdapp.net"
TF_VAR_argocd_repo_url="git@github.com:hoprnet/infrastructure.git"
TF_VAR_argocd_credentials_url="git@github.com:hoprnet"
```

## Installation

Run the `day-0-apply` workflow in Github to install `day-0` resources such as:
- GKE Kubernetes cluster and node pools.
- IAM service accounts and bindings for the Kubernetes cluster.
- VPC networks and firewall rules for the Kubernetes cluster.

After successful completion of `day-0-apply`, run the `day-1-apply` workflow in Github to install `day-1` resources such as:
- ArgoCD helm chart and the initial ArgoCD app-of-apps.
- IAM service accounts and bindings for `day-2` applications, e.g. `cert-manager`, `external-dns`, etc.

## Uninstallation

Run the `day-1-destroy` workflow in Github to destroy `day-1`. After successful completion of `day-1-destroy`, run the `day-0-destroy` workflow in Github to destroy `day-0`. Note that some of the `day-2` cloud provider resources created by your apps, such as load balancers and DNS entries, might interfere with the current destruction of `day-1` and `day-0`. Either make sure everything in `day-2` is uninstalled cleanly, or you might have to do remove the stuck resources manually.

# Usage

## Access

1. Ensure your administrator has given enough permissions, e.g. `roles/container.developer` role is added to your IAM user.
2. Install and initialize Google Cloud CLI as described here: https://cloud.google.com/sdk/docs/install-sdk.
3. Follow the instructions on how to access the Kubernetes cluster here: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl.
   1. Run `gcloud auth login` and follow the on-screen instructions and pick the correct Google project.
   2. Run `gcloud container clusters get-credentials` and pass `name`, as well as `region` or `zone` flags.
4. Verify you're able to access the cluster and see the nodes by running: `kubectl get nodes`.

## Applications

These are just some convenience commands for developers that might come in handy. Please see the official upstream docs of the respective applications for more info.

### Sealed Secrets

Make sure you have the `kubeseal` binary installed: https://github.com/bitnami-labs/sealed-secrets. To generate a sealed secret run:

```shell
export NAMESPACE=your-namespace
export SECRET_NAME=your-secret

cat << EOF > /tmp/env
your-key=your-value
your-another-key=your-another-value
EOF

kubectl create secret generic -n $NAMESPACE $SECRET_NAME --from-env-file /tmp/env -oyaml --dry-run=client > /tmp/${SECRET_NAME}-secret.yaml
cat /tmp/${SECRET_NAME}.yaml | kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets | tee /tmp/${SECRET_NAME}-sealed-secret.yaml
```
