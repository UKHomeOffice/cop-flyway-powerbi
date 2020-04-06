#!/usr/bin/env bash

# Ensure environment values are not exposed in drone output
set +x

echo "Exporting environment variables"

# jdbc:sqlserver://<host>:<port>;databaseName=<database>
export FLYWAY_URL="jdbc:sqlserver://${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT};databaseName=${DB_POWERBI_DBNAME}"
export FLYWAY_BASELINE_ON_MIGRATE="true"

export BASEPATH="${PWD}"
echo "Running from base path: ${BASEPATH}"

echo "Checking if SQL server is up and ready for connections"
i=0
/opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -d ${DB_POWERBI_DBNAME} -Q "SELECT DATABASEPROPERTYEX(N'database name', 'Collation')" -t 5
SS_EXIT=$?
while [[ "${i}" -lt "5" && ${SS_EXIT} != 0 ]]
do
    echo "waiting for SQL Server to start, attempt: ${i}"
    sleep 15s
    if [[ "${i}" > 5 ]]
    then
        echo "Error: failed waiting for SQL Server to start"
        exit 1
    fi
    ((i++))
    /opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -d ${DB_POWERBI_DBNAME} -Q "SELECT DATABASEPROPERTYEX(N'database name', 'Collation')" -t 5
    SS_EXIT=$?
done

echo "Migrating powerbi database"
 
export FLYWAY_USER=${DB_POWERBI_FLYWAY_USERNAME}
export FLYWAY_PASSWORD=${DB_POWERBI_FLYWAY_PASSWORD}

export FLYWAY_PLACEHOLDERS_DATABRICKSPASSWORD=${DB_POWERBI_DATABRICKS_PASSWORD}
export FLYWAY_PLACEHOLDERS_DATABRICKSUSERNAME=${DB_POWERBI_DATABRICKS_USERNAME}
export FLYWAY_PLACEHOLDERS_DBNAME=${DB_POWERBI_DBNAME}
export FLYWAY_PLACEHOLDERS_MASTERUSER=${DB_POWERBI_FLYWAY_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIPASSWORD=${DB_POWERBI_POWERBI_PASSWORD}
export FLYWAY_PLACEHOLDERS_POWERBIUSERNAME=${DB_POWERBI_POWERBI_USERNAME}

export SSPASSWORD=${DB_POWERBI_FLYWAY_PASSWORD}

export FLYWAY_LOCATIONS="filesystem:${BASEPATH}/schemas/powerbi"

flyway -configFiles=${BASEPATH}/docker/flyway_powerbi_docker.conf migrate
if [[ "$?" != 0 ]]
then
    echo "Error: migration of powerbi db failed"
    exit 1
fi

exit 0
