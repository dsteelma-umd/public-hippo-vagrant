# public-hippo-vagrant

HippoCMS development Vagrant environment

## Prerequisites

- VirtualBox
- Vagrant
- Oracle JDK 8 tar.gz (to be installed into the VM)
- [Hippo source code](https://github.com/umd-lib/public-hippo)

Due to the need to manually click through Oracle's license agreement in order to
download a JDK, the JDK is not automatically fetched by the provisioning
scripts. Instead, manually download a tar.gz distribution for 64-bit Linux from
[Oracle's site](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html)
and place it in a `dist/` subdirectory of the `public-hippo-vagrant` checkout
directory.

The bootstrap provisioning script will pick up any `jdk-*.tar.gz` file, but note
that production is currently using Java 8u112, so that is the recommended version
to use for local development.

## Usage

### Check out the Vagrant

```
> git clone git@github.com:umd-lib/public-hippo-vagrant.git
```

### Checkout the "env" repositories for the website and CMS

These should be placed in the same directory as the "public-hippo-vagrant"
directory:

```
> git clone https://github.com/umd-lib/public-hippo-cms-env.git
> git clone https://github.com/umd-lib/public-hippo-site-env.git
```
### Check out and compile the Hippo webapps

**Note:** the UMD public-hippo repository is private.

```
$ git clone git@github.com:umd-lib/public-hippo.git
$ cd public-hippo
$ mvn clean install
$ mvn -P split-dist -pl '!repository-war'
$ cp target/*.tar.gz ../public-hippo-vagrant/dist
```

### Obtain an Oracle JDK

See the [Prerequisites section](#prerequisites) for instructions.

### Bring up the Vagrant and start Tomcats

The [hippo.sh](scripts/hippo.sh) provisioning script currently looks for
distribution tarballs for Hippo version 10.1.1-0. If you deploy different version, you have to change that by setting the
`HIPPO_VERSION` environment variable before running `vagrant up`. The UMD Hippo server distribution tarballs should be copied to public-hippo-vagrant/dist directory.

```
If HIPPO_VERION is 11.2.4-0, public-11.2.4-0-cms-split-distribution.tar.gz and public-11.2.4-0-site-split-distribution.tar.gz shall be in public-hippo-vagrant/dist.
```


```
To start vagrant:
$ HIPPO_VERSION=11.2.4-0 vagrant up
```

This will create three virtual machines:

* postgres - Runs the Postgres server
* cms - Runs the CMS
* site - Runs the website

To access a particular VM, user:

```
> vagrant ssh <VM_NAME>
```

where "<VM_NAME>" is the name of the virtual machine. For example, to access the
CMS virtual machine:

```
> vagrant ssh cms
```

The CMS and site are not started automatically. To run the CMS, do the
following:

1) Login to the CMS virual machine:

```
> vagrant ssh cms
```

2) Switch to the "/apps/cms" directory and run the "control" script:

```
cms> cd /apps/cms/
cms> ./control start
```

Note: The first time the CMS is run, it may take several minutes (or longer) to
start, due to the need to populate the Postgres database with the bootstrap
data. See the "Refreshing the repository to shorten the development cycle"
section below for information on how to prepopulate the Postgres database.

You can watch the Tomcat log in a separate window by doing:

```
$ cd /apps/git/public-hippo-vagrant
# for the cms:
$ vagrant ssh cms -- tail -f /apps/cms/tomcat/logs/catalina.out
# or for the site:
$ vagrant ssh -- tail -f /apps/cms/tomcat-site1/logs/catalina.out
# or for the site2:
$ vagrant ssh -- tail -f /apps/cms/tomcat-site2/logs/catalina.out
```

Once both Tomcats start up, you should have a functioning web application on the
following URLs:

* CMS: <http://192.168.55.10/>
* CMS Console: <http://192.168.55.10/console/>
* Site: <http://192.168.55.20/>

In order to make channel manager work, change the property rest.uri in /hippo:configuration/hippo:frontend/cms/cms-services/hstRestProxyService.
rest.uri=http://127.0.0.1:9605/site/_cmsrest

## Structure

* **[dist/](dist):** Holding area for tarballs used by the provisioner (JDK,
  Tomcat, etc.); these are not stored under version control
* **[env/](env):** Config files copied by the shell provisioner
  [scripts](scripts)
* **[manifests/](manifests):** Puppet manifests for provisioning
* **[scripts/](scripts):** Shell scripts for provisioning
* **[Vagrantfile](Vagrantfile):** The Vagrantfile that controls it all

## Runtime Environment Structure

Within the **/apps/cms** directory on the VM, there is a parallel structure of 2
directories each for the CMS and the Site. These are:

* **tomcat-{cms,site1,site2}:** `CATALINA_BASE` directory containing the Tomcat runtime
  configuration files (including the repository.xml), the logs, and control
  script.
* **storage-{cms,site1,site2}:** Hippo local repository storage. Note that each
  instance needs its own storage directory, though they both use the same
  PostgreSQL database for persistance storage. This location is set using the
  `repo_path` environment variable in the
  **tomcat-{cms,site1,site2}/conf/env-config.properties** file.

There are two additional directories:

* **utilities:** Public utilities (e.g. the DBFinder loader script).
* **webapps:** WAR files. Note that the **public-hippo-$VERSION-site.war** file
  is shared between the two Tomcat instances.

## Refreshing the repository to shorten the development cycle

Once the environment is up, the cms and site have been started (to get the bootstrap loaded into the repository), and any modifications you wish to make to the repository hae been made, save the repository database to a backup file.

You should probably shut down the cms and site first to ensure that the repository is in the state you wish.

```
sudo -u postgres /usr/bin/pg_dump -Fc hippo --verbose > /vagrant/dist/dump-hippo.custom.0
```
You can restore the database repository with

```
sudo -u postgres /usr/bin/pg_restore --clean --verbose -d hippo /vagrant/dist/dump-hippo.custom.0
```
Storing the dump file in **/vagrant/dist** will ensure that it will not be erased when the vagrant is shut down.

If you wish to start the site after the database is restored, clean out the workspaces in **/apps/cms/storage-cms/workspaces** so that the indexes will be rebuilt.
