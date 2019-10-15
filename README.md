## SNGULAR WORDPRESS TEMPLATE

Wordpress SNG template installation

#### INSTALLATION

1. Clone template repository

```
git clone git@gitlab.sngular.com:SNG09C/wp-template-website.git
```

2. Copy content to your new Wordpres installation directory

```
mkdir NAME-WEBSITE
cp -rpf wp-template-website/* NAME-WEBSITE/
```

3. Copy Sngular Project Plugin

```
cp -rpf /path/to/sng/NAME-PLUGIN NAME-WEBSITE/plugins
```

4. Copy Sngular Project Theme

```
cp -rpf /path/to/sng/NAME-THEME NAME-WEBSITE/themes
```

5. Edit **env-template** file and set required information
6. Move **env-template** to **.env**

```
mv env-template .env
```

7. Edit **wp-config.template** and set required information (same as set in **.env-template**)

```
define( 'DB_NAME', 'MYSQL_DATABASE' );
define( 'DB_USER', 'MYSQL_USER' );
define( 'DB_PASSWORD', 'MYSQL_PASSWORD' );
```

8. Move **wp-config.template** to **wp-config.php**

```
mv wp-config.template wp-config.php
```

9. On **plugins** dir, edit *requirements.txt* and add desired install plugins and their versions. Example:

```
wordpress-seo==11.4
wp-mail-smtp==1.4.2
```

#### OUTSTANDING WORDPRESS PLUGINS

To install buyed plugins or plugins that are not avaliable on wordpress site, uncompress the zip and copy the plugin folder on plugins local folder.

```

cp buyed-plugins NAME-WEBSITE/plugins
```
It will be avaliable to activate on your installation

#### RUNNING CONTAINER

Once you have completed your installation, run it.

```
cd NAME-WEBSITE
docker-compose up --build
```

To access  your installation, open a web browser and browse http://localhost


When you access for first time you will be asked to give an administrator name and password.


Then you can go to http://localhost and log with your admin credentials.

