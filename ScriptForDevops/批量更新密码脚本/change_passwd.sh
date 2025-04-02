#!/bin/bash

read -p '请输入服务器密码：' pass
read -p '请输入服务器新密码: ' newpass
read -p '请再次输入服务器新密码: ' renewpass
read -p '请输入root新密码: ' newrootpass
read -p '请再次root新密码: ' renewrootpass

set -e

if [[ $newpass = pass ]]; then
	echo "新密码不能与旧密码一致，请输入新密码"
	exit 0;
fi

if [ $newpass = $renewpass -a $newrootpass = $renewrootpass ];then
	for ip in  192.168.0.{177}
	do

	{
		expect ./change_pass.exp $ip $pass $newpass $newrootpass
		echo "$ip lmode新密码：$newpass" root新密码：$newrootpass >> /home/lmode/updatepass/newpassword.txt
	}

	done
else

echo"输入的新密码 或者root新密码不一致"
fi
