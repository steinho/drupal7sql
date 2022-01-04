FROM drupal:7-apache-buster

# RUN  composer require drupal/sqlsrv

RUN apt-get update && \
    apt-get install -y unixodbc-dev gnupg libgssapi-krb5-2

RUN curl -s -N https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update

RUN pecl install sqlsrv && pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /usr/local/etc/php/conf.d/docker-php-ext-sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /usr/local/etc/php/conf.d/docker-php-ext-pdo_sqlsrv.ini
RUN printf "pdo_sqlsrv.client_buffer_max_kb_size = 24480\nwincache.ucachesize = 20\n" > /usr/local/etc/php/conf.d/custom.ini
RUN printf "wincache.ucachesize = 20\n" > /usr/local/etc/php/conf.d/custom2.ini

# # nødvendig sql odbc driver 48 
#RUN apt-get update
# # RUN apt-get install gnupg -y
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools

RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN set -eux; \
	curl -fSL "https://ftp.drupal.org/files/projects/sqlsrv-7.x-2.x-dev.tar.gz" -o sqlsrv-7.x-2.x-dev.tar.gz; \
	tar -xz --strip-components=1 -f sqlsrv-7.x-2.x-dev.tar.gz -C /var/www/html/includes/database; \
	rm sqlsrv-7.x-2.x-dev.tar.gz; \
# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# RUN php composer-setup.php
# RUN php -r "unlink('composer-setup.php');"
# # RUN mv composer.phar /usr/local/bin/composer
# RUN php composer.phar require drupal/sqlsrv