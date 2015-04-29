/etc/init.d/apache2 start
/etc/init.d/mysql start
exec tail -f /home/myqpp/app/current/log/production.log
