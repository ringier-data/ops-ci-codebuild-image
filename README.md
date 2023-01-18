# ops-ci-codebuild-image

**Current version: v0.0.2**

Connect+ standard image for AWS CodeBuild.

## BOM

* Ubuntu 22.04
* stunnel 5.67
* aws-iam-authenticator 0.6.2
* kubectl 1.24.7
* awscli2 latest
* Python 3.10.* (NOTE: Ubuntu 22.04 latest)
* pip latest
* Node.js 18.13.0

## To upgrade the components

NOTE: Do NOT forget to update this document as well to keep information in sync.

### Ubuntu 22.04

Update `./app/Dockerfile` to change `FROM ubuntu:xx.xx`. We should work with Ubuntu LTS release by default.

### stunnel 5.67

Check https://www.stunnel.org/downloads.html to see if there is any new version.

In case of a new version, update `./app/Dockerfile` to change `STUNNEL_VERSION`. Do not forget to change
`STUNNEL_SHA256` at the same time. The SHA256 value can be found from the download page mentioned above. 

### AWS tools

#### aws-iam-authenticator 0.6.2 

Check https://github.com/kubernetes-sigs/aws-iam-authenticator/releases to see if there is any new patch for `aws-iam-authenticator`.
In case of a new patch, update `./app/Dockerfile` to change the corresponding URLS

#### kubectl 1.24.7

NOTE: according the [AWS document](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html), `kubectl` supports plus/minus
only one minor version difference of EKS control plane. We do not have the free choice to pick the `kubectl` version.

Check `/14-scmi/rcplus-scmi-infrastructure/infrastructure/roles/aws-resources/defaults/main.yml` for the current `eks_version` we use.
Note it down.

Check https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html and copy the URL of corresponding `kubectl` file, update
`./app/Dockerfile` to reflect it.

### Docker 20.10.22 && docker-compose 2.15.1 && dind commit 1f32e3c95d72a29b3eaacba156ed675dba976cb5

Check https://github.com/docker/compose/releases to see if there is any version of `docker-compose`. If yes, update `./app/Dockerfile` to
change `DOCKER_COMPOSE_VERSION`

Check https://github.com/docker-library/docker/blob/master/versions.json, if there is a new version of Docker Engine:
* update `./app/Dockerfile` to change `DOCKER_VERSION`
* update `./app/Dockerfile` to change `DIND_COMMIT`

### Python packages

Run the shell command to update the `requirements.txt`: 
```bash
pip-compile --upgrade --no-header --quiet --allow-unsafe ./app/requirements.in > ./app/requirements.txt
```

NOTE: in case `pip-compile` is not found, manually install it with `pip install pip-tools` 
