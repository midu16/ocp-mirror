# Use a base image with the desired Linux distribution (e.g., CentOS, Ubuntu)
FROM docker.io/library/fedora:38

# Set the maintainer 
MAINTAINER midu@redhat.com

# Set the working directory
WORKDIR /app

# Creating the admin user
RUN useradd -ms /bin/bash admin
# Adding the admin user to 'sudo' group
RUN usermod -a -G root admin

# Set environment variables for OpenShift client version and download URLs
ENV OC_VERSION="4.12.21"
ENV OC_MIRROR_VERSION="4.12.21"

# Use ARG to specify build-time arguments (optional)
ARG OC_VERSION
ARG OC_MIRROR_VERSION

# Use the ENV instruction to set environment variables during the build process
# These values will be replaced with the build-time ARGs if provided, otherwise
# they will retain the default values specified earlier.
ENV OC_VERSION=${OC_VERSION}
ENV OC_MIRROR_VERSION=${OC_MIRROR_VERSION}

# openshift-client-linux.tar.gz contains oc and kubeadm binaries
ENV OC_DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz
# oc-mirror 
ENV OC_MIRROR_DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/oc-mirror.tar.gz

# Install necessary tools (wget, tar)
RUN yum update -y && \
    yum install -y wget tar git make gcc findutils go-srpm-macros golang

# Download oc, kubeadm, and oc-mirror binaries
RUN wget -O /app/oc.tar.gz ${OC_DOWNLOAD_URL} && \
    tar -C /app -zxvf /app/oc.tar.gz && \
    mv /app/oc /usr/local/bin/oc && \
    mv /app/kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    wget -O /app/oc-mirror.tar.gz ${OC_MIRROR_DOWNLOAD_URL} && \
    tar -C /app -zxvf /app/oc-mirror.tar.gz && \
    mv /app/oc-mirror /usr/local/bin/oc-mirror && \
    chmod +x /usr/local/bin/oc-mirror

# Add /app to the PATH environment variable
ENV PATH="/usr/local/bin:${PATH}"

# Cleanup unnecessary files
RUN rm -rf /app/*

# Adding the user admin to 'sudo' group
RUN usermod -a -G root admin

# sudoers.d/admin creation
RUN mkdir -p /etc/sudoers.d/ && echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin
RUN chmod 044 /etc/sudoers.d/admin

# Switching to admin user
USER admin

# Switching to admin $HOME
WORKDIR /home/admin

# Creating the automation that is generating the cluster-operator bundle release 
COPY template_imageset_config.sh /app/template_imageset_config.sh
RUN chmod +x /app/template_imageset_config.sh


# Creating the mountpoint of .docker for config.json
VOLUME /home/admin/.docker

# creating the mountpoint of mirroring process for cluster operators and day2-operators
VOLUME /app/cluster-oprators

# Set the entrypoint of the container to /bin/bash
CMD ["/bin/bash"]
