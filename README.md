# nginx-php-for-azure
Nginx and PHP docker container for use primarily in Azure App Services - works in other environments such as bare metal though.

## Built with the following PHP Versions
- 8.1
- 8.2
- 8.3
- 8.4

Append "php" to the beginning of the PHP version for the image name, e.g "php8.2"  
Recommend you only use supported PHP versions, the rest are for backwards compatibility and may be removed in the future.

## Configurable environment variables with defaults listed below
- PORT = 8080
- NGINX_VIRTUAL_HOST = _
- NGINX_ROOT = /var/www/html
- TZ = Europe/London

## Opens port 2222 for Azure SSH

## Licensed under GPL 3.0
Please open source any changes you make!
