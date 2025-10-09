# syntax=docker/dockerfile:1

# Base image
FROM ruby:3.4.4-slim AS base

# Set environment variables
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=8080

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev curl libvips nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle

# Copy application code
COPY . .

# Precompile assets (important for production)
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Expose the Vercel port
EXPOSE 8080

# Start the Rails server
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec rails s -p 8080 -b 0.0.0.0"]
