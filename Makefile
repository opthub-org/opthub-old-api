VER=latest
APP=opthub-api
STG=$(APP)-stage

.PHONY: ps start stop clean deploy-stage init-stage deploy init login migrate install

ps:
	docker-compose ps

start:
	docker-compose up -d

stop:
	docker-compose down

clean:
	docker volume rm opthub-api_db-data

deploy-stage:
	git push heroku-stage master

deploy:
	git push heroku master

init-stage:
	heroku create $(STG) --stack=container
	heroku addons:create heroku-postgresql:hobby-dev -a $(STG)

init:
	heroku create $(APP) --stack=container
	heroku addons:create heroku-postgresql:hobby-basic -a $(APP)

login:
	heroku login
	heroku container:login

migrate:
	hasura init hasura --endpoint https://$(APP).herokuapp.com --admin-secret atrIhKym3BoRVy
	cd hasura
	hasura migrate create init --from-server
	hasura metadata export 

install:
	apt install docker docker-compose
	curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
	curl https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash