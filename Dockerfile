FROM ubuntu:14.04

# Install Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  build-essential \
  pkg-config \
  git \
  python \
  && rm -rf /var/lib/apt/lists/*

# Install Node (copied from node 4.4.5 Dockerfile)
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NODE_VERSION 4.4.5
RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm cache clear

# Install Hubot
RUN npm install -g coffee-script hubot
# Install yo, and the hubot generator.
RUN npm -g install yo generator-hubot

# Create Hubot
RUN mkdir -p /app/hubot
WORKDIR /app/hubot
ADD hubot /app/hubot

# Extra hubot packages should be added to hubot/package.json
RUN npm install --save
# Set Hubot Options
ENV HUBOT_IRC_UNFLOOD true
ENV HUBOT_SLACK_EXIT_ON_DISCONNECT true

# HTTP Listener listen port 9980
ENV PORT 9980
EXPOSE 9980

# Run Hubot
ENTRYPOINT ["bin/hubot"]
CMD ["-a", "slack"]
