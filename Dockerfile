FROM php:7.0-apache
MAINTAINER Nick Budak <budak@lclark.edu>, Rishi Javia <rishijavia@lclark.edu>

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="Apache" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vcs-url="https://github.com/WatzekDigitalInitiatives/docker-omeka"

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y git imagemagick wget unzip
RUN docker-php-ext-install exif mysqli

# Install omeka
WORKDIR /var/www
RUN git clone --recursive https://github.com/omeka/Omeka.git
RUN chown -R root.www-data Omeka && chmod 775 Omeka
WORKDIR /var/www/Omeka
RUN rm db.ini.changeme
ADD db.ini ./db.ini
RUN rm .htaccess.changeme
ADD .htaccess ./.htaccess
RUN rm application/config/config.ini.changeme
ADD config.ini application/config/config.ini
RUN mv application/logs/errors.log.empty application/logs/errors.log
WORKDIR /var/www/Omeka/themes
RUN wget http://omeka.org/wordpress/wp-content/uploads/Emiglio-2.1.1.zip
RUN unzip Emiglio-2.1.1.zip
RUN rm Emiglio-2.1.1.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Avantgarde-1.zip
RUN unzip Avantgarde-1.zip
RUN rm Avantgarde-1.zip
WORKDIR /var/www/Omeka/plugins
RUN wget http://omeka.org/wordpress/wp-content/uploads/Omeka-Api-Import-1.1.1.zip
RUN unzip Omeka-Api-Import-1.1.1.zip
RUN rm Omeka-Api-Import-1.1.1.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Dropbox-0.7.2.zip
RUN unzip Dropbox-0.7.2.zip
RUN rm Dropbox-0.7.2.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Dropbox-0.7.2.zip
RUN unzip Dropbox-0.7.2.zip
RUN rm Dropbox-0.7.2.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Geolocation-2.2.5.zip
RUN unzip Geolocation-2.2.5.zip
RUN rm Geolocation-2.2.5.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/History-Log-2.6.zip
RUN unzip History-Log-2.6.zip
RUN rm History-Log-2.6.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Item-Order-2.0.2.zip
RUN unzip Item-Order-2.0.2.zip
RUN rm Item-Order-2.0.2.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Ngram-1.1.zip
RUN unzip Ngram-1.1.zip
RUN rm Ngram-1.1.zip
RUN wget http://omeka.org/wordpress/wp-content/uploads/Clean-Url-2.14.zip
RUN unzip Clean-Url-2.14.zip
RUN rm Clean-Url-2.14.zip
WORKDIR /var/www/Omeka
RUN find . -type d | xargs chmod 775
RUN find . -type f | xargs chmod 664
RUN find files -type d | xargs chmod 777
RUN find files -type f | xargs chmod 666

# Configure apache
ADD omeka.conf /etc/apache2/sites-available/omeka.conf
RUN a2enmod rewrite
RUN a2ensite omeka
RUN a2dissite 000-default
ENV APPLICATION_ENV development
ENV HTTPS false

# Configure php
ENV PHP_MEMORY_LIMIT 64M
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV PHP_POST_MAX_SIZE 10M

# Configure mysql
ENV OMEKA_DB_HOST localhost
ENV OMEKA_DB_USER omeka
ENV OMEKA_DB_PASSWORD omeka
ENV OMEKA_DB_NAME omeka
ENV OMEKA_DB_PREFIX _omeka
ENV OMEKA_DB_CHARSET utf8

# Add init script
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Expose 443 for https
EXPOSE 443

# Run the server
CMD ["/run.sh"]
