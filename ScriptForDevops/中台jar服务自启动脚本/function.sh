#!/bin/bash

DATE=$(date +%m%d)

# 排查服务和端口是否正常

function CheckMiddlewareServices {  
    local serviceName=$1  
    local port=$2  
    local host=$3  
      
    if nc -z $host $port &>/dev/null; then  
        echo "$serviceName 运行正常"
    else
        echo "$serviceName 暂未启动请排查应用 时间：$DATE" >> ./error.log
        exit 1 
    fi
    
}  

# 排查服务是否启动
function CheckJavaServices {
    local serviceName=$1
    local workspace=$2


    PID=$(pgrep -f $serviceName)
    # 检查服务是否正在运行  
    if [ -z "$PID" ]; then  
        cd $workspace
        echo "服务 $serviceName 未运行，尝试启动..."  >> ./CheckJavaServices_error.log
        sh startup.sh
    fi
}