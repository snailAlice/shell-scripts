#!/bin/bash
#Desc: Script to restart, release or roll service
#Author: wangxiangyang
#create by 2017-12-08

#==========================================================
#Functions
#==========================================================
function printUsage() {
  echo "usage: $0 [start|stop|restart]"
}


function restartService() {
#重启脚本
cd /var/consul/services/
sudo grep -l crawler-chsi * |xargs sudo rm -f
/usr/local/bin/consul reload
cd /app/services/
pid=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "crawler-chsi-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi
echo start crawler-chsi-server-1.0-SNAPSHOT.jar
sleep 3
nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &

echo `ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar|grep -v grep`
sleep 10
pid2=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid2" = "" ] ; then
    nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "succeed!"
fi

	
}

function releaseService() {
#发布脚本
cd /var/consul/services/
sudo grep -l crawler-chsi * |xargs sudo rm -f
/usr/local/bin/consul reload
cd /app/services/
pid=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "crawler-chsi-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi
sleep 2
mv crawler-chsi-server-1.0-SNAPSHOT.jar /app/bak/crawler-chsi-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d)
sleep 2
mv /app/pre/crawler-chsi-server-1.0-SNAPSHOT.jar crawler-chsi-server-1.0-SNAPSHOT.jar
echo start crawler-chsi-server-1.0-SNAPSHOT.jar
sleep 3
nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &

echo `ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar|grep -v grep`
sleep 10
pid2=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid2" = "" ] ; then
    nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "succeed!"
fi
	
}

function rollService() {
#回滚脚本
cd /var/consul/services/
sudo grep -l crawler-chsi * |xargs sudo rm -f
/usr/local/bin/consul reload
cd /app/services/
pid=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "crawler-chsi-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi
sleep 2
mv crawler-chsi-server-1.0-SNAPSHOT.jar /app/roll/crawler-chsi-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d)
sleep 2
mv /app/bak/crawler-chsi-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d) crawler-chsi-server-1.0-SNAPSHOT.jar
echo start crawler-chsi-server-1.0-SNAPSHOT.jar
sleep 3
nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &

echo `ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar|grep -v grep`
sleep 10
pid2=`ps -ef|grep crawler-chsi-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid2" = "" ] ; then
    nohup /usr/local/bin/java -jar -Dserver.port=8023 -Dservice.tag=prod crawler-chsi-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "succeed!"
fi
	
}

#================================================
# Service restart, release and roll
#================================================
if [[ $# -eq 0 ]]; then
    restartService
else
    case "$1" in
        restart)
            restartService
            ;;
        release)
            stopService
            ;;
        roll)
            rollService
            ;;
        -h)
            printUsage
            ;;
        *)
            >&2 echo "invalid argument"
            printUsage
            exit 1
            ;;
    esac
fi
