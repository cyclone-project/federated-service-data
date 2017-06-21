#!/bin/sh
DOCKER_IMAGE_OWNER=cyclone
DOCKER_IMAGE_NAME=proxy-service-data
FQDN=${FQDN:-$(curl http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)}
FQDN=${FQDN:-$(              hostname -I | sed 's/ /\n/g' | grep -v 172.17 | head -n 1)}
TARGET_FQDN=${TARGET_FQDN:-$(hostname -I | sed 's/ /\n/g' | grep    172.17 | head -n 1)}
TARGET_PORT=${TARGET_PORT:-8080}
TARGET_PATH=${TARGET_PATH:-/}
if [ -z "$1" ]
then
	DEFAULT_DEAMON_OR_ITERACTIVE=d
else
	DEFAULT_DEAMON_OR_ITERACTIVE=it
fi
DEAMON_OR_ITERACTIVE=${DEAMON_OR_ITERACTIVE:-$DEFAULT_DEAMON_OR_ITERACTIVE}
SUDO_CMD=${SUDO_CMD:-sudo}
LOG_DIR=${LOG_DIR:-/var/log/httpd-proxy-service-data}
DATA_DIR=${DATA_DIR:-/root/mydisk}
UI_DIR=${DATA_DIR}/_h5ai
H5AI_ZIP="h5ai-0.29.0.zip"

if [ ! -d $LOG_DIR ]
then
	echo "LOG_DIR(=$LOG_DIR) is missing, creating it"
	$SUDO_CMD mkdir -p $LOG_DIR
fi

if [ "$(docker ps 1>/dev/null 2>/dev/null ; echo $?)" != "0" ]
then
	echo "Docker seems to not be running"
	$SUDO_CMD service docker start
fi

if [ "$ALLOWED_EMAIL_SPACE_SEPARATED_VALUES" != "" ]
then
    rm ./apache_groups
fi

echo "DOCKER_IMAGE_OWNER:$DOCKER_IMAGE_OWNER"
echo "DOCKER_IMAGE_NAME:$DOCKER_IMAGE_NAME"
echo "FQDN:$FQDN"
echo "TARGET_FQDN:$TARGET_FQDN"
echo "TARGET_PORT:$TARGET_PORT"
echo "TARGET_PATH:$TARGET_PATH"
echo "DEAMON_OR_ITERACTIVE:$DEAMON_OR_ITERACTIVE"
echo "SUDO_CMD:$SUDO_CMD"
echo "ALLOWED_EMAIL_SPACE_SEPARATED_VALUES:$ALLOWED_EMAIL_SPACE_SEPARATED_VALUES"
echo "LOG_DIR:$LOG_DIR"
echo "DATA_DIR:$DATA_DIR"

if [ ! -e ./apache_groups ]
then

  #ALLOWED_EMAIL_COMMA_SEPARATED_VALUES=${ALLOWED_EMAIL_COMMA_SEPARATED_VALUES:-john.doe@no.where, bowie@space.oddity}
  if [ "X$ALLOWED_EMAIL_SPACE_SEPARATED_VALUES" = "X" ]
  then
    echo "env var \$ALLOWED_EMAIL_SPACE_SEPARATED_VALUES must contains edugain email of allowed user"
    exit 1
  fi
  echo "cyclone: $ALLOWED_EMAIL_SPACE_SEPARATED_VALUES" > apache_groups
fi


# Install graphic dependency in DATA_DIR $DATA_DIR
if [ ! -d $UI_DIR ]; then 
        which unzip &> /dev/null
        res=$?

        # if [ $( which unzip &> /dev/null ; echo $?) -ne 0 ]; then
        if [ $res -ne 0 ]; then
                echo "Install unzip package res value is $res"
                apt-get install --yes unzip &> /dev/null
	fi

	echo "Install Web server interface."
	wget --no-verbose https://release.larsjung.de/h5ai/${H5AI_ZIP} -P /tmp
	unzip -q /tmp/${H5AI_ZIP} -d ${DATA_DIR}
	rm /tmp/${H5AI_ZIP}

	if [ -d $UI_DIR ]; then
		echo "Sucessfully install Web server $H5AI_ZIP"
	else
		echo "Fail to install  Web server $H5AI_ZIP"
	fi
fi



echo "to open $TARGET_PORT:\niptables -I INPUT 1 -p tcp -i docker0 -m tcp --dport $TARGET_PORT -j ACCEPT"

echo "redirecting / to http://${TARGET_FQDN}:${TARGET_PORT}${TARGET_PATH}"
echo "user(s) allowed:"
cat apache_groups

docker rm -f proxy-service-data
docker build -t ${DOCKER_IMAGE_OWNER}/${DOCKER_IMAGE_NAME} . 


docker run -${DEAMON_OR_ITERACTIVE} -p 80:80 \
        --restart always \
	-e FQDN=${FQDN}  \
	-e TARGET_FQDN=${TARGET_FQDN}  \
	-e TARGET_PORT=${TARGET_PORT} \
	-e TARGET_PATH=${TARGET_PATH} \
	-v ${LOG_DIR}:/var/log/httpd \
	-v $PWD/proxy.conf:/etc/httpd/conf.d/proxy.conf:ro \
	-v $PWD/proxy.conf:/etc/apache2/conf-enabled/proxy.conf:ro \
	-v $PWD/apache_groups:/etc/httpd/apache_groups:ro \
        -v $DATA_DIR:/ifb/data \
	--name ${DOCKER_IMAGE_NAME}  \
	${DOCKER_IMAGE_OWNER}/${DOCKER_IMAGE_NAME} $1

