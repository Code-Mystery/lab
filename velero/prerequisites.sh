#!/bin/bash

k3d cluster create cluster-a --agents 1
k3d cluster create cluster-b --agents 1

velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.8.0 --bucket velero --secret-file ./minio-credentials --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://host.k3d.internal:30091
