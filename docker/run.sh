#!/usr/bin/env bash

# Ensure environment values are not exposed in drone output
set +x

echo "Exporting environment variables"

export DB_POWERBI_DEFAULT_DBNAME=${DB_POWERBI_DEFAULT_DBNAME}
export DB_POWERBI_HOSTNAME=${DB_POWERBI_HOSTNAME}
export DB_POWERBI_PORT=${DB_POWERBI_PORT}
export DB_POWERBI_OPTIONS=${DB_POWERBI_OPTIONS}
export DB_POWERBI_JDBC_OPTIONS=${DB_POWERBI_JDBC_OPTIONS}
export URL="postgresql://${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_DEFAULT_DBNAME}${DB_POWERBI_OPTIONS}"
export FLYWAY_URL="jdbc:"postgresql://${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_DEFAULT_DBNAME}${DB_POWERBI_JDBC_OPTIONS}""
export DB_POWERBI_DEFAULT_USERNAME=${DB_POWERBI_DEFAULT_USERNAME}
export DB_POWERBI_DEFAULT_PASSWORD=${DB_POWERBI_DEFAULT_PASSWORD}
export FLYWAY_PLACEHOLDERS_MASTERUSER=${DB_POWERBI_DEFAULT_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIOWNERNAME=$DB_POWERBI_GOVERNANCE_OWNER_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIOWNERPASSWORD=$DB_POWERBI_GOVERNANCE_OWNER_PASSWORD}
export FLYWAY_PLACEHOLDERS_POWERBISCHEMA=$DB_POWERBI_GOVERNANCE_SCHEMA}
export PGPASSWORD=${DB_POWERBI_DEFAULT_PASSWORD}

export BASEPATH="${PWD}"
echo "Running from base path: ${BASEPATH}"

echo "Checking if postgres is up and ready for connections"
i=0
pg_isready -d ${URL} -U ${DB_POWERBI_DEFAULT_USERNAME} -t 60
PG_EXIT=$?
while [[ "${i}" -lt "5" && ${PG_EXIT} != 0 ]]
do
    echo "waiting for Postgres to start, attempt: ${i}"
    sleep 5s
    if [[ "${i}" > 5 ]]
    then
        echo "Error: failed waiting for Postgres to start"
        exit 1
    fi
    ((i++))
    pg_isready -d ${URL} -U ${DB_POWERBI_DEFAULT_USERNAME} -t 60
    PG_EXIT=$?
done

echo "Creating initial databases"
export FLYWAY_USER=${DB_POWERBI_DEFAULT_USERNAME}
export FLYWAY_PASSWORD=${DB_POWERBI_DEFAULT_PASSWORD}


echo "Checking if database exists"
STATUS=$( psql postgresql://${DB_POWERBI_DEFAULT_USERNAME}@${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_DEFAULT_DBNAME}${DB_POWERBI_OPTIONS} -tc "SELECT 1 FROM pg_database WHERE datname='${DB_POWERBI_REFERENCE_DBNAME}'" | sed -e 's/^[ \t]*//')
if [[ "${STATUS}" == "1" ]]
then
    echo "Database already exists"
else
    echo "Database does not exist creating - Bootstrapping databases"
    export FLYWAY_LOCATIONS="filesystem:${BASEPATH}/schemas/init"
    flyway -configFiles=${BASEPATH}/docker/flyway_init_docker.conf migrate
    if [[ "$?" != 0 ]]
    then
        echo "Error: initialising database"
        exit 1
    fi
    cd ${BASEPATH}/docker/
    yasha bootstrap.j2 -o /tmp/bootstrap.sql
    psql postgresql://${DB_POWERBI_DEFAULT_USERNAME}@${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_DEFAULT_DBNAME}${DB_POWERBI_OPTIONS} < /tmp/bootstrap.sql
    if [[ "$?" != 0 ]]
    then
        echo "Error: with bootstrapping database"
        exit 1
    fi
fi

echo "Migrating powerbi database"
export FLYWAY_URL="jdbc:postgresql://${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_REFERENCE_DBNAME}${DB_POWERBI_JDBC_OPTIONS}"
export FLYWAY_USER=$DB_POWERBI_GOVERNANCE_OWNER_USERNAME}
export FLYWAY_PASSWORD=$DB_POWERBI_GOVERNANCE_OWNER_PASSWORD}
export FLYWAY_SCHEMAS=$DB_POWERBI_GOVERNANCE_SCHEMA}
export FLYWAY_PLACEHOLDERS_SCHEMA=$DB_POWERBI_GOVERNANCE_SCHEMA}
export FLYWAY_PLACEHOLDERS_AUTHENTICATORUSER=$DB_POWERBI_GOVERNANCE_AUTHENTICATOR_USERNAME}
export FLYWAY_PLACEHOLDERS_AUTHENTICATORPASSWORD=$DB_POWERBI_GOVERNANCE_AUTHENTICATOR_PASSWORD}
export FLYWAY_PLACEHOLDERS_ANONUSER=$DB_POWERBI_GOVERNANCE_ANON_USERNAME}
export FLYWAY_PLACEHOLDERS_SERVICEUSER=$DB_POWERBI_GOVERNANCE_SERVICE_USERNAME}
export FLYWAY_PLACEHOLDERS_READONLYUSER=$DB_POWERBI_GOVERNANCE_READONLY_USERNAME}
export FLYWAY_LOCATIONS="filesystem:${BASEPATH}/schemas/powerbi"

flyway -configFiles=${BASEPATH}/docker/flyway_powerbi_docker.conf migrate
if [[ "$?" != 0 ]]
then
    echo "Error: migration of powerbi db failed"
    exit 1
fi

exit 0
