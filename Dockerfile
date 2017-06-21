FROM debian:8

#will run apache
CMD apache2ctl -D FOREGROUND

#on port 80
EXPOSE 80

RUN apt-get update && apt-get install -y \
		apache2 \
		wget \
		php5-common \
		libapache2-mod-php5 \
		php5-cli \
                gcc \
                libjansson4 \
                libhiredis0.10 \
                libcurl3 \
        && wget --quiet --output-document=/tmp/libcjose.deb https://github.com/pingidentity/mod_auth_openidc/releases/download/v2.0.0/libcjose_0.4.1-1_amd64.deb \
        && wget --quiet --output-document=/tmp/oidc.deb https://github.com/pingidentity/mod_auth_openidc/releases/download/v2.0.0/libapache2-mod-auth-openidc_2.0.0-1_amd64.deb \
        && dpkg -i /tmp/libcjose.deb /tmp/oidc.deb \
        && rm -f /tmp/oidc.deb /tmp/libcjose.deb \
        && rm -rf /var/lib/apt/lists/*

RUN a2enmod \
		auth_openidc \
		ssl \
		authz_groupfile \
		headers \
		rewrite \
		proxy_wstunnel \
		proxy \
		proxy_http

