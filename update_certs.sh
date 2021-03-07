#!/bin/bash
# This is a command line tool for updating expired SSL certificates with certbot.
# Currently this script works only with nginx.
#
# Copyright 2021 Mike Sergeenkov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Enabled virtual hosts location
SITES_ENABLED_DIR="${SITES_ENABLED_DIR:-"/etc/nginx/sites-enabled"}"
# Location where certbot stores all certificates
LETSENCRYPT_CERTS_DIR="${LETSENCRYPT_CERTS_DIR:-"/etc/letsencrypt/live/"}"
# Number of days until the certificate expires
GRACE_DAYS="${GRACE_DAYS:-3}"
# For these domains script will not check and update certificates
EXCEPTION_DOMAINS_REGEXP="${EXCEPTION_DOMAINS_REGEXP:-.int.|default}"

affected_domains=()

printf "Script started\n\n"

printf "Parsing $SITES_ENABLED_DIR for domains...\n\n"
for filename in $(ls $SITES_ENABLED_DIR); do
    # For every domain get certificate expiration date
    if [[ ! $filename =~ $EXCEPTION_DOMAINS_REGEXP ]]; then
        echo "Getting expration date for $filename"
        certificate_file_path="$LETSENCRYPT_CERTS_DIR$filename/fullchain.pem"
        if [ -f $certificate_file_path ]; then
            certificate_data=`echo | openssl x509 -enddate -noout -in "$LETSENCRYPT_CERTS_DIR$filename/fullchain.pem" | sed -e 's#notAfter=##'`
            certificate_end_date=`date -d "${certificate_data}" '+%s'`
            current_date=`date '+%s'`
            diff="$((${certificate_end_date}-${current_date}))"
            if test "${diff}" -lt "$((${GRACE_DAYS}*24*3600))";
            then
                #certbot --nginx certonly -n --force-renewal -d $filename > 2>/dev/null
                echo 'certbot'
                if [ $? -eq 0 ]; then
                    certificate_data=`echo | openssl x509 -enddate -noout -in "$LETSENCRYPT_CERTS_DIR$filename/fullchain.pem" | sed -e 's#notAfter=##'`
                    certificate_end_date=`date -d "${certificate_data}" '+%Y-%m-%d'`
                    echo "Certificate had been successfully updated for domain $filename and valid before $certificate_end_date"
                    affected_domains+=( $filename )
                else
                    echo "Unable to update certificate for domain $filename: /var/log/letsencrypt for more details"
                fi
            else
                echo "Certificate for domain $filename will expire in more then $GRACE_DAYS. Skipping."
            fi    
        else 
            echo "Unable to get certificate file for domain $filename: file does not exist"
        fi
        echo "--------"
    fi

done

# Restart nginx to apply newly generated certificates
# nginx -t 2>/dev/null
echo 'nginx -t'
if [ $? -eq 0 ]; then
    # service nginx restart 2>/dev/null
    echo 'nginx restart'
    echo "Script successfully finished."
    echo "Certificates updated for ${#affected_domains[@]} domains"
    printf '%s\n' "${affected_domains[@]}"
    exit 0
else
    echo "Script finished with error. Check nginx config and nginx logs."
    exit 1
fi