#!/bin/sh

DOMAIN="avi.alkalay.net"
MULTISITE_ID=2

OLD_HOST="mysql.alkalay.net"
OLD_USER="blog"
OLD_DB="blog_57"
OLD_TABLE_PREFIX="wp_"

NEW_HOST=$OLD_HOST
NEW_USER=$OLD_USER
NEW_DB="blog2"
NEW_TABLE_PREFIX=$OLD_TABLE_PREFIX

echo
echo "Export and convert..."
mysqldump -h "$OLD_HOST" -u "$OLD_USER" -p --add-drop-table $OLD_DB |

sed -e "
	s|^DROP TABLE IF EXISTS \`${OLD_TABLE_PREFIX}|DROP TABLE IF EXISTS \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^CREATE TABLE \`${OLD_TABLE_PREFIX}|CREATE TABLE \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^LOCK TABLES \`${OLD_TABLE_PREFIX}|LOCK TABLES \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^INSERT INTO \`${OLD_TABLE_PREFIX}|INSERT INTO \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|ALTER TABLE \`${OLD_TABLE_PREFIX}|ALTER TABLE \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|${OLD_TABLE_PREFIX}user_roles|${NEW_TABLE_PREFIX}${MULTISITE_ID}_user_roles|g;
" | gzip -c -9 > "$DOMAIN".multisite.sql.gz


echo
echo "Import converted..."
zcat "$DOMAIN".multisite.sql.gz | mysql -h "$NEW_HOST" -u "$NEW_USER" -p "$NEW_DB"



