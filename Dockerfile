FROM ruby:3.0.3-alpine

RUN apk add --no-cache imagemagick postgresql-client tzdata nodejs dcron gnupg file curl

WORKDIR /app

# Install gems
ARG BUNDLE_WITHOUT=development:test:tools
COPY Gemfile Gemfile.lock /app/
RUN apk add --virtual .build-deps build-base postgresql-dev git tzdata \
    && gem install bundler \
    && bundle config set without ${BUNDLE_WITHOUT} \
    && bundle install --no-cache -j4 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/cache \
    && rm -rf /root/.bundle/cache \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete \
    && apk del .build-deps

# NB: master.key must be present in ./config
COPY . /app

# Prepare build env
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true

ARG RAILS_MASTER_KEY
ENV APP_HOST ${APP_HOST}

# Precompile assets
RUN sh -c "bundle exec rake assets:precompile" \
    && rm -rf tmp/cache

# Startup
EXPOSE 3000
CMD ["./docker_startup.sh"]
