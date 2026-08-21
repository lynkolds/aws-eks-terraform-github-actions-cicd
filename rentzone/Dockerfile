FROM amazonlinux:2

# Update all installed packages to thier latest versions
RUN yum update -y 

# Install unzip, wget, and Apache in a single layer to reduce image size
RUN yum install -y unzip wget httpd

# Install PHP and various extensions
RUN amazon-linux-extras enable php7.4 && \
  yum clean metadata && \
  yum install -y \
    php \
    php-common \
    php-pear \
    php-cgi \
    php-curl \
    php-mbstring \
    php-gd \
    php-mysqlnd \
    php-gettext \
    php-json \
    php-xml \
    php-fpm \
    php-intl \
    php-zip

# Download the MySQL repository package
RUN wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm

# Import the GPG key for the MySQL repository
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# Install the MySQL repository package
RUN yum localinstall mysql80-community-release-el7-3.noarch.rpm -y

# Install the MySQL community server package
RUN yum install mysql-community-server -y

# Change directory to the html directory
WORKDIR /var/www/html

# Copy the web file zip to a temporary location and unzip it there
COPY rentzone/rentzone.zip /tmp/

# Create a temporary directory, unzip the web files there, copy the unzipped files to the html directory and then remove the temporary directory and the zip file
RUN mkdir -p /tmp/webfiles && \
    unzip /tmp/rentzone.zip -d /tmp/webfiles && \
    cp -av /tmp/webfiles/rentzone/. /var/www/html/ && \
    rm -rf /tmp/webfiles /tmp/rentzone.zip


# Enable the mod_rewrite setting in the httpd.conf file
RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

RUN chown -R apache:apache /var/www/html
RUN chmod -R 755 /var/www/html
RUN chmod -R 775 /var/www/html/storage

# Copy the file, AppServiceProvider.php from the host file system into the container at the path app/Providers/AppServiceProvider.php
COPY rentzone/AppServiceProvider.php app/Providers/AppServiceProvider.php

# Expose the default Apache and MySQL ports
EXPOSE 80 3306

# Start Apache and MySQL
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
