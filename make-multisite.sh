#!/bin/bash

MULTISITE_ID=2

OLD_DOMAIN="avi.alkalay.net"
OLD_DB_HOST="mysql.alkalay.net"
OLD_DB_USER="blog"
OLD_DB="blog_57"
OLD_TABLE_PREFIX="wp_"

NEW_DOMAIN="avi.alkalay.net"
NEW_DB_HOST=$OLD_DB_HOST
NEW_DB_USER=$OLD_DB_USER
NEW_DB="alkalay_net_wordpress_multisite"
NEW_TABLE_PREFIX=$OLD_TABLE_PREFIX

echo
echo "Export and convert..."
mysqldump -h "$OLD_DB_HOST" -u "$OLD_DB_USER" -p --add-drop-table "$OLD_DB" |

sed -e "
	s|^DROP TABLE IF EXISTS \`${OLD_TABLE_PREFIX}|DROP TABLE IF EXISTS \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^CREATE TABLE \`${OLD_TABLE_PREFIX}|CREATE TABLE \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^LOCK TABLES \`${OLD_TABLE_PREFIX}|LOCK TABLES \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^INSERT INTO \`${OLD_TABLE_PREFIX}|INSERT INTO \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|ALTER TABLE \`${OLD_TABLE_PREFIX}|ALTER TABLE \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|${OLD_TABLE_PREFIX}user_roles|${NEW_TABLE_PREFIX}${MULTISITE_ID}_user_roles|g;
" | gzip -c -9 > "$NEW_DOMAIN".multisite.sql.gz


echo
echo "Import converted..."
zcat "$NEW_DOMAIN".multisite.sql.gz | mysql -h "$NEW_DB_HOST" -u "$NEW_DB_USER" -p "$NEW_DB"


echo
echo "Last instrumentations..."

mysql -h "$NEW_DB_HOST" -u "$NEW_DB_USER" -p "$NEW_DB" <<EndOfInstrumentation
UPDATE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options SET option_value = 'https://${NEW_DOMAIN}' WHERE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options.option_name = 'home';
UPDATE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options SET option_value = 'https://${NEW_DOMAIN}' WHERE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options.option_name = 'siteurl';
UPDATE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options SET option_value = 'https://${NEW_DOMAIN}' WHERE ${NEW_TABLE_PREFIX}${MULTISITE_ID}_options.option_name = 'oid_trust_root';
EndOfInstrumentation

# Later, I found this as a nice writeup about DB migration:
# https://deliciousbrains.com/wp-migrate-db-pro/doc/exporting-single-site-as-subsite-for-multisite-install/