
# ======================================================================================

# The University of Edinburgh
# University Website Programme

# Build a Docker image containing a good-to-go EdWeb Distribution.
# For help and support, take a look at the wiki space (EASE log-in required):
# <add link when we're done.>

# Developed by: Angelos Athanasakos (angelos [dot] athanasakos [at] ed.ac.uk)
# Special thanks: Callum Kerr, Pat Fleury
# Version: 0.9
# Date: Feburary 2017

# ======================================================================================


# ======================================================================================
# === // LAMP stack
# === // CentOS 6, Apache 2.2.15, PHP 5.3.3, MySQL 5.1.7(3), xDebug 2.2.5
# ======================================================================================

FROM centos:6

RUN yum localinstall -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm

RUN yum install --enablerepo=ius -y \
  autoconf \
  automake \
  gcc \
  gcc-c++ \
  httpd \
  libapache2-mod-php5 \
  mysql-client \
  mysql-server \
  php \
  php-cli \
  php-curl \
  php-devel \
  php-gd \
  php-gettext \
  php-mbstring \
  php-mcrypt \
  php-dom \
  php-mysql \
  php-pear \
  supervisor \
  wget;

# Install xDebug
RUN pecl install xdebug-2.2.5; yum clean all

# End of LAMP stack



# ======================================================================================
# === // Install some additional applications (we think these are useful!)
# === // Drush
# ======================================================================================

# Install Drush (we need Console_Table as a Drush req.)
RUN pear install Console_Table
RUN wget --quiet -O - http://ftp.drupal.org/files/projects/drush-8.x-6.0-rc4.tar.gz | tar -zxf - -C /usr/local/share
RUN ln -s /usr/local/share/drush/drush /usr/local/bin/drush

ENV PHPMYADMIN_VERSION 4.0.10.19

# Setup PHPMyAdmin
RUN wget --quiet https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.bz2 \
&& tar -xvjf /phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.bz2 -C / \
&& rm /phpMyAdmin-${PHPMYADMIN_VERSION}-english.tar.bz2 \
&& mv /phpMyAdmin-${PHPMYADMIN_VERSION}-english /var && /bin/bash -c "adduser phpmy"

RUN cd /var && mv phpMyAdmin-${PHPMYADMIN_VERSION}-english phpmyadmin && \
chown -R phpmy.apache phpmyadmin/ && cd /var/phpmyadmin && mkdir config && chmod o+rw config && \
cp config.sample.inc.php config/config.inc.php && chmod o+w config/config.inc.php


# End of additional applications



# ======================================================================================
# === // Copy over configured files
# === // Pulls over customised configuration files, the filesystem and database images.
# ======================================================================================

# Move our Apache config file into the machine
COPY includes/lamp/httpd.conf /etc/httpd/conf/httpd.conf

# Move our MySQL config into the machine
COPY includes/lamp/my.cnf /etc/my.cnf

# Move our php config into the machine
COPY includes/lamp/php.ini /etc/php.ini

# CentOS supervisor
COPY includes/lamp/supervisord.conf /etc/supervisord.conf

# Nice wee phpinfo page for debugging.
COPY includes/lamp/phpinfo.php /var/www/html/phpinfo.php

# PHPMyAdmin config file
COPY includes/lamp/config.inc.php  /var/phpmyadmin/config/config.inc.php

# Mapping
RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/my.cnf

# script for running container
COPY includes/scripts/run.sh /usr/local/bin/run.sh

# Give the run.sh file execute permissions, we'll run this via the CMD command at the end of this file.
RUN chmod +x /usr/local/bin/run.sh

# Give MYSQL
RUN service httpd start && service mysqld start && mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');" 

# End of copying configuration files



# ======================================================================================
# === // Wrap up
# ======================================================================================

# Set the PWD to the root html folder.
WORKDIR /var/www/html

# Make a temp html folder (this prevents some odd stuff happening with shared folders later).
RUN mkdir -p /var/www/html-temp && chmod -R 777 /var/www/html-temp && cp -r /var/www/html/. /var/www/html-temp

# Setup the shared folders container.
VOLUME /var/www/html

# Expose the HTTP and MySQL ports.
EXPOSE 80 3306 9000

# Run the bash script. This script sets up a load of cool shit.
CMD ["/usr/local/bin/run.sh"]












