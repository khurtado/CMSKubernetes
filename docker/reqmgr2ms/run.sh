#!/bin/bash
srv=`echo $USER | sed -e "s,_,,g"`

echo Line 1 > /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# overwrite host PEM files in /data/srv area
if [ -f /etc/secrets/robotkey.pem ]; then
    sudo cp /etc/secrets/robotkey.pem /data/srv/current/auth/$srv/dmwm-service-key.pem
    sudo cp /etc/secrets/robotcert.pem /data/srv/current/auth/$srv/dmwm-service-cert.pem
    sudo chown $USER.$USER /data/srv/current/auth/$srv/dmwm-service-key.pem
    sudo chown $USER.$USER /data/srv/current/auth/$srv/dmwm-service-cert.pem
fi

# overwrite proxy if it is present in /etc/proxy
if [ -f /etc/proxy/proxy ]; then
    export X509_USER_PROXY=/etc/proxy/proxy
    mkdir -p /data/srv/state/$srv/proxy
    if [ -f /data/srv/state/$srv/proxy/proxy.cert ]; then
        rm /data/srv/state/$srv/proxy/proxy.cert
    fi
    ln -s /etc/proxy/proxy /data/srv/state/$srv/proxy/proxy.cert
    mkdir -p /data/srv/current/auth/proxy
    if [ -f /data/srv/current/auth/proxy/proxy ]; then
        rm /data/srv/current/auth/proxy/proxy
    fi
    ln -s /etc/proxy/proxy /data/srv/current/auth/proxy/proxy
fi
echo Line 2 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# overwrite header-auth key file with one from secrets
if [ -f /etc/secrets/hmac ]; then
    mkdir -p /data/srv/current/auth/wmcore-auth
    if [ -f /data/srv/current/auth/wmcore-auth/header-auth-key ]; then
        sudo rm /data/srv/current/auth/wmcore-auth/header-auth-key
    fi
    sudo cp /etc/secrets/hmac /data/srv/current/auth/wmcore-auth/header-auth-key
    sudo chown $USER.$USER /data/srv/current/auth/wmcore-auth/header-auth-key
    mkdir -p /data/srv/current/auth/$srv
    if [ -f /data/srv/current/auth/$srv/header-auth-key ]; then
        sudo rm /data/srv/current/auth/$srv/header-auth-key
    fi
    sudo cp /etc/secrets/hmac /data/srv/current/auth/$srv/header-auth-key
    sudo chown $USER.$USER /data/srv/current/auth/$srv/header-auth-key
fi
echo Line 3 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# In case there is at least one configuration file under /etc/secrets, remove
# the default config files from the image and copy over those from the secrets area
cdir=/data/srv/current/config/$srv
cfiles="config-monitor.py config-output.py config-transferor.py"
for fname in $cfiles; do
    if [ -f /etc/secrets/$fname ]; then
        pushd $cdir
        rm $cfiles
        popd
        break
    fi
done

echo Line 4 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

for fname in $cfiles; do
    if [ -f /etc/secrets/$fname ]; then
        sudo cp /etc/secrets/$fname $cdir/$fname
        sudo chown $USER.$USER $cdir/$fname
    fi
done

echo Line 5 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

files=`ls $cdir`
for fname in $files; do
    if [ -f /etc/secrets/$fname ]; then
        if [ -f $cdir/$fname ]; then
            rm $cdir/$fname
        fi
        sudo cp /etc/secrets/$fname $cdir/$fname
        sudo chown $USER.$USER $cdir/$fname
    fi
done

echo Line 6 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

files=`ls /etc/secrets`
for fname in $files; do
    if [ ! -f $cdir/$fname ]; then
        sudo cp /etc/secrets/$fname /data/srv/current/auth/$srv/$fname
        sudo chown $USER.$USER /data/srv/current/auth/$srv/$fname
    fi
done
echo Line 7 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# Sleep for a while before starting services
sleep 2
echo ls -l $cdir >> /tmp/debug
ls -l $cdir >> /tmp/debug 2>&1

# start the service
# if it is ms-output, then we also need to start mongodb
#if [ -f $cdir/config-output.py ]; then
#    echo "I got in this if" >> /tmp/debug
#    /data/srv/current/config/mongodb/manage start 'I did read documentation'
#fi

echo Line 8 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

#echo /data/srv/current/config/$srv/manage start 'I did read documentation' >> /tmp/debug
#/data/srv/current/config/$srv/manage start 'I did read documentation'

echo Line 9 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# run monitoring script
#if [ -f /data/monitor.sh ]; then
#    /data/monitor.sh
#fi
echo Line 10 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug

# start cron daemon
#sudo /usr/sbin/crond -n
sleep 5

echo Line 11 >> /tmp/debug
date >> /tmp/debug
echo 'ps aux | grep mongodb'
ps aux | grep mongodb >> /tmp/debug
