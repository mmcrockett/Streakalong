FROM ruby:2.2.10-jessie

ENV RAILS_ROOT /var/www/streakalong
ENV RAILS_ENV production

WORKDIR $RAILS_ROOT

COPY Gemfile* ./

RUN gem install bundler --version=1.17.3 --no-document
RUN bundle config --local without development:test
RUN bundle install --jobs 20 --retry 5

COPY . .

RUN bundle exec rake secret > ${RAILS_ROOT}/config/streakalong.production.secret.token
RUN bundle exec rake assets:precompile
RUN rm -rf test/* tmp/* log/* db/*

EXPOSE 3000

CMD rm -rf tmp/pids/ && rails server --port 3000 --binding 0.0.0.0
