# ops-ci-codebuild-image

**Current version: v0.2.4**

Connect+ standard image for AWS CodeBuild.

## Usage

The outcome of this repo is a Docker image, being used by `ops-ci-codebuild` for all RC+ CodeBuild projects.

To avoid the chicken-egg constraint, this image itself is not to be built with CodeBuild. Instead, a Github workflow with GitHub Actions
is configured to build the image and push the result to ECR with additionally a `latest` tag when anything committed to `main` branch.  

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
* poetry latest
* Node.js 18.13.0

## To upgrade the components

NOTE: Do NOT forget to update this document as well to keep information in sync.

### Ubuntu 22.10

Update `./app/Dockerfile` to change `FROM ubuntu:xx.xx`.

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

Run the shell command (LOCALLY, because it is a development instead of deployment activity) to update the `poetry.lock` file: 
```bash
cd ./app && poetry lock && poetry export --without-hashes --without-urls  | grep -iv pywin32= | sed -E 's/(.*)\ ;.*/\1/g' > requirements.txt && cd ..
```

NOTE: here we use `poetry` to manage the dependencies, because of the well-known conflicts between `dvc[s3]` and `botocore`, using
`pip-tools` would never resolve the dependencies into a state that all the constraints are satisfied, irrelevant from which resolver
strategy we chose.

Although `poetry.lock` is the source of truth for the container image build, we produce a `requirements.txt` here to serve as the bill
of material for human reference.
