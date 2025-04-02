#!/bin/bash

source ./function.sh



workDir="/home/lmode/microservices"
prefix="fs-smp-"
servers=('admin' 'api' 'auth' 'basicdata' 'front' 'ops')
# 检测中间件是否启动成功

# 检查Nacos  
CheckMiddlewareServices "Nacos" 8848 192.168.0.233

# 检查RabbitMQ  
CheckMiddlewareServices "RabbitMQ" 15672 192.168.0.233

# 检查Redis  
CheckMiddlewareServices "Redis" 6379 192.168.0.233


# 使用for循环遍历数组中的每个服务器名称  
for server in "${servers[@]}"; do
    # 检查服务器名称是否包含'bpmn'  
    if [[ $server == "erp" ]]; then

        workspace=$workDir/$server
        server="fs-erp-ms"
        CheckJavaServices $server $workspace

    else
        serverName=$prefix$server
        workspace=$workDir/$server
        CheckJavaServices $serverName $workspace
    fi

done

