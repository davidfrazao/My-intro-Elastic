attach shell 

# show numeric owners
ls -n /opt/cerebro/conf

# show numeric owner for one file
stat -c '%u:%g %n' /opt/cerebro/conf/application.conf

# show the process user/group ids
id -u
id -g
