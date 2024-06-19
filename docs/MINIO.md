# MinIO Configuration

MinIO is a package that deploys a full-featured and simplified S3 object storage API and service. This package is only deployed on top of the [Local Path Provisioner](./LOCAL-PATH.md) or [Longhorn](./LONGHORN.md) storage solutions.

## Usage

By default, the provided MinIO instance provisions a minimal set up that includes a single bucket named `uds` that is accessible by the `uds` user:

```yaml
users:
  - accessKey: uds
    secretKey: uds-secret
    policy: readwrite-username-policy
```

You can port-forward ```uds zarf tools kubectl port-forward service/minio 9000:9000 -n minio``` to access the service externally from where you can use any S3-compatible client to configure your buckets or the MinIO (`mc`) cli to handle other configurations, users or policy management. Similar functions could be performed in-cluster as well via a Job or other means.

## Quickstart

```bash
# port-forward the MinIO service
uds zarf tools kubectl port-forward service/minio 9000:9000 -n minio

# Get the MinIO Admin Credentials
ROOT_PASSWORD=$(uds zarf tools kubectl get secret "minio" -n "minio" -o json | jq -r '.data.rootPassword' | base64 --decode)
ROOT_USER=$(uds zarf tools kubectl get secret "minio" -n "minio" -o json | jq -r '.data.rootUser' | base64 --decode)
```

### MinIO CLI

```bash
# Configure MC Alias
set +o history
mc alias set my-alias http://localhost:9000 "$ROOT_USER" "$ROOT_PASSWORD"
set -o history

# Get Buckets
mc ls my-alias

# Create a Bucket
mc mb my-alias/mybucket

# Create a User (mc cli only)
mc admin user add my-alias bob bobs-secret

# List policies
mc admin policy ls my-alias
```

Please see the [reference](https://min.io/docs/minio/linux/reference/minio-mc-admin.html) docs for the mc tool for further administrative usage examples.

## Configuring MinIO in This Package

The MinIO config provided in this package cannot be modified at deploy time without building a custom version of the package that overrides the values file defaults in [minio-values.yaml](../packages/minio/values/minio-values.yaml).

Example Values File:

```yaml
# buckets
buckets:
  - name: my-bucket
    policy: none
    purge: false
  - name: other-bucket
  - name: third-bucket
# users
users:
  - accessKey: console
    secretKey: "console-secret"
    policy: consoleAdmin
  - accessKey: logging
    existingSecret: my-secret
    existingSecretKey: password
    policy: readwrite
```

Please see the MinIO chart's [values](https://github.com/minio/minio/blob/master/helm/minio/values.yaml) file for more examples.

## Configuring MinIO in a Bundle

If you are building a uds bundle and are using uds-k3d as a base for that bundle, you might want to configure the bundle to be able to customize the MinIO deployment either at bundle create or deploy time.

### Configure Create Time MinIO Overrides

This example will override the default users and buckets provisioned in the MinIO instance. These are bundle create time overrides.

> **_NOTE:_** Because the underlying fields for `users` and `buckets` are arrays, overriding these options via values will result in the default `uds` user and `uds` bucket not being created.

```yaml
# uds-bundle.yaml

[...]
    overrides:
      minio:
        values:
        - path: "users"
          value:
            - accessKey: console
              secretKey: "console-secret"
              policy: consoleAdmin
            - accessKey: logging
              secretKey: "logging-secret"
              policy: readwrite
        - path: "buckets"
          value:
            - name: "loki"  
            - name: "velero"
            - name: "myapp"
            - name: "myotherapp"
```

### Configure Deploy Time MinIO Overrides

This example will show how to expose the ability to override the default users, policies, service accounts and buckets provisioned in the MinIO instance at bundle deploy time.

```yaml
# uds-bundle.yaml

packages:
  - name: minio
    repository: ghcr.io/justinthelaw/packages/minio
    # x-release-please-start-version
    ref: "0.4.2"
    # x-release-please-end
    overrides:
      minio:
        variables:
          - name: buckets
            description: "Set MinIO Buckets"
            path: buckets
          - name: svcaccts
            description: "MinIO Service Accounts"
            path: svcaccts
          - name: users
            description: "MinIO Users"
            path: users
          - name: policies
            description: "MinIO policies"
            path: policies
```

Once the bundle has been created the deployer can customize the resources deployed by providing the values to the uds-config.yaml

```yaml
bundle:
  deploy:
    zarf-packages:
      minio:
        set:
          buckets:
            - name: "my-favorite-bucket"
                policy: "public"
                purge: false
          users:
            - accessKey: console
                secretKey: "console-secret"
                policy: consoleAdmin
          policies:
            - name: example-policy
              statements:
                - effect: Allow # this is the default
                  actions:
                    - "s3:AbortMultipartUpload"
                    - "s3:GetObject"
                    - "s3:DeleteObject"
                    - "s3:PutObject"
                    - "s3:ListMultipartUploadParts"
                  actions:
                    - "s3:CreateBucket"
                    - "s3:DeleteBucket"
                    - "s3:GetBucketLocation"
                    - "s3:ListBucket"
                    - "s3:ListBucketMultipartUploads"
```

## Additional Info

- [MinIO Repository](https://github.com/minio/minio)
- [MinIO Documentation Website](https://min.io/docs/minio/kubernetes/upstream/)
