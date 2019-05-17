# Varnish Docker Container Image

[![Build Status](https://travis-ci.org/wodby/varnish.svg?branch=master)](https://travis-ci.org/wodby/varnish)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/varnish.svg)](https://hub.docker.com/r/wodby/varnish)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/varnish.svg)](https://hub.docker.com/r/wodby/varnish)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/varnish.svg)](https://microbadger.com/images/wodby/varnish)

* [Docker images](#docker-images)
* [Environment variables](#environment-variables)
* [Installed modules](#installed-modules)
* [Default behaviour](#default-behaviour)
    * [Caching rules](#caching-rules)
    * [Cache personification](#cache-personification)
    * [GeoIP](#geoip)
    * [Currency](#currency)    
    * [Flushing](#cache-flushing)
    * [Miscellaneous](#miscellaneous)
* [Config presets](#config-presets)
    * [Drupal](#drupal)
    * [WordPress](#wordpress)    
* [Orchestration actions](#orchestration-actions)    
* [Deployment](#deployment)    

## Docker Images

❗For better reliability we release images with stability tags (`wodby/varnish:6-X.X.X`) which correspond to [git tags](https://github.com/wodby/varnish/releases). We strongly recommend using images only with stability tags. 

# Exemple d'usage drupal varnish_auth :
 ## basé sur https://joshwaihi.com/content/authenticated-page-caching-varnish-drupal

Changer le hostname de wwwsst.local à votre nom de hôte de ton site web. Éditer presets/drupal.vcl.tmpl
Changer le chemin vers le module drupal varnish_auth (sandbox pour l'instant https://www.drupal.org/sandbox/leonnk/2128311 ), change ceci: /profiles/portail/modules/custom/varnish_auth/access_check.php
 à /sites/all/modules/contrib/varnish_auth/access_check.php se trouve aussi dans presets/drupal.vcl.tmpl 
Quand ton config est bon lance un sudo make.
Changer l'adresse ip 172.17.0.1 à l'adresse ip de ton hôte docker contenant apache et ton site web Drupal.
Changer VARNISH_SECRET de 00000000-bbbb-cccc-dddd-eeeeeeeee999 à ton secret si exclus un code sera généré par le serveur.

sudo make;

sudo docker -D run --detach \
  -e VARNISH_BACKEND_HOST=wwwsst.local \
  -e VARNISH_SECRET=00000000-bbbb-cccc-dddd-eeeeeeeee999 \
  -e VARNISH_CONFIG_PRESET=drupal \
  --add-host "wwwsst.local:172.17.0.1" \
  --name=varnish \
  -itd entreprise7pro/varnish:6.0

S'assurer que ton docker fonctionnent:
sudo docker ps;

Déclenche une session bash afin de contrôler ton serveur varnish: sudo exec -it varnish bash

Dépistage: varnishlog

# varnish_auth j'ai dû adapter le vcl 3.x à 4.x/6.x comme ci mentionné https://varnish-cache.org/docs/5.1/whats-new/upgrading-4.0.html

# Drupal config (varnish_auth) cacher les pages authentifiés.
  Activer le module varnish_auth suit les conseils dans README.txt sauf ignorer example.vcl ceci étant déjà dans les fichiers .tmpl de entreprise7pro/varnish.

  Si ce n'est pas déjà configuré ajouter le config varnish dans ton fichier drupal settings.php
   ex: 
// sites/default/settings.php
// Le chiffre '2' correspond au rôle 'authenticated user' , si tu veut d'autres rôles configuré il faut alors ajouter les autres.
$conf['varnish_auth_roles'] = array(2);
$conf['varnish_auth_domains'] = array('wwwsst.local'); // Change wwwsst.local à votre domaine.

// Ajouter ceci pour varnish!
$base_path = ($dir = rtrim(dirname($_SERVER['SCRIPT_NAME']), '\/')) ? $dir . '/' : '/';
ini_set('session.cookie_path', $base_path);
$conf['cache_backends'] = array('sites/all/modules/contrib/varnish/varnish.cache.inc');
$conf['cache_class_cache_page'] = 'VarnishCache';




Overview:

* All images are based on Alpine Linux
* Base image: [wodby/alpine](https://github.com/wodby/alpine)
* [Travis CI builds](https://travis-ci.org/wodby/varnish) 
* [Docker Hub](https://hub.docker.com/r/wodby/varnish)

Supported tags and respective `Dockerfile` links:

* `6.0`, `6`, `latest` [_(Dockerfile)_](https://github.com/wodby/varnish/tree/master/Dockerfile)
* `4.1`, `4` [_(Dockerfile)_](https://github.com/wodby/varnish/tree/master/Dockerfile)

## Environment Variables

| Variable                                   | Default Value              | Description                                     |
| ------------------------------------------ | -------------------------- | ----------------------------------              |
| `VARNISH_ALLOW_UNRESTRICTED_PURGE`         |                            | Used for ban requests as well                   |
| `VARNISH_BACKEND_BETWEEN_BYTES_TIMEOUT`    | `60s`                      |                                                 |
| `VARNISH_BACKEND_CONNECT_TIMEOUT`          | `3.5s`                     |                                                 |
| `VARNISH_BACKEND_FIRST_BYTE_TIMEOUT`       | `60s`                      |                                                 |
| `VARNISH_BACKEND_GRACE`                    | `2m`                       |                                                 |
| `VARNISH_BACKEND_HOST`                     |                            | Mandatory                                       |
| `VARNISH_BACKEND_PORT`                     | `80`                       |                                                 |
| `VARNISH_CACHE_PER_COUNTRY`                |                            | Separate caches based on [country code](#geoip) |
| `VARNISH_CACHE_PER_CURRENCY`               |                            | Separate caches based on [currency](#currency)  |
| `VARNISH_CURRENCY_EUR_COUNTRY_CODES`       |                            | See [currencies](#currency)                     |
| `VARNISH_CURRENCY_USD_COUNTRY_CODES`       |                            | See [currencies](#currency)                     |
| `VARNISH_BIG_FILES_SIZE`                   | `10485760`                 | 10MB                                            |
| `VARNISH_BIG_FILES_TTL`                    | `120s`                     |                                                 |
| `VARNISH_CACHE_STATIC_FILES`               |                            |                                                 |
| `VARNISH_CONFIG_PRESET`                    |                            |                                                 |
| `VARNISH_DEFAULT_TTL`                      | `120s`                     |                                                 |
| `VARNISH_ERRORS_GRACE`                     | `15s`                      |                                                 |
| `VARNISH_PURGE_EXTERNAL_REQUEST_HEADER`    |                            |                                                 |
| `VARNISH_KEEP_ALL_COOKIES`                 |                            |                                                 |
| `VARNISH_KEEP_ALL_PARAMS`                  |                            |                                                 |
| `VARNISH_IMPORT_MODULES`                   |                            | Separated by comma                              |
| `VARNISH_MOBILE_DISABLE_CASH`              |                            |                                                 |
| `VARNISH_MOBILE_SEPARATE_CASH`             |                            |                                                 |
| `VARNISH_MOBILE_USER_AGENT`                |                            | See default value below                         |
| `VARNISH_PIPE_CLOSE_CONNECTION`            |                            |                                                 |
| `VARNISH_PURGE_KEY`                        |                            | Randomly generated if missing                   |
| `VARNISH_SECONDARY_STORAGE_CONDITION`      |                            | Must be valid VCL                               |
| `VARNISH_SECRET`                           |                            | Generated automatically if missing              |
| `VARNISH_STATIC_FILES`                     |                            | See default value below                         |
| `VARNISH_STATIC_TTL`                       | `86400`                    | In seconds                                      |
| `VARNISH_STRIP_COOKIES`                    |                            | See default value below                         |
| `VARNISH_STRIP_PARAMS`                     |                            | See default value below                         |
| `VARNISH_STRIP_ALL_PARAMS`                 |                            | Ignored if `$VARNISH_KEEP_ALL_PARAMS` is set    |
| `VARNISHD_DEFAULT_TTL`                     | `120`                      |                                                 |
| `VARNISHD_MEMORY_SIZE`                     | `64m`                      |                                                 |
| `VARNISHD_PARAM_BAN_LURKER_AGE`            | `60.000`                   |                                                 |
| `VARNISHD_PARAM_BAN_LURKER_BATCH`          | `1000`                     |                                                 |
| `VARNISHD_PARAM_BAN_LURKER_SLEEP`          | `0.010`                    |                                                 |
| `VARNISHD_PARAM_BETWEEN_BYTES_TIMEOUT`     | `60.000`                   |                                                 |
| `VARNISHD_PARAM_CONNECT_TIMEOUT`           | `3.500`                    |                                                 |
| `VARNISHD_PARAM_DEFAULT_GRACE`             | `10.000`                   |                                                 |
| `VARNISHD_PARAM_DEFAULT_KEEP`              | `0.000`                    |                                                 |
| `VARNISHD_PARAM_DEFAULT_TTL`               | `120.000`                  |                                                 |
| `VARNISHD_PARAM_FETCH_CHUNKSIZE`           | `16k`                      |                                                 |
| `VARNISHD_PARAM_FIRST_BYTE_TIMEOUT`        | `60.000`                   |                                                 |
| `VARNISHD_PARAM_GZIP_BUFFER`               | `32k`                      |                                                 |
| `VARNISHD_PARAM_GZIP_LEVEL`                | `6`                        |                                                 |
| `VARNISHD_PARAM_GZIP_MEMLEVEL`             | `8`                        |                                                 |
| `VARNISHD_PARAM_HTTP_GZIP_SUPPORT`         | `on`                       |                                                 |
| `VARNISHD_PARAM_HTTP_MAX_HDR`              | `64`                       |                                                 |
| `VARNISHD_PARAM_HTTP_REQ_HDR_LEN`          | `8k`                       |                                                 |
| `VARNISHD_PARAM_HTTP_REQ_SIZE`             | `32k`                      |                                                 |
| `VARNISHD_PARAM_HTTP_RESP_HDR_LEN`         | `8k`                       |                                                 |
| `VARNISHD_PARAM_HTTP_RESP_SIZE`            | `32k`                      |                                                 |
| `VARNISHD_PARAM_IDLE_SEND_TIMEOUT`         | `60.000`                   |                                                 |
| `VARNISHD_PARAM_MAX_ESI_DEPTH`             | `5`                        |                                                 |
| `VARNISHD_PARAM_MAX_RESTARTS`              | `4`                        |                                                 |
| `VARNISHD_PARAM_MAX_RETRIES`               | `4`                        |                                                 |
| `VARNISHD_PARAM_NUKE_LIMIT`                | `50`                       |                                                 |
| `VARNISHD_PARAM_PING_INTERVAL`             | `3`                        |                                                 |
| `VARNISHD_PARAM_PIPE_TIMEOUT`              | `60.000`                   |                                                 |
| `VARNISHD_PARAM_POOL_REQ`                  | `10,100,10`                |                                                 |
| `VARNISHD_PARAM_POOL_SESS`                 | `10,100,10`                |                                                 |
| `VARNISHD_PARAM_PREFER_IPV6`               | `off`                      |                                                 |
| `VARNISHD_PARAM_RUSH_EXPONENT`             | `3`                        |                                                 |
| `VARNISHD_PARAM_SEND_TIMEOUT`              | `600`                      |                                                 |
| `VARNISHD_PARAM_SHORTLIVED`                | `10.000`                   |                                                 |
| `VARNISHD_PARAM_TCP_KEEPALIVE_INTVL`       | `75.000`                   |                                                 |
| `VARNISHD_PARAM_TCP_KEEPALIVE_PROBES`      | `8`                        |                                                 |
| `VARNISHD_PARAM_TCP_KEEPALIVE_TIME`        | `7200.000`                 |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_ADD_DELAY`     | `0.000`                    |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_DESTROY_DELAY` | `1.000`                    |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_FAIL_DELAY`    | `0.200`                    |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_MAX`           | `5000`                     |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_MIN`           | `100`                      |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_STACK`         | `48k`                      |                                                 |
| `VARNISHD_PARAM_THREAD_POOL_TIMEOUT`       | `300.000`                  |                                                 |
| `VARNISHD_PARAM_THREAD_POOLS`              | `2`                        |                                                 |
| `VARNISHD_PARAM_THREAD_QUEUE_LIMIT`        | `20`                       |                                                 |
| `VARNISHD_PARAM_TIMEOUT_IDLE`              | `5.000`                    |                                                 |
| `VARNISHD_PARAM_TIMEOUT_LINGER`            | `0.050`                    |                                                 |
| `VARNISHD_PARAM_VSL_BUFFER`                | `4k`                       |                                                 |
| `VARNISHD_PARAM_VSL_RECLEN`                | `255b`                     |                                                 |
| `VARNISHD_PARAM_VSL_SPACE`                 | `80M`                      |                                                 |
| `VARNISHD_PARAM_VSM_SPACE`                 | `1M`                       |                                                 |
| `VARNISHD_PARAM_WORKSPACE_BACKEND`         | `64k`                      |                                                 |
| `VARNISHD_PARAM_WORKSPACE_CLIENT`          | `64k`                      |                                                 |
| `VARNISHD_PARAM_WORKSPACE_SESSION`         | `0.50k`                    |                                                 |
| `VARNISHD_PARAM_WORKSPACE_THREAD`          | `2k`                       |                                                 |
| `VARNISHD_SECONDARY_STORAGE`               |                            | See example below                               |
| `VARNISHD_SECRET_FILE`                     | `/etc/varnish/secret`      |                                                 |
| `VARNISHD_VCL_SCRIPT`                      | `/etc/varnish/default.vcl` |                                                 |

###### `VARNISH_MOBILE_USER_AGENT`:

Backslashes must be escaped as `\\`

```
ipod|android|blackberry|phone|mobile|kindle|silk|fennec|tablet|webos|palm|windows ce|nokia|philips|samsung|sanyo|sony|panasonic|ericsson|alcatel|series60|series40|opera mini|opera mobi|au-mic|audiovox|avantgo|blazer|danger|docomo|epoc|ericy|i-mode|ipaq|midp-|mot-|netfront|nitro|pocket|portalmmm|rover|sie-|symbian|cldc-|j2me|up\\.browser|up\\.link|vodafone|wap1\\.|wap2\\.
```

###### `VARNISH_STATIC_FILES`:

```
asc|doc|xls|ppt|csv|svg|jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|html|htm
```

###### `VARNISH_STRIP_COOKIES`

Ignored if `$VARNISH_KEEP_ALL_COOKIES` is set

```
__[a-z]+|wooTracker|VCKEY-[a-zA-Z0-9-_]+
```

###### `VARNISH_STRIP_PARAMS`

Ignored if `$VARNISH_KEEP_ALL_PARAMS` is set

```
utm_[a-z]+|gclid|cx|ie|cof|siteurl|fbclid
```

###### `VARNISH_SECONDARY_STORAGE_CONDITION`:

Allows defining custom conditions for storing the cache object in the secondary storage; as it is injected into an `if` it has to contain valid VCL syntax for it.

Please note that `VARNISHD_SECONDARY_STORAGE` must be defined as well, otherwise the secondary storage would not be available.

Example: instruct varnish to store in the secondary storage from the backend via custom header `X-Cache-Bin`:

```
VARNISH_STORAGE_CONDITION='beresp.http.x-cache-bin = "secondary"'
```

## Installed modules

| Module                                                                                      | Version | Imported |
| ------                                                                                      | ------- | -------- |
| [geoip](https://github.com/varnish/libvmod-geoip)                                           | 1.0.3   | ✓        |
| [cookie](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_cookie.rst)       | latest  |          |
| [vsthrottle](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_cookie.rst)   | latest  |          |
| [header](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_header.rst)       | latest  |          |
| [saintmode](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_saintmode.rst) | latest  |          |
| [softpurge](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_softpurge.rst) | latest  |          |
| [tcp](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_tcp.rst)             | latest  |          |
| [var](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_var.rst)             | latest  |          |
| [xkey](https://github.com/varnish/varnish-modules/blob/master/docs/vmod_xkey.rst)           | latest  |          |
| bodyaccess                                                                                  | latest  |          |

Modules can be imported as `$VARNISH_IMPORT_MODULES=xkey,softpurge`.

## Default behaviour

### Caching rules

* Only GET or HEAD requests are cached
* Backend responses with `Set-Cookie` header not cached
* Static files (see `$VARNISH_STATIC_FILES`) not cached by default, set `$VARNISH_CACHE_STATIC_FILES` to cache
* Error pages 404 and >500 not cached with grace period `$VARNISH_ERRORS_GRACE`
* All AJAX requests not cached
* Big files (larger than `$VARNISH_BIG_FILES_SIZE`) not cached

### Cache personification

White-listed cookies starting with `VCKEY-` followed by alphanumeric characters, underscores or hyphens are used to build cache hash. You can use such cookies to personify cache by a certain criteria, e.g. set `VCKEY-lang` to `en` or `fr` to cache different versions for English and French users.

On your backend you should check whether `VCKEY-` cookie exists, if it does generate a personified version of a page and do not set cookie again, otherwise it won't be cached on Varnish. 

### GeoIP

We identify client's two-letter country code ([ISO 3166](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)) and pass it to a backend in `X-Country-Code` header. If Varnish could not recognize the country the default value will be `Unknown`. You can optionally uniquify cache per country by setting `$VARNISH_CACHE_PER_COUNTRY=1`. We use GeoLite database from MaxMind.


If we see CloudFlare country code header we use it instead.

### Currency

We use [the country code](#geoip) to identify the currency and pass it to a backend in `X-Currency` header. You can optionally uniquify cache per currency by setting `$VARNISH_CACHE_PER_CURRENCY=1`. 

We use data from [IBAN](https://www.iban.com/currency-codes) to identify which country uses which currency, currently only USD and EUR supported.

Country codes for USD (`$VARNISH_CURRENCY_USD_COUNTRY_CODES`): 
```
US|AS|BQ|IO|EC|SV|GU|HT|MH|FM|MP|PA|PW|PR|TL|TC|UM|VG|VI
```

Country codes for EUR (`$VARNISH_CURRENCY_EUR_COUNTRY_CODES`):
```
AD|AT|BE|CY|EE|FI|FR|GF|TF|DE|GP|GR|VA|IE|IT|LV|LT|LU|MT|MQ|YT|MC|ME|NL|PT|RE|BL|MF|PM|SM|SK|SI|ES|CE|CH|AX
```

### Cache flushing

* Purge and ban requests both use Varnish's `ban` method to flush cache and restricted by the purge key `$VARNISH_PURGE_KEY` (generated if missing). Use header `X-VC-Purge-Key` to pass the key for purge/ban requests
* Purge requests look up for exact match but ignores query params, you can change the method by setting `X-VC-Purge-Method` to `regex` or `exact` (respects query params)
* Additionally for ban requests cache flushed by `Cache-Tags` header (Drupal's case)
* If you want to allow unrestricted purge/ban requests in internal network specify a header via `$VARNISH_PURGE_EXTERNAL_REQUEST_HEADER` that exists only for external requests (e.g. `X-Real-IP`). If specified header is not set Varnish will skip purge key check

### Miscellaneous

* Header `X-VC-Cache` set to `HIT` or `MISS` when varnish delivers content
* Cache hash includes host (or ip) and request protocol
* Varnish adds client's IP added to `X-Forwarded-For`
* [Websocket requests supported](https://varnish-cache.org/docs/4.1/users-guide/vcl-example-websockets.html)
* Query params (`$VARNISH_STRIP_PARAMS`) stripped unless `$VARNISH_KEEP_ALL_PARAMS` is set
* Cookies (`$VARNISH_STRIP_COOKIES`) stripped unless `$VARNISH_KEEP_ALL_COOKIES` is set
* Hashes and trailing `?` stripped from URL before passing to backend
* By default cache mobile devices is identical. You can separate it by setting `$VARNISH_MOBILE_SEPARATE_CASH` or completely disable by setting `$VARNISH_MOBILE_DISABLE_CASH`. Regex `$VARNISH_MOBILE_USER_AGENT` used to identify mobile devices by `User-Agent` header 
* Set one of the following headers from backend to disable caching for a page: 
    ```
    X-VC-Cacheable: NO
    Cache-control: private
    Cache-control: no-cache
    ```
* Set `X-VC-Debug` to show cache hashes and pass through header `X-VC-DebugMessage`
* `BigPipe` supported
* Secondary storage can be defined via `$VARNISH_STORAGE_CONDITION`

## Config presets

You can use one of the following config presets to extend the default behaviour:

### Drupal

Add `VARNISH_CONFIG_PRESET=drupal` to use this preset.

* Pages matching `$VARNISH_DRUPAL_EXCLUDE_URLS` will not be cached
* If a cookie from `$VARNISH_DRUPAL_PRESERVED_COOKIES` is set a page will not be cached. All other cookies stripped  

###### `VARNISH_DRUPAL_EXCLUDE_URLS`:

Backslashes must be escaped as `\\`

```
^(/update\\.php|/([a-z]{2}/)?admin|/([a-z]{2}/)?admin/.*|/([a-z]{2}/)?system/files/.*|/([a-z]{2}/)?flag/.*|.*/ajax/.*|.*/ahah/.*)$
```

###### `VARNISH_DRUPAL_PRESERVED_COOKIES`:

Not affected by `$VARNISH_KEEP_ALL_COOKIES`

```
SESS[a-z0-9]+|SSESS[a-z0-9]+|NO_CACHE
```

### WordPress

Add `VARNISH_CONFIG_PRESET=wordpress` to use this preset.

* Requests with `ak_action|app-download` query params or `akm_mobile` cookie not cached (Jetpack plugin)
* Strips `replytocom=` query param
* Use `$VARNISH_WP_ADMIN_SUBDOMAIN` if you have your admin on a subdomain to disable caching 
* If a cookie from `$VARNISH_WP_PRESERVED_COOKIES` is set a page will not be cached. All other cookies stripped

###### `VARNISH_WP_PRESERVED_COOKIES`:

Not affected by `$VARNISH_KEEP_ALL_COOKIES`

```
PHPSESSID|wp-postpass_[a-z0-9]+|wordpress_[_a-z0-9]+|wordpress_logged_in_[a-z0-9]+|woocommerce_cart_hash|woocommerce_items_in_cart|wp_woocommerce_session_[a-z0-9]+|akm_mobile
```

## Orchestration Actions

```
make COMMAND [params ...]

commands:
    check-ready [host max_try wait_seconds delay_seconds]
    flush [host]
 
default params values:
    host localhost
    max_try 1
    wait_seconds 1
    delay_seconds 0
```

## Deployment

Deploy Varnish container to your own server via [![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby](https://wodby.com/stacks/varnish).
