FROM python:3.8-slim-buster as build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY pipe/ requirements.txt LICENSE.txt pipe.yml README.md /
RUN apt-get update && apt-get install --no-install-recommends -y \
      apt-transport-https=1.8.* \
      gnupg=2.* \
      curl=7.* \
      unzip=6.* \
      git=1:2.* && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y kubectl=1.21.* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --user --no-cache-dir -r /requirements.txt && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.2.9.zip" -o "awscliv2.zip" && unzip awscliv2.zip && \
    echo 'c778f4cc55877833679fdd4ae9c94c07d0ac3794d0193da3f18cb14713af615f awscliv2.zip' | sha256sum -c -

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

FROM python:3.8-slim-buster

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# copy kubectl cli binary and install aws cli v2
COPY --from=build /usr/bin/kubectl /usr/bin
COPY --from=build /usr/local/bin/helm /usr/bin
COPY --from=build /aws aws
RUN ./aws/install && rm -rf aws

# copy python env
COPY --from=build /root/.local /root/.local
# copy project files
COPY --from=build pipe.py /
COPY --from=build LICENSE.txt pipe.yml README.md /

ENV PATH=/root/.local/bin:$PATH


COPY pipe /
COPY LICENSE.txt pipe.yml README.md /

ENTRYPOINT ["python", "/pipe.py"]
