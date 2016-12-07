#!/bin/bash

mkdir -p /apps

# Oracle JDK
JDK=$(find /vagrant/dist -maxdepth 1 -type f -name 'jdk-*.tar.gz' | tail -n1)
if [ -z "$JDK" ]; then
    echo >&2 "No JDK found. Please download an Oracle JDK tar.gz and place it in [vagrant]/dist"
    exit 1
fi
echo "Found JDK in $JDK"
tar xzvf "$JDK" --directory /apps
# find the newly extracted JDK
JAVA_HOME=$(find /apps -maxdepth 1 -type d -name 'jdk*' | tail -n1)
ln -s "$JAVA_HOME" /apps/java
cat > /etc/profile.d/hippo.sh <<END
export JAVA_HOME=$JAVA_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
END

# Tomcat
# can't install via yum since that is only version 6.0.24
TOMCAT_VERSION=8.0.39
TOMCAT=/vagrant/dist/apache-tomcat-${TOMCAT_VERSION}.tar.gz
# look for a cached tarball
if [ ! -e "$TOMCAT" ]; then
    TOMCAT_PKG_URL=http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
    curl -Lso "$TOMCAT" "$TOMCAT_PKG_URL"
fi
tar xvzf "$TOMCAT" --directory /apps
chown -R vagrant:vagrant /apps/apache-tomcat-${TOMCAT_VERSION}

# Puppet Modules
puppet module install puppetlabs-firewall
puppet module install puppetlabs-postgresql

# runtime server environment
mkdir -p /apps/cms
chown -R vagrant:vagrant /apps/cms
