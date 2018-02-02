#!/bin/bash

# Deploys the HippoCMS distribution tarballs.
# Usage: hippo.sh [version]

# need the Postgres JDBC
PGSQL_JDBC_VERSION=9.4.1212
PGSQL_JDBC=/vagrant/dist/postgresql-${PGSQL_JDBC_VERSION}.jar
if [ ! -e "$PGSQL_JDBC" ]; then
    PGSQL_JDBC_URL=https://jdbc.postgresql.org/download/postgresql-${PGSQL_JDBC_VERSION}.jar
    curl -Lso "$PGSQL_JDBC" "$PGSQL_JDBC_URL"
fi

# deploy Hippo from dist tarballs
HIPPO_VERSION=${1:-10.1.1-0}

# Load the tar files
HIPPO_DIST=/vagrant/dist/public-${HIPPO_VERSION}-cms-split-distribution.tar.gz
    
# webapps and utilities
tar xvzf "$HIPPO_DIST" --directory /apps/cms webapps utilities
    
#tar xvzf "$HIPPO_DIST" --directory /apps/cms/tomcat common shared
    
sed -i "s/hippo.version=.*/hippo.version=$HIPPO_VERSION/" \
        /apps/cms/tomcat/conf/catalina.properties

POSTGRES_URL=192.168.55.100
sed -i "s/hippo.database.url=jdbc:postgresql:\/\/pgcommondev.lib.umd.edu:5439\/hippo/hippo.database.url=jdbc:postgresql:\/\/$POSTGRES_URL:5432\/hippo/g" \
        /apps/cms/tomcat/conf/catalina.properties
        
cp "$PGSQL_JDBC" /apps/cms/tomcat/common/lib

# copy utilities property file
UTILITIES_PROPERTIES=/vagrant/env/.public-utilities.properties
cp "$UTILITIES_PROPERTIES" /home/vagrant