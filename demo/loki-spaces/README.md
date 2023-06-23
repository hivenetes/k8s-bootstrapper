# Loki and DigitalOcean Spaces Integration Demo

Loki Stack is a powerful log aggregation system that integrates with Grafana for visualization and monitoring. This tutorial will walk you through installing Loki Stack and using DigitalOcean Spaces(S3 compatible) Object Storage for application log retention.

## Prerequisites

Before you begin, make sure you have the following prerequisites installed:

- [Helm CLI](https://helm.sh/docs/intro/install/) - version 2.9.10 or later
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [Configure s3cmd with DO Spaces](https://docs.digitalocean.com/products/spaces/reference/s3cmd/)

## Step 1: Add the Loki Stack Helm Chart Repository

To install Loki Stack using Helm, we need to add the Grafana Helm Chart repository to Helm. Run the following command to add the repository:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

This command adds the Grafana Helm Chart repository to Helm, allowing us to install Loki Stack from this repository.

## Step 2: DigitalOcean Spaces Persistent Storage for Loki

In this step, we will enable `persistent` storage for `Loki.` and use the `DO Spaces`bucket to store the application logs.

Next, Let's configure `Helm` to set up Loki persistent storage via `DO Spaces,` as well as set the correct `schema.`

The final `Loki` storage setup configuration looks similar to this (please replace the `<>` placeholders accordingly):

```yaml
loki:
  enabled: true
  config:
    schema_config:
      configs:
        - from: "2020-10-24"
          store: boltdb-shipper
          object_store: aws
          schema: v11
          index:
            prefix: index_
            period: 24h
    storage_config:
      boltdb_shipper:
        active_index_directory: /data/loki/boltdb-shipper-active
        cache_location: /data/loki/boltdb-shipper-cache
        cache_ttl: 24h
        shared_store: aws
      aws:
        bucketnames: <YOUR_DO_SPACES_BUCKET_NAME_HERE>
        endpoint: <YOUR_DO_SPACES_BUCKET_ENDPOINT_HERE>  # in the following format: <region>.digitaloceanspaces.com
        region: <YOUR_DO_SPACES_BUCKET_REGION_HERE>      # short region name (e.g.: fra1)
        access_key_id: <YOUR_DO_SPACES_ACCESS_KEY_HERE>
        secret_access_key: <YOURDO_SPACES_SECRET_KEY_HERE>
        s3forcepathstyle: true
```

Run the following command to install Loki Stack:

  ```shell
HELM_CHART_VERSION="2.9.10"       

helm install loki grafana/loki-stack --version "${HELM_CHART_VERSION}" \
  --namespace=loki-stack \
  --create-namespace \
  -f "assets/loki-stack-values-${HELM_CHART_VERSION}.yaml"
```

This command installs Loki Stack with the specified Helm chart version. It creates a new namespace called "loki-stack" and deploys the Loki Stack components into that namespace. The values for the installation are provided through the `loki-stack-values-${HELM_CHART_VERSION}.yaml` file.

Finally, check the `Helm` release status:

```shell
helm ls -n loki-stack
```

The output looks similar to (`STATUS` column should display 'deployed'):

```text
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
loki    loki-stack      1               2023-06-22 20:49:28.619273 +0200 CEST   deployed        loki-stack-2.9.10        v2.6.1  
```

If everything goes well, you should see the `DO Spaces` bucket containing the `index` and `chunks` folders (the `chunks` folder is `fake,` which is a strange name - this is by design, when not running in `multi-tenant` mode).

![Loki DO Spaces Storage](assets/images/loki-storage-do-spaces.png)

## Step 4: Configure Grafana with Loki

In this step, you will add the `Loki` data source to `Grafana.` First, expose the `Grafana` web interface on your local machine.

```shell
kubectl --namespace loki-stack port-forward svc/loki-grafana 3000:80 
```

After the installation, you can retrieve the admin password for Grafana. Use the following command:

```bash
kubectl get secret --namespace loki-stack loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

This command retrieves the admin password for Grafana from the secret named "loki-grafana" in the "loki-stack" namespace. The password is then decoded from Base64 and displayed in the terminal.

Next, open a web browser on [localhost:3000](http://localhost:3000):

- Log in using username: `admin` and the password: `from the previous step.`
- Click the `Explore` icon from the left panel to access the application logs

## Step 5: Access Grafana Dashboards

Next, point your web browser to [localhost:3000](http://localhost:3000), and navigate to the `Explore` tab from the left panel. Select `Loki` from the data source menu, and run this query:

  ```json
  {container="vote-bot", namespace="emojivoto"}
  ```

  The output looks similar to the following:

  ![LogQL Query Example](assets/images/lql-first-example.png)

Perform another query, but this time filter the results to include only the `Error` message:

  ```json
  {container="web-svc",namespace="emojivoto"} |= "Error"
  ```

  The output looks similar to this (notice how the `Error` word is being highlighted in the query results panel):

  ![LogQL Query Example](assets/images/lql-second-example.png)  

## Step 6 - Setting Loki Storage Retention

In this step, we will set `DO Spaces` retention policies. Since we configured `DO Spaces` as the default storage backend for `Loki,` the same rules apply for every `S3` compatible storage type.

`Retention` is an essential aspect when configuring storage backends because `storage is finite.` While `S3` storage is not expensive and is somewhat `infinite` (it makes you think like that), having a retention policy set is good practice.

`S3` compatible storage has its own set of policies and rules for retention. In the `S3` terminology, it is called `object lifecycle.` On the official documentation page, you can learn more about the DO Spaces [bucket lifecycle](https://docs.digitalocean.com/reference/api/spaces-api/#configure-a-buckets-lifecycle-rules) options.

**Note:**

`S3CMD` is an excellent utility to inspect how many objects are present and the size of the `DO Spaces` bucket used for `Loki` retention. `S3CMD` also helps you see if the retention policies are working so far. Please follow the `DigitalOcean` guide for installing and setting up [s3cmd](https://docs.digitalocean.com/products/spaces/resources/s3cmd).

Setting the `Loki` storage bucket lifecycle is achieved via the `s3cmd` utility.

Next, you will use the `assets/manifests/loki_do_spaces_lifecycle.xml` configuration file to configure retention for the `Loki` bucket. The policy file contents look similar:

```xml
<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Rule>
    <ID>Expire old fake data</ID>
    <Prefix>fake/</Prefix>
    <Status>Enabled</Status>
    <Expiration>
      <Days>10</Days>
    </Expiration>
  </Rule>

  <Rule>
    <ID>Expire old index data</ID>
    <Prefix>index/</Prefix>
    <Status>Enabled</Status>
    <Expiration>
      <Days>10</Days>
    </Expiration>
  </Rule>
</LifecycleConfiguration>
```

The above `lifecycle` configuration, will automatically `delete` after `10 days`, all the objects from the `fake/` and `index/` paths in the `Loki` storage bucket. A `10 days` lifespan is chosen in this example, because it's usually enough for development purposes. For `production` or other critical systems, a period of `30 days` and even more is recommended.

Configure the `Loki` bucket lifecycle using `s3cmd`:

1. Next, open and inspect the `assets/manifests/loki_do_spaces_lifecycle.xml` file  using a text editor of your choice

2. Then, set the `lifecycle` policy (please replace the `<>` placeholders accordingly):

    ```shell
    s3cmd setlifecycle 04-setup-observability/assets/manifests/loki_do_spaces_lifecycle.xml s3://<LOKI_STORAGE_BUCKET_NAME>
    ```

3. Finally, check that the `policy` was set (please replace the `<>` placeholders accordingly):

    ```shell
    s3cmd getlifecycle s3://<LOKI_STORAGE_BUCKET_NAME>
    ```

After finishing the above steps, you can `inspect` the bucket `size` and `number` of objects via the `du` subcommand of `s3cmd` (the name is borrowed from the `Linux Disk Usage` utility). Please replace the `<>` placeholders accordingly:

```shell
s3cmd du -H s3://<LOKI_DO_SPACES_BUCKET_NAME>
```

The output looks similar to the following (notice that it prints the bucket size - `19M`, and the number of objects present - `2799`):

```text
19M    2799 objects s3://loki-storage-test/
```

Next, the `DO Spaces` backend implementation will automatically clean the objects for you based on the expiration date. You can always edit the policy if needed by uploading a new one.

## Conclusion

In this tutorial, we learned the following:

- Install `Loki` for application log monitoring in your `DOKS` cluster
- Use `LogQL` for querying logs. Data visualization on Grafana
- How to set up `persistent storage` and retention for `Loki` using `DigitalOcean Spaces.`

Happy log aggregation and monitoring with Loki Stack, Grafana and DO Spaces. 
