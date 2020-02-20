#!/bin/bash

APACHE_VHOSTS=/etc/apache2/sites-enabled
NGINX_VHOSTS=/etc/nginx/sites-enabled

function show_vhosts {
    for file in `ls $1`
    do
        echo -e "\n$1/$file"
        cat $1/$file | grep --color -E "ServerName|DocumentRoot|server_name|root"
    done
}

if [[ -d $APACHE_VHOSTS ]]; then
    show_vhosts $APACHE_VHOSTS
fi

if [[ -d $NGINX_VHOSTS ]]; then
    show_vhosts $NGINX_VHOSTS
fi

