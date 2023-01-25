# ops-ci-codebuild-image

**Current version: v0.1.2**

Connect+ standard image for AWS CodeBuild.

## BOM

* Ubuntu 22.10
* stunnel 5.67
* aws-iam-authenticator 0.6.2
* kubectl 1.24.7
* awscli2 latest
* Python 3.10.* (NOTE: from Ubuntu 22.10)
* Docker CE (NOTE: incl. docker-compose and docker-buildx, from https://download.docker.com/linux/ubuntu/)
* dind latest
* pip latest
* Node.js 18.13.0

## To upgrade the components

NOTE: Do NOT forget to update this document as well to keep information in sync.

### Ubuntu 22.10

Update `./app/Dockerfile` to change `FROM ubuntu:xx.xx`. We should work with Ubuntu LTS release by default.

### Node.js 18.13.0

Check https://nodejs.org/en/download/ to see if there is any new version.

In case of a new version, update `./app/Dockerfile` to change `NODE_18_VERSION`.

### stunnel 5.67

Check https://www.stunnel.org/downloads.html to see if there is any new version.

In case of a new version, update `./app/Dockerfile` to change `STUNNEL_VERSION`. 

### AWS tools

#### aws-iam-authenticator 0.6.2 

Check https://github.com/kubernetes-sigs/aws-iam-authenticator/releases to see if there is any new patch for `aws-iam-authenticator`.
In case of a new patch, update `./app/Dockerfile` to change the corresponding URLS

#### kubectl 1.24.9

NOTE: according the [AWS document](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html), `kubectl` supports plus/minus
only one minor version difference of EKS control plane. We do not have the free choice to pick the `kubectl` version.

Check `/14-scmi/rcplus-scmi-infrastructure/infrastructure/roles/aws-resources/defaults/main.yml` for the current `eks_version` we use.
Note it down.

Check https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html and copy the URL of corresponding `kubectl` file, update
`./app/Dockerfile` to reflect it.

### Python packages

Run the shell command to update the `requirements.txt`: 
```bash
pip-compile --upgrade --no-header --quiet --allow-unsafe ./app/requirements.in > ./app/requirements.txt
```

NOTE: in case `pip-compile` is not found, manually install it with `pip install pip-tools` 
