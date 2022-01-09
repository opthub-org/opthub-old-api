# OptHub API

GraphQL API server

## Usage
### Start
```
$ docker-compose up -d
```
Open http://localhost:8080 on your web browser.

### Stop
```
$ docker-compose down
```

### Clear
```
$ docker volume rm opthub-api_db-data
```

## Deploy on Heroku
### 1. Install Heroku CLI
[Install Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)

### 2. Log in Heroku CLI
```
$ heroku login

Logging in... done
Logged in as xxxxxxxxxx@example.com
```

### 3. Create a Heroku app
```
$ heroku create opthub-api --stack=container

Creating ⬢ opthub-api... done
https://opthub-api.herokuapp.com/ | https://git.heroku.com/opthub-api.git
```

### 4. Create a Heroku PostgreSQL add-ons
```
$ heroku addons:create heroku-postgresql:hobby-dev
```

### 5. Deploy an app
```
$ git push heroku master
```

### 6. Check the app
```
$ heroku open
```

## Migrate DB
See https://hasura.io/docs/1.0/graphql/core/migrations/index.html

### 1. Install Hasura CLI
```
$ heroku run "curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash"
```

### 2. Download data from old Hasura
```
$ hasura init "<src-name>" --endpoint "<src-url>" --admin-secret "<src-secret>"
$ cd "<src-name>"
$ hasura migrate create init --from-server
$ hasura metadata export
$ hasura seed create init --from-table "<src-table>"
```

### 3. Upload data to new Hasura
```
$ hasura migrate apply --endpoint "<dest-url>" --admin-secret "<dest-secret>"
$ hasura metadata apply --endpoint "<dest-url>" --admin-secret "<dest-secret>"
$ hasura seed apply --endpoint "<dest-url>" --admin-secret "<dest-secret>"
```
