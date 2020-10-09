FROM ruby:2-alpine

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo

WORKDIR /app

COPY Gemfile* ./

RUN apk update && \
    apk upgrade && \
    apk add --no-cache gcc g++ libc-dev libxml2-dev linux-headers make tzdata && \
    apk add --virtual build-packs --no-cache build-base curl-dev && \
    bundle install -j4 && \
    apk del --purge build-packs

COPY . ./

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
