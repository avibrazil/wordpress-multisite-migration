#!/bin/sh

# mysqldump -h 'mysql.alkalay.net' -u blog -p --add-drop-table blog_57

OLD_TABLE_PREFIX="wp_"
NEW_TABLE_PREFIX="wp_"

MULTISITE_ID=2

sed -e "
	s|^DROP TABLE IF EXISTS \`${OLD_TABLE_PREFIX}|DROP TABLE IF EXISTS \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^CREATE TABLE \`${OLD_TABLE_PREFIX}|CREATE TABLE \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^LOCK TABLES \`${OLD_TABLE_PREFIX}|LOCK TABLES \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
	s|^INSERT INTO \`${OLD_TABLE_PREFIX}|INSERT INTO \`${NEW_TABLE_PREFIX}${MULTISITE_ID}_|g;
"	

