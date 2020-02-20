#!/bin/bash

HOSTS='/etc/apache2/sites-enabled/'

for file in `ls $HOSTS`
do
        echo $file
        cat $HOSTS$file | grep --color -E "ServerName|DocumentRoot"
done
