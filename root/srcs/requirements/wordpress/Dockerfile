FROM debian:bullseye

# Atualizar o sistema e instalar dependências
RUN apt update && apt upgrade -y && apt install -y \
  php7.4-fpm \
  php7.4-mysqli \
  curl \
  && apt clean

# Criar o diretório e ajustar permissões
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Copiar arquivos de configuração e script de instalação
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/.
COPY ./tools/wp-install.sh .

# Tornar o script executável
RUN chmod +x ./wp-install.sh

# Garantir que as permissões do diretório wp-content/uploads estejam corretas
RUN mkdir -p /var/www/html/wp-content/uploads \
  && chown -R www-data:www-data /var/www/html/wp-content \
  && find /var/www/html/wp-content/uploads -type d -exec chmod 755 {} \; \
  && find /var/www/html/wp-content/uploads -type f -exec chmod 644 {} \;

# Definir o entrypoint para executar o script de instalação do WordPress
ENTRYPOINT ["sh", "./wp-install.sh"]