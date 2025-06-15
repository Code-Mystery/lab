# General
I created this little test setup to try out Veleros capabilities of backing up and restore k8s clusters with dynamically provisioned PVs. Turns out it works fantastically.

# Prerequisites
- k3d installed
- docker desktop with k8s installed

# Installation Guide
1. Create cluster "cluster-source" by running `k3d cluster create cluster-source --agents 1`
2. Create cluster "cluster-target" by running `k3d cluster create cluster-target --agents 1`
3. Apply file minio.yaml to cluster "docker-desktop" by running `kubectl apply -f minio.yaml` to create the minio instance which will be used to store the backuped cluster
4. Switch to cluster "cluster-source" and apply file dynamic-pv-test.yaml by running `kubectl apply -f dynamic-pv-test.yaml` to create the resources which will be backuped
5. Log in to minio via localhost:30091 -- User: minioadmin | Password: minioadmin
6. Create bucket "velero"
7. Switch to cluster "cluster-source" and run `velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.8.0 --bucket velero --use-node-agent --secret-file ./minio-credentials --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://host.k3d.internal:30090`
8. Run `velero backup create cluster-source-backup --include-namespaces test`
9. Switch to cluster "cluster-target" and run `velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.8.0 --bucket velero --use-node-agent --secret-file ./minio-credentials --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://host.k3d.internal:30090`
10. Run `velero backup describe cluster-source-backup`
11. Run `velero restore create --from-backup cluster-source-backup`
12. Check out all the restored resources on the "cluster-target" cluster
13. Delete cluster "cluster-source" with `k3d cluster delete cluster-source`
14. Delete cluster "cluster-target" with `k3d cluster delete cluster-target`
15. Switch to cluster "docker-desktop" and remove minio deploymen with `kubectl delete -f minio.yaml`

ATTENTION: add "127.0.0.1 host.k3d.internal" to /etc/hosts on your local machine
