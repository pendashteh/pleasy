function debug () {
phpcli="/etc/php/7.2/cli/php.ini"
phpapache="/etc/php/7.2/apache2/php.ini"

case $1 in
  on)
    sudo sed -i 's/xdebug.profiler_enable=0/xdebug.profiler_enable=1/g' $phpapache
    sudo sed -i 's/xdebug.remote_enable=0/xdebug.remote_enable=1/g' $phpapache
    sudo sed -i 's/xdebug.remote_autostart=0/xdebug.remote_autostart=1/g' $phpapache
    sudo sed -i 's/;zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/g' $phpapache

    sudo sed -i 's/xdebug.profiler_enable=0/xdebug.profiler_enable=1/g' $phpcli
    sudo sed -i 's/xdebug.remote_enable=0/xdebug.remote_enable=1/g' $phpcli
    sudo sed -i 's/xdebug.remote_autostart=0/xdebug.remote_autostart=1/g' $phpcli
    sudo sed -i 's/;zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/g' $phpcli

    sudo service apache2 restart
  ;;
  off)
    sudo sed -i 's/xdebug.profiler_enable=1/xdebug.profiler_enable=0/g' $phpapache
    sudo sed -i 's/xdebug.remote_enable=1/xdebug.remote_enable=0/g' $phpapache
    sudo sed -i 's/xdebug.remote_autostart=1/xdebug.remote_autostart=0/g' $phpapache
    sudo sed -i 's/zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/;zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/g' $phpapache

    sudo sed -i 's/xdebug.profiler_enable=1/xdebug.profiler_enable=0/g' $phpcli
    sudo sed -i 's/xdebug.remote_enable=1/xdebug.remote_enable=0/g' $phpcli
    sudo sed -i 's/xdebug.remote_autostart=1/xdebug.remote_autostart=0/g' $phpcli
    sudo sed -i 's/zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/;zend_extension = \/usr\/lib\/php\/20151012\/xdebug.so/g' $phpcli

    sudo sed -i 's/xdebug.profiler_enable=1/xdebug.profiler_enable=0/g' $phpapache
    sudo service apache2 restart
  ;;
  *)
    echo "Usage: php_debug on|off"
  ;;
esac

}