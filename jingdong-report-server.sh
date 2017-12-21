#!/bin/bash
#Desc: Script to restart, release or roll service

#================================================================================================
#Functions
#================================================================================================
function printUsage() {
  echo "usage: jingdong-report-server.sh [restart|release|roll]"
}


function restartService() {
#重启
cd /data/mj/consul/data/services/
grep -l  jingdong-report-service * |xargs rm -f
/data/mj/consul/bin/consul reload
sleep 20
cd /app/services/
pid=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi

echo start jingdong-report-service-server-1.0-SNAPSHOT.jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
echo 
sleep 10
pid2=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is succeed!"
fi
}

function releaseService() {
#发布脚本
cd /data/mj/consul/data/services/
grep -l jingdong-report-service * |xargs rm -f
/data/mj/consul/bin/consul reload
sleep 20
cd /app/services/
pid=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi
sleep 3
mv jingdong-report-service-server-1.0-SNAPSHOT.jar /app/bak/jingdong-report-service-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d)
sleep 3
mv /app/pre/jingdong-report-service-server-1.0-SNAPSHOT.jar jingdong-report-service-server-1.0-SNAPSHOT.jar

echo start jingdong-report-service-server-1.0-SNAPSHOT.jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
sleep 10
pid2=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is succeed!"
fi
}

function rollService() {
#回滚脚本
cd /data/mj/consul/data/services/
grep -l jingdong-report-service * |xargs rm -f
/data/mj/consul/bin/consul reload
sleep 20
cd /app/services/
pid=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'`
if [ "$pid" = "" ] ; then
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is shutdown now!"
else
    kill -9 $pid
fi
sleep 3
mv jingdong-report-service-server-1.0-SNAPSHOT.jar /app/roll/jingdong-report-service-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d)
sleep 3
mv /app/bak/jingdong-report-service-server-1.0-SNAPSHOT.jar_$(date +%Y%m%d) jingdong-report-service-server-1.0-SNAPSHOT.jar

echo start jingdong-report-service-server-1.0-SNAPSHOT.jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
sleep 10
pid2=`ps -ef|grep jingdong-report-service-server-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}' `
if [ "$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=prod -Dserver.port=9999 -jar jingdong-report-service-server-1.0-SNAPSHOT.jar > /dev/null 2>&1 &
else
    echo "jingdong-report-service-server-1.0-SNAPSHOT.jar is succeed!"
fi
}

#=============================================================================================
# Service restart, release and roll
#=============================================================================================
if [[ $# -eq 0 ]]; then
    restartService
else
    case "$1" in
        restart)
            restartService
            ;;
        release)
            releaseService
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

