#!/usr/bin/env bash

# Ensure environment values are not exposed in drone output
set +x

echo "Exporting environment variables"

#export DB_POWERBI_DBNAME=${DB_POWERBI_DBNAME}
#export DB_POWERBI_HOSTNAME=${DB_POWERBI_HOSTNAME}
#export DB_POWERBI_PORT=${DB_POWERBI_PORT}
#export DB_POWERBI_JDBC_OPTIONS=${DB_POWERBI_JDBC_OPTIONS}
export URL="sqlserver://${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT}/${DB_POWERBI_DBNAME}"
export FLYWAY_URL="jdbc:"sqlserver://${DB_POWERBI_HOSTNAME};user=${DB_POWERBI_FLYWAY_USERNAME};password=${DB_POWERBI_FLYWAY_PASSWORD};databaseName=${DB_POWERBI_DBNAME};${DB_POWERBI_JDBC_OPTIONS}""


#export DB_POWERBI_DATABRICKS_USERNAME=${DB_POWERBI_DATABRICKS_USERNAME}
#export DB_POWERBI_DATABRICKS_PASSWORD=${DB_POWERBI_DATABRICKS_PASSWORD}
#export DB_POWERBI_POWERBI_USERNAME=${DB_POWERBI_POWERBI_USERNAME}
#export DB_POWERBI_POWERBI_PASSWORD=${DB_POWERBI_POWERBI_PASSWORD}

export FLYWAY_PLACEHOLDERS_MASTERUSER=${DB_POWERBI_FLYWAY_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIOWNERNAME=$DB_POWERBI_POWERBI_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIOWNERPASSWORD=$DB_POWERBI_POWERBI_PASSWORD}
export FLYWAY_PLACEHOLDERS_POWERBISCHEMA=$DB_POWERBI_POWERBI_SCHEMA}
export SSPASSWORD=${DB_POWERBI_FLYWAY_PASSWORD}

export BASEPATH="${PWD}"
echo "Running from base path: ${BASEPATH}"

echo "Checking if SQL server is up and ready for connections"
i=0
/opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -Q "SELECT DATABASEPROPERTYEX(N'database name', 'Collation')" -t 5
SS_EXIT=$?
while [[ "${i}" -lt "15" && ${SS_EXIT} != 0 ]]
do
    echo "waiting for SQL Server to start, attempt: ${i}"
    sleep 5s
    if [[ "${i}" > 15 ]]
    then
        echo "Error: failed waiting for SQL Server to start"
        exit 1
    fi
    ((i++))
    /opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -Q "SELECT DATABASEPROPERTYEX(N'database name', 'Collation')" -t 5
    SS_EXIT=$?
done


echo "Creating initial databases"
export FLYWAY_USER=${DB_POWERBI_FLYWAY_USERNAME}
export FLYWAY_PASSWORD=${DB_POWERBI_FLYWAY_PASSWORD}


echo "Checking if database exists"
STATUS=$( /opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -Q "SELECT DATABASEPROPERTYEX(N'database name', 'Collation')" -t 5)
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
    /opt/mssql-tools/bin/sqlcmd -S ${DB_POWERBI_HOSTNAME} -U ${DB_POWERBI_FLYWAY_USERNAME} -P ${DB_POWERBI_FLYWAY_PASSWORD} -Q /tmp/bootstrap.sql -t 5
    if [[ "$?" != 0 ]]
    then
        echo "Error: with bootstrapping database"
        exit 1
    fi
fi

echo "Migrating powerbi database"
#export FLYWAY_URL="jdbc:"sqlserver://${DB_POWERBI_FLYWAY_USERNAME}@${DB_POWERBI_HOSTNAME}:${DB_POWERBI_PORT};databaseName=${DB_POWERBI_DBNAME};${DB_POWERBI_JDBC_OPTIONS}""
 
export FLYWAY_USER=$DB_POWERBI_POWERBI_USERNAME}
export FLYWAY_PASSWORD=$DB_POWERBI_POWERBI_PASSWORD}
export FLYWAY_SCHEMAS=$DB_POWERBI_POWERBI_SCHEMA}
export FLYWAY_PLACEHOLDERS_SCHEMA=$DB_POWERBI_POWERBI_SCHEMA}

export FLYWAY_PLACEHOLDERS_DATABRICKSPASSWORD=$DB_POWERBI_DATABRICKS_PASSWORD}
export FLYWAY_PLACEHOLDERS_DATABRICKSUSER=$DB_POWERBI_DATABRICKS_USERNAME}
export FLYWAY_PLACEHOLDERS_POWERBIPASSWORD=$DB_POWERBI_POWERBI_PASSWORD}
export FLYWAY_PLACEHOLDERS_POWERBIUSER=$DB_POWERBI_POWERBI_USERNAME}

export FLYWAY_LOCATIONS="filesystem:${BASEPATH}/schemas/powerbi"

flyway -configFiles=${BASEPATH}/docker/flyway_powerbi_docker.conf migrate
if [[ "$?" != 0 ]]
then
    echo "Error: migration of powerbi db failed"
    exit 1
fi

exit 0
