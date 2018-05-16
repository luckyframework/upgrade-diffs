# Base image
FROM crystallang/crystal:0.24.1

# Setup environment variables that will be available to the instance
ENV APP_HOME /produciton

# Installation of dependencies
RUN apt-get update -qq \
  && apt-get install -y \
  # Needed for certain libraries
  build-essential \
  # # Needed for postgres gem
  # libpq-dev \
  # Needed for asset compilation
  nodejs \
  yarn \
  # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
  /var/lib/apt \
  /var/lib/dpkg \
  /var/lib/cache \
  /var/lib/log

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile
# and install gems

ADD shards.yml* $APP_HOME/
RUN shards install

# Copy over our application code
ADD . $APP_HOME

# Run our app
CMD lucky dev
