
mysql -uroot -p123456 -h127.0.0.1 -Ne "select concat('delete from ',table_name,';') from information_schema.tables where table_schema = 'venus' and table_name != 'tb_database_version'" > sql/clear.sql
mysql -uroot -p123456 -h127.0.0.1 -D venus < sql/clear.sql

pause