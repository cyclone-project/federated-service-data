FROM debian

#will run apache
CMD apache2ctl -D FOREGROUND

#on port 80
EXPOSE 80

RUN apt-get update && apt-get install -y \
		apache2 \
		nano \
		wget \
	&& wget --quiet --output-document=/tmp/oidc.deb https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.8.8/libapache2-mod-auth-openidc_1.8.8-1_amd64.deb \
	 ; dpkg -i /tmp/oidc.deb \
	 ; apt-get install -fy \
	&& dpkg -i /tmp/oidc.deb \
	&& rm /tmp/oidc.deb \
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

