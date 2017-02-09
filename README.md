# federated-service-data

Module filter access on application running on port 8080 to filtering Edugain on 80.
and provide access to data directory to parse and download file at <ip>/data.

```shell


export DEAMON_OR_ITERACTIVE=it
export ALLOWED_EMAIL_SPACE_SEPARATED_VALUES="john.doe@no.where bowie@space.oddity"

#don't forget to adujst TARGET_FQDN, TARGET_PORT, and TARGET_PATH
export TARGET_PATH=/

# Set directory to parse on url <ip>/data, by default is '/root/mydisk'
export DATA_DIR=/root/mydisk

./startServiceData.sh
```
