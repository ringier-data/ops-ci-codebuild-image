FROM ubuntu:22.04

COPY . /tmp/src
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# NOTE 1: for the Ubuntu packages installed in the official 22.04 Docker image, the list can be found at:
#    https://git.launchpad.net/cloud-images/+oci/ubuntu-base/commit/?h=dist-jammy-amd64-20221130&id=5107d90663ceb24789a9fa19136b0753c5651aa0
#    Generally, start from https://git.launchpad.net/cloud-images/+oci/ubuntu-base/refs/tags to get the corresponding commit
# NOTE 2: the AWS standard CodeBuild images uses ppa:git-core/ppa to install the newest version of git. To use the ppa
#    registry, we will have to install package software-properties-common, which implies the installation of Python3
#    and quite some other packages. As we will install a Python interpreter later with pyenv, the redundancy should be
#    avoided. To reduce the eventual image size, we take the Ubuntu 22.04 standard git, so that software-properties-common
#    is not needed.
RUN set -ex \
    #
    # Setup environment (we intentionally avoid using ARG or ENV to avoid extra image layer)
    #
    && export DEBIAN_FRONTEND="noninteractive" \
    && export LC_CTYPE="C.UTF-8" \
    #
    && ARCH=$(uname -m) \
    && PLATFORM=$(/tmp/src/get_platform.sh) \
    && echo "Architecture=${ARCH}        Platform=${PLATFORM}" \
    #
    && SRC_DIR="/usr/src" \
    #
    && STUNNEL_VERSION="5.67" \
    #
    && NODE_18_VERSION="18.13.0" \
    #
    && DOCKER_BUCKET="download.docker.com" \
    && DOCKER_CHANNEL="stable" \
    && DIND_COMMIT="1f32e3c95d72a29b3eaacba156ed675dba976cb5" \
    && DOCKER_COMPOSE_VERSION="2.15.1" \
    && DOCKER_VERSION="20.10.22" \
    #
    # Install git, SSH, and other utilities \
    #
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update -qq \
    && apt install -y -qq --no-install-recommends apt-transport-https apt-utils openssh-client \
    && mkdir ~/.ssh \
    && mkdir -p /codebuild/image/config \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && apt-get install -y -qq --no-install-recommends \
          asciidoc  \
          autoconf \
          automake \
          build-essential \
          bzip2 \
          ca-certificates \
          curl \
          file \
          g++ \
          gcc \
          gettext \
          gettext-base \
          git \
          gnupg \
          jq \
          less \
          libapr1 \
          libaprutil1 \
          libargon2-0-dev \
          libbz2-dev \
          libc6-dev \
          libcurl4-openssl-dev \
          libdb-dev \
          libdbd-sqlite3-perl \
          libdbi-perl \
          libdpkg-perl \
          libedit-dev \
          liberror-perl \
          libevent-dev \
          libffi-dev \
          libgeoip-dev \
          libglib2.0-dev \
          libhttp-date-perl \
          libio-pty-perl \
          libkrb5-dev \
          liblzma-dev \
          libmysqlclient-dev \
          libncurses5-dev \
          libncursesw5-dev \
          libonig-dev \
          libpq-dev \
          libreadline-dev \
          libserf-1-1 \
          libsodium-dev \
          libsqlite3-dev \
          libssl-dev \
          libsvn-perl \
          libsvn1 \
          libtimedate-perl \
          libtool \
          libxml2-dev \
          libxml2-utils \
          libxslt1-dev \
          libyaml-dev \
          libyaml-perl \
          libzip-dev \
          llvm \
          locales \
          make \
          netbase \
          openssl \
          patch \
          pkg-config \
          procps \
          python-is-python3 \
          python3-pip \
          python3.10 \
          rsync \
          tar \
          unzip \
          xfsprogs \
          xz-utils \
          zip \
          zlib1g-dev \
    && useradd codebuild-user \
    #
    # Install the common tools
    #
    # stunnel
    && mkdir /tmp/stunnel \
    && cd /tmp/stunnel \
    && STUNNEL_TAR=stunnel-$STUNNEL_VERSION.tar.gz \
    && curl -sSL -o $STUNNEL_TAR https://www.stunnel.org/downloads/$STUNNEL_TAR \
    && tar xfz $STUNNEL_TAR \
    && cd stunnel-$STUNNEL_VERSION \
    && ./configure \
    && make -j4 --quiet \
    && make install --quiet \
    && openssl genrsa -out key.pem 2048 \
    && openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -subj "/C=US/ST=Washington/L=Seattle/O=Amazon/OU=Codebuild/CN=codebuild.amazon.com" \
    && cat key.pem cert.pem >> /usr/local/etc/stunnel/stunnel.pem \
    && stunnel -version \
    # AWS Tools
    && curl -sSL -o /usr/local/bin/aws-iam-authenticator --ipv4 --ssl-allow-beast --ssl-no-revoke --ssl-revoke-best-effort https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.2/aws-iam-authenticator_0.6.2_linux_${PLATFORM} \
    && curl -sSL -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.7/2022-10-31/bin/linux/${PLATFORM}/kubectl \
    && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator \
    && aws-iam-authenticator version \
    && kubectl version --client=true --output=yaml \
    # Configure SSM
    && mkdir /tmp/ssm \
    && cd /tmp/ssm \
    && curl -sSL -o amazon-ssm-agent.deb https://s3.amazonaws.com/amazon-ssm-us-east-1/latest/debian_${PLATFORM}/amazon-ssm-agent.deb \
    && dpkg -i amazon-ssm-agent.deb \
    # Install AWS CLI v2
    && curl -sSL -o /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip \
    && unzip -q /tmp/awscliv2.zip -d /opt \
    && /opt/aws/install --update --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin \
    && aws --version \
    #
    # Install Node.js
    #
    && cd /tmp/ \
    && git clone --quiet https://github.com/tj/n \
    && cd n \
    && make install \
    && n $NODE_18_VERSION \
    && cd \
    && hash -r \
    && node --version \
    && npm --version \
    #
    # Install Python packages
    #
    && pip --quiet --disable-pip-version-check --no-color install --no-cache-dir --upgrade pip \
    && pip --quiet --disable-pip-version-check --no-color install --no-cache-dir --requirement /tmp/src/requirements.txt \
    && python --version \
    && ansible --version \
    #
    # Install Docker (engine, dind, compose, buildx)
    #
    && mkdir /tmp/docker \
    && cd /tmp/docker \
    && curl -sSL -o docker.tgz https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/${ARCH}/docker-${DOCKER_VERSION}.tgz \
    && tar zxf docker.tgz --strip-components 1 --directory /usr/local/bin/ \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    && curl -sSL -o /usr/local/bin/dind https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind \
    && curl -sSL https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-${ARCH} > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/dind /usr/local/bin/docker-compose \
    && docker -v \
    && docker-compose version \
    && docker buildx version \
    #
    # Place configuration files
    #
    && mv /tmp/src/ssh_config /root/.ssh/config \
    && mv /tmp/src/runtimes.yml /codebuild/image/config/runtimes.yml \
    && mv /tmp/src/dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh \
    && mv /tmp/src/amazon-ssm-agent.json /etc/amazon/ssm/amazon-ssm-agent.json \
    #
    # Clean-up
    #
    && rm -rf /opt/aws \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && echo "" > /var/log/dpkg.log \
    && echo "" > /var/log/apt/history.log

VOLUME /var/lib/docker

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh"]
