#!/bin/bash
docker-compose run app rails new . --api --no-deps --force --skip-action-cable --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-record --skip-active-storage --skip-git --skip-javascript --skip-jbuilder --skip-sprockets --skip-turbolinks --skip-test --skip-system-test --skip-webpack-install
