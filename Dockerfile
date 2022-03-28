FROM 802306197541.dkr.ecr.eu-central-1.amazonaws.com/terraform:1.0.5

ARG INFRA_DEPLOY_KEY
ARG INFRA_DEPLOY_KEY_PRIV

RUN mkdir ~/.ssh/
RUN touch ~/.ssh/id_rsa.tango-infra.pub && \
    chmod 644 ~/.ssh/id_rsa.tango-infra.pub && \
    echo $INFRA_DEPLOY_KEY >> ~/.ssh/id_rsa.tango-infra.pub
RUN touch ~/.ssh/id_rsa.tango-infra && \
    chmod 600 ~/.ssh/id_rsa.tango-infra && \
    echo -e $INFRA_DEPLOY_KEY_PRIV | tr -d "\"" >> ~/.ssh/id_rsa.tango-infra
RUN touch ~/.ssh/config && \
    echo -e "  AddKeysToAgent yes\n  IdentityFile ~/.ssh/id_rsa.tango-infra" >> ~/.ssh/config

RUN touch ~/.ssh/known_hosts && \
    ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN git config --global url."git@github.com:".insteadOf "https://github.com/" && \
    eval "$(ssh-agent -s)" && \
    ssh-add ~/.ssh/id_rsa.tango-infra

RUN apk update
RUN apk upgrade
RUN apk add --no-cache openrc git docker bash jq==1.6-r1
RUN rc-update add docker boot

RUN apk add --no-cache python3-dev libressl-dev musl-dev libffi-dev curl
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN pip3 install awscli --upgrade
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community openjdk15
RUN apk add --no-cache maven
ENV JAVA_HOME /usr/lib/jvm/java-15-openjdk/
RUN export JAVA_HOME

RUN mkdir ~/.m2/
COPY ./settings.xml /root/.m2/settings.xml

ENV ALPINE_MIRROR ""
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/main/" >> /etc/apk/repositories
RUN apk add --no-cache nodejs yarn --repository="http://dl-cdn.alpinelinux.org/alpine/v3.11/main/"

RUN apk add --no-cache npm build-base


RUN apk add zip
