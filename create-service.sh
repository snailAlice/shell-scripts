#!/usr/bin/env bash
#create servcie.sh scripts
echo "Input jar name:"  
read jar
echo "The jar name you input is: $jar" 

echo "Input server port name:"  
read port
echo "The server  port you input is: $port" 

echo "Input consul tag:"  
read tag
echo "The consul tag you input is: $tag"
csul=`echo $jar |awk -F '-server' '{ print $1 }'`
echo "ps -ef|grep $jar |grep -v grep|awk '{print \$2}'" >p

(
cat <<EOF
#!/bin/bash
#Desc: Script to restart, release or roll service

#================================================================================================
#Functions
#================================================================================================
function printUsage() {
  echo "usage: ${csul}-server.sh [restart|release|roll]"
}


function restartService() {
#重启脚本
cd /var/consul/services/
sudo grep -l $csul * |xargs sudo rm -f
/usr/local/bin/consul reload
sleep 20
cd /app/services/
pid=\`$(cat p)\`
if [ "\$pid" = "" ] ; then
    echo "$jar is shutdown now!"
else
    kill -9 \$pid
fi
sleep 3
echo start $jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
echo `ps -ef|grep $jar|grep -v grep`
sleep 10
pid2=\`$(cat p)\`
if [ "\$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
else
    echo "$jar is succeed!"
fi
}

function releaseService() {
#发布脚本
cd /var/consul/services/
sudo grep -l $csul * |xargs sudo rm -f
/usr/local/bin/consul reload
sleep 20
cd /app/services/
pid=\`$(cat p)\`
if [ "\$pid" = "" ] ; then
    echo "$jar is shutdown now!"
else
    kill -9 \$pid
fi
sleep 3
mv $jar /app/bak/${jar}_\$(date +%Y%m%d)
sleep 3
mv /app/pre/${jar} $jar

echo start $jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
sleep 10
pid2=\`$(cat p)\`
if [ "\$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
else
    echo "$jar is succeed!"
fi
}

function rollService() {
#回滚脚本
cd /var/consul/services/
sudo grep -l $csul * |xargs sudo rm -f
/usr/local/bin/consul reload
sleep 20
cd /app/services/
pid=\`$(cat p)\`
if [ "\$pid" = "" ] ; then
    echo "$jar is shutdown now!"
else
    kill -9 \$pid
fi
sleep 3
mv $jar /app/roll/${jar}_\$(date +%Y%m%d)
sleep 3
mv /app/bak/${jar}_\$(date +%Y%m%d) $jar

echo start $jar
sleep 2
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
sleep 10
pid2=\`$(cat p) \`
if [ "\$pid2" = "" ] ; then
nohup /usr/local/bin/java -Dservice.tag=$tag -Dserver.port=$port -jar $jar > /dev/null 2>&1 &
else
    echo "$jar is succeed!"
fi
}

#=============================================================================================
# Service restart, release and roll
#=============================================================================================
if [[ \$# -eq 0 ]]; then
    restartService
else
    case "\$1" in
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

EOF
) > ${csul}-server.sh

chmod 755 *.sh

