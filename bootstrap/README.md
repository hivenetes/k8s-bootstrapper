## Bootstrap

The bootstrapper leverages the "App of Apps" pattern, and we use Helm to achieve this. 

```bash
.
├── Chart.yaml # boiler plate chart.yaml
├── README.md 
├── bootstrap-resources # ingress/cluster issuer
├── bootstrap.yaml # parent app 
├── templates # child app templates (one file per app)
└── values.yaml # bootstrapper chart overrides: enable/diable apps
```

In this case, the parent app "**bootstrap**" is installed along with its *child apps* which are rendered from `templates/` and `bootstrap-resources/` directories. 
By default, we have disabled most of the apps, but you can easily enable them by setting the flags in the [values.yaml](./values.yaml) 

```yaml
# values.yaml
# Global
domain: 
storageClass: "do-block-storage"
# Application specific
bots:
  enable: false
guestbook:
  enable: false
kyverno:
  enable: false  
logging:
  enable: false
observability:
  enable: false
  pdkey:
  storageSize: 50Gi
  retention: 5d
traefik:
  enable: true  
trivy:
  enable: false
```
> Note: Save changes to the file as deemed fit and push the changes to the git repository. The bootstrapper follows a strict GitOps workflow, so all the changes need to be pushed to git to reflect the changes in the Kubernetes cluster.
