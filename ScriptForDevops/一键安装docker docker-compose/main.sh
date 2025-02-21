#!/bin/bash

#环境变量PATH没设好，在cron里执行时有很多命令会找不到
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

#引入函数文件
source ./function.sh

#set -e选项保证程序的每一步都执行正确,如果前面一部程序执行错误,则直接退出程序
#set -e

#仓库密码
Warehouse_passwd="Inw0k26x4L"

#获取当前服务器的IP地址
NIC_Name=`ls /etc/sysconfig/network-scripts | grep ifcfg | grep -v 'lo' | awk -F '-' '{print $2}'`
IPADDR=`ifconfig $NIC_Name | grep inet | grep -v inet6 | awk '{print $2}'`

#日志路径
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
[ -f $PROGPATH ] && PROGPATH="."
LOGPATH="$PROGPATH/log"
[ -e $LOGPATH ] || mkdir $LOGPATH
RESULTFILE="$LOGPATH/$IPADDR-`date +%Y%m%d`.txt"

function check(){

	Check_environment ;
	Install_Docker ;
	Docker_Warehouse $Warehouse_passwd;

}

#执行检查并保存检查结果
check > $RESULTFILE
echo "检查结果：$RESULTFILE"







