# Migrate the local MongoDB data to Mongo Atlas Cloud

In this case, MongoDB is running locally on a Docker container.

## Step into the container

```sh
docker exec -it <container_name> bash
```

## Run dump inside it

```sh
mongodump --uri="mongodb://localhost:27017/bewa_mongo" --out=/tmp/mongo_backup
```

## Exit and copy the dump out

```sh
docker cp <container_name>:/tmp/mongo_backup ./mongo_backup
```

## Copy your backup files into the existing container

```sh
docker cp ./mongo_backup mongodb:/tmp/mongo_backup
```

## Run mongorestore inside it

```sh
docker exec -it mongodb mongorestore \
 --uri="mongodb+srv://jalbertoqz:PASSWORD@clusterito.j3qr7mo.mongodb.net/bewa_mongo" \
 /tmp/mongo_backup/bewa_mongo
```
