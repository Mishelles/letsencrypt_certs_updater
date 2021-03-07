# Let's Encrypt Certs Updater: automate your boring stuff with letsencrypt and certbot

## What does this script do?

This is a command line tool for updating expired SSL certificates with certbot.
The script gets domain names from nginx sites enabled directory. After that it checks certificates expiration date with *openssl*. If certificate expiration date 

The script assumes that the certificate was issued using certbot with nginx plugin.

## Why not use native certbot update mechanism?

Native certbot auto-renew script works with limited number of domains. So, we need a solution for update certs one by one.

## How to use?

1. Clone:
```
git clone https://github.com/Mishelles/letsencrypt_certs_updater.git
```
2. Make it executable:
```
cd letsencrypt_certs_updater && chmod +x update_certs.sh
```
3. Run:
```
./letsencrypt_certs_updater/update_certs.sh
```

## Setting up scheduled certificates update

You can also add this script into your crontab.
For example, with the following cron configuration the script invokes every day at 2 a.m.:

```
0 2 * * * /<your path>/update_certs.sh
```

## Additional configuration

You can configure the script by setting the follofing enviroment variables:

| Variable                 | Description                                                     | Default Value            |
|--------------------------|-----------------------------------------------------------------|--------------------------|
| SITES_ENABLED_DIR        | Enabled virtual hosts location                                  | /etc/nginx/sites-enabled |
| LETSENCRYPT_CERTS_DIR    | Location where certbot stores all certificates                  | /etc/letsencrypt/live/   |
| GRACE_DAYS               | Number of days until the certificate expires                    | 3                        |
| EXCEPTION_DOMAINS_REGEXP | For these domains script will not check and update certificates | .int.\|default           |