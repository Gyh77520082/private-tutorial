#!/bin/bash
#
file_start=$(basename $0)
cd $(dirname $0)
curdir=$(pwd)

source ${curdir}/function.sh
#环境变量PATH没设好，在cron里执行时有很多命令会找不到
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

#判断权限防止权限不够需要使用root执行该脚本
[ $(id -u) -gt 0 ] && echo "请用root用户执行此脚本！" && exit 1

##巡检脚本版本号
#VERSION=""

#查看当前centos系统版本
centosVersion=$(awk '{print $(NF-1)}' /etc/redhat-release)
#IP地址
#获取当前服务器的IP地址
NIC_Name=`ls /etc/sysconfig/network-scripts | grep ifcfg | grep -v 'lo' | awk -F '-' '{print $2}'`
IPADDR=`ifconfig $NIC_Name | grep inet | grep -v inet6 | awk '{print $2}'`

#日志路径
LOGPATH="${curdir}/log"
[ -e $LOGPATH ] || mkdir $LOGPATH
RESULTFILE="$LOGPATH/$IPADDR-`date +%Y%m%d`.md"

function check(){
    version
    getSystemStatus
    getCpuStatus
    getMemStatus
    getDiskStatus
    getNetworkStatus
    getListenStatus
    getProcessStatus
    getServiceStatus
    getAutoStartStatus
    getLoginStatus
    getCronStatus
    getUserStatus
    getPasswordStatus
    getSudoersStatus
    getJDKStatus
    getFirewallStatus
    getSSHStatus
    getSyslogStatus
    getSNMPStatus
    getNTPStatus
    getInstalledStatus
}
#执行检查并保存检查结果
check > $RESULTFILE
echo '</details>' >> $RESULTFILE