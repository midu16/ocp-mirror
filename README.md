# ocp-mirror


## How to build manually the container-base image for a specific OCP release

```bash
$ podman build -t oc_kubeadmin_mirror --build-arg OC_VERSION="4.12.25" --build-arg OC_MIRROR_VERSION="4.12.25" .
```

## How to run manually the container-base image

```bash
$ podman run -d --rm -it --name oc_mirror --net="host" --ipc=host -v /home/midu/.docker:/home/admin/.docker:z -v /app:/app/cluster-operators:z oc_kubeadmin_mirror:latest
```

## System behaviour

```bash
$ podman ps
CONTAINER ID  IMAGE                                    COMMAND               CREATED        STATUS            PORTS                   NAMES
342320a30585  localhost/oc_kubeadmin_mirror:latest     /usr/local/bin/oc...  3 minutes ago  Up 3 minutes ago                          oc_mirror
```

## Container logs

```bash
$ podman logs --tail 10 oc_mirror
uploading: file://openshift/release sha256:95c221b6db7c636ef393186070e33610c70d3f392496b319fb3bb782860de355 16.66KiB
uploading: file://openshift/release sha256:f85f856e4660944fcf44e35a1420eef55e4aa3d7d7f7bb4e8806be8b85096537 21.71MiB
uploading: file://openshift/release sha256:13d22793aaba19366b31951666fb198365418efb12d0c7c42af851a3242f8e5f 215.1MiB
uploading: file://openshift/release sha256:5742b67e7824f6c2182643b2d012291ca77d4280ccdd3de6f2378f4e19f9e29f 17.43KiB
uploading: file://openshift/release sha256:76d2839c958caebc47eb7a46a3140437d2a1635f6eebc3c394342068b7c2f47d 18.52KiB
uploading: file://openshift/release sha256:42b38474da8b3095ebbea049f11dc4d7ee6c9e775dc2f738e040b1cc32dae2fe 44.38MiB
uploading: file://openshift/release sha256:553a51ac201c62bfe80dc6cc0d652438d45ddaf2758c13944616e8f4e87957f3 9.022MiB
uploading: file://openshift/release sha256:b8eaf5cd7f51be24c51fdff1e79ba672c9cfa7e4650d3db3c60d28a534949b73 18.11KiB
uploading: file://openshift/release sha256:7a5d2c452f387fe325f5f27d3fdc7698cd68a3de1ca0c226246ccbc8e55cf987 18.49KiB
uploading: file://openshift/release sha256:5477f9bc8ede42fb3546f4de907c52750efd4433de56cfecaa8216b9c08d694c 31.89MiB
```

As it can be seen in the above output, the mirroring process has started.


