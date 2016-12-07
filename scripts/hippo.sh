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
for APP in cms site; do
    HIPPO_DIST=/vagrant/dist/public-${HIPPO_VERSION}-${APP}-distribution.tar.gz
    # webapps and utilities
    tar xvzf "$HIPPO_DIST" --directory /apps/cms webapps utilities
    
    # per-Tomcat runtime common and shared libs
    tar xvzf "$HIPPO_DIST" --directory /apps/cms/tomcat-${APP} common shared
    
    sed -i "s/hippo.version=.*/hippo.version=$HIPPO_VERSION/" \
        /apps/cms/tomcat-${APP}/conf/catalina.properties
    cp "$PGSQL_JDBC" /apps/cms/tomcat-${APP}/common/lib
done

# Set up site2 after renaming site to site1
cd /apps/cms/
mv tomcat-site tomcat-site1
cd /apps/cms/tomcat-site1
cp -r common /apps/cms/tomcat-site2/
cp -r shared /apps/cms/tomcat-site2/
sed -i "s/hippo.version=.*/hippo.version=$HIPPO_VERSION/" \
    /apps/cms/tomcat-site2/conf/catalina.properties
cp "$PGSQL_JDBC" /apps/cms/tomcat-site2/common/lib
      
# copy utilities property file
UTILITIES_PROPERTIES=/vagrant/env/.public-utilities.properties
cp "$UTILITIES_PROPERTIES" /home/vagrant
