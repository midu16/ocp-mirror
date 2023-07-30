# ocp-mirror


## How to build manually the container-base image for a specific OCP release

```bash
$ podman build -t oc_kubeadmin_mirror --build-arg OC_VERSION="4.12.25" --build-arg OC_MIRROR_VERSION="4.12.25" .
```

## How to run manually the container-base image

```bash
$ podman run -d --rm -it --name oc_mirror --net="host" --ipc=host -v /home/midu/.docker:/home/admin/.docker:z -v /app:/app/cluster-operators:z oc_kubeadmin_mirror:latest
```

