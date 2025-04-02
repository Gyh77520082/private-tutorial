#!/bin/bash
DATE=$(date +%m%d)

IFS=$','                     #以换行为分隔符取变量

sed -i 's/\r//' server.conf
while read line;do
	eval "$line"
done < server.conf

#备份
function bak_server(){

    cd $path
    rm -rf bak/
    mkdir bak && cp $jarname bak/$jarname$DATE
    echo "-------"$server"备份成功-------------"

}

#升级
function update_server(){

	#移动至当前项目路径并删除旧的操作空间
   	cd $path && rm -rf code/
    #创建操作空间
    mkdir code/ && mv  $jarname code/
    #移动解压jar包
    cd code/ && jar -xvf $jarname
    for pro in $projects
	do
		project=$pro"*.jar"
		#删除旧版本并将新版本移入lib
    	rm -f BOOT-INF/lib/$project && cp $uppath$project BOOT-INF/lib/
	done
	#重新压缩
    jar -cfM0 $jarname ./ && mv $jarname ../
    ps -ef|grep $jarname |grep -v 'grep'| cut -c 9-15 | xargs kill -s 9
    cd $path && sh $starts
   
    echo "-------"$server"升级成功-------------"

}

#回退
function callback_server(){

	cd $path && rm -f $jarname

	cp bak/$jarname$DATE ./$jarname

	cd $path && sh $starts

    echo "-------"$server"回退并启动成功-------------"
}


echo "B:备份(bak)"
echo "U:升级(update)"
echo "C:回退(callback)"
echo "Q:退出(quit)"
read -p "请选择操作"： Options
case $Options in
    B|b)
        for server in $servers
        do
            path=$paths$server
            jarname=$jarprefix$server'.jar'
            bak_server
        done
        ;;
    U|u)
        for server in $servers
        do
            path=$paths$server
            jarname=$jarprefix$server'.jar'
            update_server
        done
        ;;
    C|c)
        for server in $servers
        do
            path=$paths$server
            jarname=$jarprefix$server'.jar'
            callback_server
        done
        ;;
    Q|q)
        exit 0
esac 