FROM docker:20.10.3-dind
ENV TZ=UTC
RUN apk update \
  && apk add python3-dev py3-pip rust libffi-dev openssl-dev gcc libc-dev make \
             curl wget bash git sqlite jq cargo \
  && echo "source /etc/profile" >> ~/.bashrc
RUN pip3 install --upgrade pip
# install docker-compose and AWS tools
RUN pip3 install --ignore-installed \
                 docker-compose==1.25.5 awscli==1.18.135 awsebcli==3.19.0 \
                 kubernetes==11.0.0 requests==2.20.1 \
  && docker-compose --version \
  && echo "complete -C '/usr/bin/aws_completer' aws" >> ~/.bashrc \
  && aws --version
# install aws-iam-authenticator
RUN curl --silent --location --output /usr/local/bin/aws-iam-authenticator \
    https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator \
   && chmod +x /usr/local/bin/aws-iam-authenticator \
   && aws-iam-authenticator version
# install kubectl
RUN KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) \
  && curl --tlsv1.3 --ssl-reqd --silent --location --output /usr/local/bin/kubectl \
     https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && kubectl version --client=true \
  && echo "source <(kubectl completion bash) \nalias k=kubectl \ncomplete -F __start_kubectl k" >> ~/.bashrc
# install kustomize
RUN kustomize_version="v3.6.1" \
  && curl --location \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${kustomize_version}/kustomize_${kustomize_version}_linux_amd64.tar.gz" \
    | tar --extract --gzip \
  && install --target-directory=/usr/local/bin kustomize \
  && rm kustomize
# install gomplate
RUN curl --silent --location --output /usr/local/bin/gomplate \
    https://github.com/hairyhenderson/gomplate/releases/download/v3.6.0/gomplate_linux-amd64 \
   && chmod +x /usr/local/bin/gomplate \
   && gomplate --version
# install argo cli
RUN argo_version="v2.12.8" \
  && curl --silent --location \
    https://github.com/argoproj/argo/releases/download/"${argo_version}"/argo-linux-amd64.gz \
    | gzip -d > argo \
  && install --target-directory=/usr/local/bin argo \
  && rm argo
