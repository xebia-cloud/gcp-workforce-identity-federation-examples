# Google Cloud Workforce Identity Federation examples

This repository hosts Terraform examples to set up Workforce Identity Federation with your identity provider (IdP).

## Workforce Identity Federation

Workforce Identity Federation lets you use an external identity provider (IdP) to authenticate and authorize a workforce—a group of users, such as employees, partners, and contractors—using IAM, so that the users can access Google Cloud services. With Workforce Identity Federation you don't need to synchronize user identities from your existing IdP to Google Cloud identities. Workforce Identity Federation extends Google Cloud's identity capabilities to support syncless, attribute-based single sign on. Source: https://cloud.google.com/iam/docs/workforce-identity-federation


## Example usage

1. Grant required Google Cloud permissions

    - IAM Workforce Pool Admin (roles/iam.workforcePoolAdmin)

2. Grant required IdP permissions

   - *Entra ID* Application Developer

3. Enter Terraform variables

    Enter the required variables in `variables.tf`-file

4. Deploy resources

    ```bash
    terraform init
    terraform apply
    ```

    > Authenticate using your prefered mean e.g. `gcloud auth application-default login`, `az login` and so forth.

5. Use the Federated Console url of the Workforce Identity Federation provider to sign in

    https://auth.cloud.google/signin/locations/global/workforcePools/{POOL_ID}/providers/{PROVIDER_ID}?continueUrl=https://console.cloud.google/

    > The full link can be found in the Google Cloud console: https://console.cloud.google.com/iam-admin/workforce-identity-pools


    