FROM docker.rcplus.io/ubuntu:22.10

COPY . /tmp/src

# NOTE 1: for the Ubuntu packages installed in the official 22.10 Docker image, the list can be found at:
#    https://git.launchpad.net/cloud-images/+oci/ubuntu-base/commit/?h=dist-kinetic-amd64-20221130&id=28c4e64ea84b6e9bcd1352e81cf71dbb47f259cc
#    Generally, start from https://git.launchpad.net/cloud-images/+oci/ubuntu-base/refs/tags to get the corresponding commit
# NOTE 2: the AWS standard CodeBuild images uses ppa:git-core/ppa to install the newest version of git. To use the ppa
#    registry, we will have to install package software-properties-common, which implies the installation of Python3
#    and quite some other packages. As we will install a Python interpreter later with pyenv, the redundancy should be
#    avoided. To reduce the eventual image size, we take the Ubuntu 22.10 standard git, so that software-properties-common
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
    # Install git, SSH, and other utilities
    #
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update -qq \
    && apt install -y -qq --no-install-recommends apt-transport-https apt-utils \
    && apt-get install -y -qq --no-install-recommends \
          asciidoc  \
          autoconf \
          automake \
          build-essential \
          bzip2 \
          bzr \
          ca-certificates \
          curl \
          dirmngr \
          dpkg-dev \
          e2fsprogs \
          expect \
          fakeroot \
          file \
          g++ \
          gcc \
          gettext \
          gettext-base \
          git \
          gnupg \
          gzip \
          iptables \
          jq \
          kmod \
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
          libjpeg-dev \
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
          libtidy-dev \
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
          lsb-release \
          make \
          netbase \
          openssh-client \
          openssl \
          patch \
          pkg-config \
          procps \
          python-is-python3 \
          python3-configobj \
          python3-openssl \
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
    && curl -sSL -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.9/2023-01-11/bin/linux/${PLATFORM}/kubectl \
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
    # Install Docker (and dind)
    #
    && mkdir -p /etc/apt/keyrings \
    && curl -sSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
          containerd.io \
          docker-ce \
          docker-ce-cli \
          docker-compose-plugin \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    # refer to https://github.com/docker-library/docker/blob/master/versions.sh
    && DIND_COMMIT=$(curl -sSL https://github.com/docker/docker/commits/master/hack/dind.atom |grep -E 'id.*Commit' |awk -F '[[:space:]]*[<>/]+' '$2 == "id" && $3 ~ /Commit/ { print $4; exit }') \
    && curl -sSL -o /usr/local/bin/dind https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind \
    && chmod +x /usr/local/bin/dind \
    && docker -v \
    && docker compose version \
    && docker buildx version \
    #
    # Configure SSH
    #
    && mkdir ~/.ssh \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 400 ~/.ssh/known_hosts \
    && mv /tmp/src/ssh_config /root/.ssh/config \
    #
    # Place configuration files
    #
    && mkdir -p /codebuild/image/config \
    && mv /tmp/src/runtimes.yml /codebuild/image/config/runtimes.yml \
    && mv /tmp/src/dockerd-entrypoint.sh /usr/local/bin/start-dind.sh \
    && mv /tmp/src/amazon-ssm-agent.json /etc/amazon/ssm/amazon-ssm-agent.json \
    #
    # Bake the standard Ansible galaxy collections into the image
    && ansible-galaxy collection install --force git+https://github.com/ringier-data/ops-ci-aws.git,main \
    && ansible-galaxy collection install --upgrade \
          amazon.aws \
          ansible.netcommon \
          ansible.posix \
          community.aws \
          community.general \
          community.postgresql \
          kubernetes.core \
    #
    # Clean-up
    #
    && apt-get clean \
    && rm -rf /opt/aws \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && echo "" > /var/log/dpkg.log \
    && echo "" > /var/log/apt/history.log

VOLUME /var/lib/docker
