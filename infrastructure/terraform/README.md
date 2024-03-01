# Infrastructure Automation on DigitalOcean using Terraform

## Overview

This section describes the usage of [Terraform](https://www.terraform.io/) to provision the DigitalOcean infrastructure.

The Terraform code provided in this repository provisions the following:

- DigitalOcean Kubernetes cluster [digitalocean-kubernetes.tf](./digitalocean-kubernetes.tf)
- DigitalOcean Container Registry [digitalocean-container-registry.tf](./digitalocean-container-registry.tf)
- Input variables and main module behavior is controlled via [variables.tf](./variables.tf)
- Install and configure [Argo CD](https://argo-cd.readthedocs.io/en/stable/) via [argo-helm-config.tf](./argocd-helm-config.tf)

All essential aspects are configured via Terraform input variables. In addition, a [bootstrapper.tfvars.sample](./bootstrapper.tfvars.sample) file is provided to get you started quickly.

<p align="center">
<img src="../../docs/assets/infra-doks-docr.png" alt="bootstrapper-infra"/>
</p>

## Requirements

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- [doctl CLI](https://docs.digitalocean.com/reference/doctl/how-to/install/)
- [DigitalOcean access token](https://docs.digitalocean.com/reference/doctl/how-to/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## Using Terraform to Provision Infrastructure on DigitalOcean

Follow the below steps to get started:

1. Clone this repo and change your current directory to `infrastructure/terraform`

2. Initialize Terraform backend:

    ```shell
    terraform init
    ```

3. Copy and rename the `bootstrapper.tfvars.sample` file to `bootstrapper.tfvars`:

    ```shell
    cp bootstrapper.tfvars.sample bootstrapper.tfvars
    ```

4. Open the `bootstrapper.tfvars` file and adjust settings according to your needs using a text editor of your choice (preferably with [HCL](https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md) lint support). To see the default values, look at `variables.tf`.

     **Important:** 
    You will need to replace the `do_token` with your own Personal Access Token.

    List Kubernetes versions that can be used with DigitalOcean clusters.

    ```console
    doctl k8s options versions
    ```

    Choose the corresponding `Slug` and set the `doks_k8s_version` variable with the chosen Slug. If you forget to change this, and the default version in `variables.tf` no longer is supported, you will get an error saying "The argument "version" is required, but no definition was found."

    Set the `doks_cluster_region` to region you'd like from the following list:
   
    ```console
    doctl kubernetes options regions
    ```

    Each worker node creates a Droplet. Ensure that your total number of nodes, `min_nodes`, and `max_nodes` are not above this. To check what your Droplet limit is run the following command:
    
    ```console
    doctl account get
    ```
    
    To see how many Droplets you already have you can do:

    ```console
    doctl compute droplet list --no-header | wc -l
    ```

    You may submit a request for a limit increase.

5. Use `terraform plan` to inspect infra changes before applying:

    ```shell
    terraform plan -var-file=bootstrapper.tfvars -out tf-bootstrapper.out
    ```

6. If you're happy with the changes, issue `terraform apply`:

    ```console
    terraform apply "tf-bootstrapper.out"
    ```

    If everything goes as planned, you should be able to see all infrastructure components provisioned and configured as stated in the `bootstrapper.tfvars` input configuration file.

7. Use [doctl](https://docs.digitalocean.com/reference/doctl/reference/kubernetes/) to update your Kubernetes context

    ```bash
    # <cluster-id> can be found in the output of the Terraform module
    doctl kubernetes cluster kubeconfig save <cluster-id>
    ```

## Authenticate with DigitalOcean Container Registry

Follow this [one-click guide](https://docs.digitalocean.com/products/container-registry/how-to/use-registry-docker-kubernetes/#kubernetes-integration) to integrate the registry with the Kubernetes cluster.

[**Next steps »**](../../bootstrap/README.md)
