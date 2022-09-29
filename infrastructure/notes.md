

## 
- spin up cluster and DOCR using terraform
- connect the docr with doks
- docker running

```bash
doctl registry login
doctl kubernetes cluster kubeconfig save c5c13d02-d688-4aed-bd07-c4a75cdf03f4
docker build -t registry.digitalocean.com/abhi-playground-cr/app:v0.0.1 .
docker push registry.digitalocean.com/abhi-playground-cr/app:v0.0.1
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
   name: redis-pod
spec:
   containers:
   - name: redis-container01
     image: registry.digitalocean.com/abhi-playground-cr/app:v0.0.1
     ports:
     - containerPort: 6379
EOF
```

TODO:
gh-actions to bootstrap!