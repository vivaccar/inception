# Inception - 42 Project

## Introduction

Inception is a project from the 42 curriculum that introduces students to system administration and containerization using Docker. The goal is to set up a multi-container environment using `Docker Compose`, following strict guidelines to ensure a secure and scalable deployment.

In this project, you will build your own Docker-based system, running multiple services in isolated containers. By doing so, you will gain a deeper understanding of how containerization works and how to manage services efficiently in a production-like environment.

---

## What is Docker?

Docker is an open-source platform that enables developers to automate the deployment, scaling, and management of applications using containers. It allows applications to run consistently across different environments by packaging them with all their dependencies.

A **Docker container** is a lightweight, standalone, and executable package that includes everything needed to run a piece of software, including the operating system, libraries, and dependencies. Containers ensure that applications work reliably regardless of where they are deployed.

---

## What is a Container?

A **container** is an isolated environment that runs a specific application along with its dependencies. Unlike virtual machines, containers share the host system's kernel, making them more lightweight and efficient.

### Key benefits of containers:

- **Portability**: Containers can run on any system that has Docker installed.
- **Scalability**: Multiple containers can be deployed and orchestrated to handle varying workloads.
- **Isolation**: Each container operates independently, preventing conflicts between applications.

---

## What is Docker Compose?

**Docker Compose** is a tool that allows you to define and manage multi-container applications using a YAML file (`docker-compose.yml`). Instead of manually running multiple `docker run` commands, Docker Compose simplifies the process by defining services, networks, and volumes in a single configuration file.

### With Docker Compose, you can:

- Define multiple services and their dependencies.
- Specify networking rules between containers.
- Manage persistent data storage with volumes.
- Easily start and stop entire environments with:

---

## Nginx Container

Nginx is a high-performance web server that can also be used as a reverse proxy, load balancer, and HTTP cache. In the Inception project, Nginx is used to serve web pages securely over HTTPS using SSL.

### Mapping Port 443
To expose HTTPS traffic, you need to map the container's port `443` to the host machine's port `443` in `docker-compose.yml`:

```yaml
services:
  nginx:
    ports:
      - "443:443"
```

### Configuring Nginx for SSL
Inside the Nginx configuration file (`/etc/nginx/nginx.conf`), you must specify that the server should listen on port `443` and use an SSL certificate:

```nginx
server {
    listen 443 ssl;
    server_name your_domain.com;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root /var/www/html;
        index index.html;
    }
}
```

Ensure that the certificate and key files exist in the container at `/etc/nginx/ssl/`. You can generate a self-signed certificate using:

```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx.key -out nginx.crt
```

The NGINX Dockerfile will be:

```dockerfile
FROM debian:bullseye

ARG CRED_PATH CRED_CERT CRED_KEY COUNTRY STATE LOCAL ORGANIZATION UNIT COMMON_NAME #Variables that will be used in the construction of the certificate.

RUN apt update && apt upgrade -y && apt install -y nginx openssl gettext-base

RUN mkdir -p ${CRED_PATH}

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout ${CRED_PATH}/${CRED_KEY} \
-out ${CRED_PATH}/${CRED_CERT} \
-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCAL}/O=${ORGANIZATION}/OU=${UNIT}/CN=${COMMON_NAME}"

COPY conf/nginx.conf .

RUN envsubst '$CRED_PATH $CRED_KEY $CRED_CERT $COMMON_NAME' < nginx.conf > /tmp/nginx.conf

RUN mv /tmp/nginx.conf /etc/nginx/sites-available/default

ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

This setup ensures that Nginx properly handles HTTPS requests and serves content securely.

---

## WordPress Container

WordPress is a popular content management system (CMS) that requires PHP and a database to function. In this project, WordPress will run in a separate container with `php-fpm` to process PHP scripts.

### Installing PHP-FPM and WordPress
To run WordPress efficiently, the container needs `php-fpm`, which handles PHP execution, and the WordPress files themselves.

A Dockerfile for the WordPress container might look like this:

```dockerfile
FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y \
  php7.4-fpm \
  php7.4-mysqli \
  curl \
  && apt clean

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php 

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/.
COPY ./tools/wp-install.sh .

RUN chmod +x ./wp-install.sh #THIS IS A SCRIPT TO CONFIGURE WP-CONFIN.PHP check tools/wp-install.sh

RUN mkdir -p /var/www/html/wp-content/uploads \
  && chown -R www-data:www-data /var/www/html/wp-content \
  && find /var/www/html/wp-content/uploads -type d -exec chmod 755 {} \; \
  && find /var/www/html/wp-content/uploads -type f -exec chmod 644 {} \;

ENTRYPOINT ["sh", "./wp-install.sh"]
```

### Exposing Port 9000
To allow communication between the WordPress container and Nginx, you need to expose port `9000` in `docker-compose.yml`:

```yaml
services:
  wordpress:
    build: ./wordpress
    expose:
      - "9000"
```

### Configuring Nginx to Use PHP-FPM
Inside the Nginx configuration file, update the `location` block to forward PHP requests to the WordPress container:

```nginx
server {
    listen 443 ssl;
    server_name your_domain.com;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;

    }
}
```

This setup ensures that Nginx correctly forwards PHP requests to the WordPress container running `php-fpm` on port `9000`.

---

## MariaDB Container

MariaDB is an open-source relational database management system that is a drop-in replacement for MySQL. It is used to store and manage the WordPress database.

### Setting Up the MariaDB Container
The MariaDB container must be configured with a root password and a database for WordPress. This can be done using environment variables in `docker-compose.yml`:

```yaml
services:
  mariadb:
    build: requirements/mariadb/.
    container_name: mariadb
    restart: on-failure
    networks:
      - inception
    expose:
      - "3306"
    volumes:
      - database:/var/lib/mysql
    env_file:
      - .env
```

### Connecting WordPress to MariaDB
In the WordPress configuration file (`wp-config.php`), update the database connection settings:

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wp_user');
define('DB_PASSWORD', 'wp_password');
define('DB_HOST', 'mariadb');
```

With this setup, WordPress will connect to the MariaDB container to store and retrieve data.

---





