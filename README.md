# Postgres_Shell_Script
Shell Script for PostgreSQL to promote Replication DB to Master DB when Master DB shut down

This shell script is for PostgreSQL Standby as Replication DB to be promoted to Master DB When you set them as Streaming replication not Log-Shipping.

It is health-checking Master DB with curl and deleting WAL Files that you are saving for back-up if Master DB is alive and your storage is up to specific number percentage.

and you should edit crontab in your linux, and user **MUST** be **postgres**.
ex) crontab -u postgres -e

#every minute, your script will run.

&ast; &ast; &ast; &ast; &ast; /your/script/path/
