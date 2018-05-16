# Base image
FROM crystallang/crystal:0.24.1

# Setup environment variables that will be available to the instance
ENV APP_HOME /produciton

# Installation of dependencies

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update -qq \
  && apt-get install -y \
  curl \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
  && apt-get update -qq \
  # Install Heroku CLI
  && curl https://cli-assets.heroku.com/install-ubuntu.sh | bash \
  && apt-get install -y \
  curl \
  wget \
  # Needed for certain libraries
  build-essential \
  yarn \
  nodejs \
  postgresql postgresql-contrib \
  # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
  /var/lib/apt \
  /var/lib/dpkg \
  /var/lib/cache \
  /var/lib/log \
  # Install Lucky CLI
  && wget https://github.com/luckyframework/lucky_cli/archive/v0.10.0-rc3.tar.gz \
  && tar -zxf v0.10.0-rc3.tar.gz \
  && cd lucky_cli-0.10.0-rc3 \
  && crystal deps \
  && crystal build src/lucky.cr --release --no-debug \
  && mv lucky /usr/local/bin/. \
  && cd \
  && rm -rf lucky_cli-0.10.0-rc3 \
  && rm -rf v0.10.0-rc3.tar.gz

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile
# and install gems

COPY shard.yml $APP_HOME/
RUN shards install

# Copy over our application code
COPY . $APP_HOME

RUN yarn install --silent \
  && npm rebuild node-sass --force \
  && yarn dev

# Run our app
CMD lucky dev
