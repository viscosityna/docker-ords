#!/bin/bash

OPTS=`getopt -o h --long help,db-host:,db-port:,db-service-name:,db-sid:,apex-pu-pass:,apex-listener-pass:,apex-listener-pass:,apex-rest-pu-pass: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#echo "$OPTS"
eval set -- "$OPTS"

while true; do
	case "$1" in
		--db-host ) DB_HOSTNAME="$2"; shift; shift ;;
		--db-port ) DB_PORT="$2"; shift; shift ;;
		--db-service-name ) DB_SERVICE_NAME="$2"; shift; shift ;;
		--db-sid ) DB_SID="$2"; shift; shift ;;
		--apex-pu-pass ) APEX_PUBLIC_USER_PASSWORD="$2"; shift; shift ;;
		--apex-listener-pass ) APEX_LISTENER_PASSWORD="$2"; shift; shift ;;
		--apex-rest-pu-pass )  APEX_REST_PUBLIC_USER_PASSWORD="$2"; shift; shift ;;
		-- ) shift ; break ;;
		* ) break ;;
	esac
done

if [ ! -f ./ords.lock ]; then
	
	if [ -d ./ords-current ]; then
		echo "Removing old ords directory"
		rm -r ./ords-current
	fi

	unzip ords.current.zip -d ords-current

	cat <<EOF > ./ords-current/params/ords_params.properties
db.hostname=$DB_HOSTNAME
db.port=$DB_PORT
db.servicename=$DB_SERVICE_NAME
db.sid=$DB_SID
db.password=$APEX_PUBLIC_USER_PASSWORD
db.username=APEX_PUBLIC_USER
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
user.apex.listener.password=$APEX_LISTENER_PASSWORD
user.apex.restpublic.password=$APEX_REST_PUBLIC_USER_PASSWORD
user.public.password=$APEX_PUBLIC_USER_PASSWORD
standalone.mode=false
EOF

	java -jar ./ords-current/ords.war configdir ./conf/ords

	java -jar ./ords-current/ords.war install simple 

	cp ./ords-current/ords.war ./webapps

	touch ./ords.lock
else
	echo "ords has been configured already"
fi

catalina.sh run