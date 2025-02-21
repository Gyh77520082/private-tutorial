#!/bin/bash


eval "source ~/.bash_profile && source /etc/profile" >/dev/null 2>&1
export LANG=en_US.utf8

find ./ -type f | xargs sed -i 's/\r//'  >> /dev/null 2>&1

file_start=$(basename $0)
cd $(dirname $0)
curdir=$(pwd)

readonly VERSION_REGEX="[0-9]+\.[0-9]+\.[0-9]{4}[0-1][0-9][0-3][0-9]"
version_file_path="${curdir}/.version"

date=$(date +%Y%m%d)

if [ ! -d "${curdir}/xunjian-result/${date}" ];then
  mkdir ${curdir}/xunjian-result/"${date}"
fi

# 防止重复执行此脚本
pid_start_parent_list_str=$(ps -ef|grep "${file_start}"|grep -v grep| awk '{print $3}')
pid_start_list_str=$(ps -ef|grep "${file_start}"|grep -v grep| awk '{print $2}')
pid_start_parent_list=(${pid_start_parent_list_str//" "/ })
pid_start_list=(${pid_start_list_str//" "/ })
count_start=0
for ((i=0; i<${#pid_start_list[@]}; i++))
do
    pid_start=${pid_start_list[i]}
    pid_start_parent=${pid_start_parent_list[i]}
    count_check_parent=0
    for pid_start_check in ${pid_start_list[@]}
    do
        if [[ ${pid_start_parent} == ${pid_start_check} ]]; then
            count_check_parent=$((${count_check_parent}+1))
            break
        fi
    done
    if [[ ${count_check_parent} -gt 0 ]]; then
        continue
    fi
    dir_pid_start=$(pwdx ${pid_start}|sed "s@.*: @@")
    if [[ ${dir_pid_start} == ${curdir} ]]; then
        count_start=$((${count_start}+1))
    fi
done
if [[ ${count_start} -gt 1 ]]; then
    echo "当前已有人正在${curdir}目录下执行start.sh，由于无法支持多人（或多窗口）使用，本次执行已自动退出，敬请谅解~
若着急使用，可以互相沟通协调下 (^_^)"
    exit 0
fi

function _execplaybook() {
    extra_vars=""
    if [[ $# > 1 ]]; then
        extra_vars="-e $2"
    fi
    ansible-playbook playbook.yml -t $1 ${extra_vars}
}

function _fetch_version() {
    local version_check=$(grep -E "${VERSION_REGEX}" ${version_file_path})
    if [[ -z ${version_check} ]]; then
        return
    fi
    version="${version_check}"
}

function _install_ansible() {
    local exist_check=$(ansible --version 2>/dev/null)
    local system_version=$(grep -o "[0-9]" /etc/system-release|head -n 1 |grep -o "[0-9]")
    if [[ -z ${exist_check} ]]; then
        case "${system_version}" in
        7)
            yum install -y epel-release
            yum install ansible -y
            echo "完成安装，版本为:$(ansible --version|head -n 1)"
            ;;
        esac
    else
        echo ""
        echo "服务器已安装anisble，无需安装，版本为:$(ansible --version|head -n 1)"
    fi

}

function _display_menu_multi_host_inspection() {
    echo -e "
\033[1m> 开始菜单 > 多主机巡检\033[0m

请选择:
    a) # 安装ansible (仅支持centos7)
    h) # 编辑主机 inventory
    p) # 测试连接 (利用ansible的ping模块，会检测主机连接信息配置的准确性)
    s) # 开始巡检（完成上述操作，即可开始巡检）
    q) # 返回"
}

function _multi_host_inspection() {
    while true; do
        _display_menu_multi_host_inspection
        read -p "执行项: " arg
        local arg_digit_match=$(grep "^[[:digit:]]*$" <<< $(echo "${arg}"))
        case ${arg} in
            a) # 安装ansible (仅支持centos7)
                while true; do
                    read -p "该服务器系统版本为:$(cat /etc/system-release)是否需要安装ansible (yes/no) " is_check
                    if [[ "${is_check}" == "yes" ]]; then
                        is_exec="true"
                        break
                    elif [[ "${is_check}" == "no" ]]; then
                        is_exec="false"
                        break
                    else
                        continue
                    fi
                done
                if [[ "${is_exec}" == "true" ]]; then
                     _install_ansible
                fi
                ;;
            h) # 编辑主机 inventory
                vi inventory
                ;;
            p) # 测试连接 (利用ansible的ping模块，会检测主机连接信息配置的准确性)
                while true; do
                    read -p "是否需要kill掉所有的ansible进程以保障检测结果的准确性(若此时有未跑完的ansible进程，建议互相沟通清楚后再决定) (yes/no) " is_check
                    if [[ "${is_check}" == "yes" ]]; then
                        local pid_ansible=$(pgrep -f ansible)
                        if [[ ! -z ${pid_ansible} ]]; then
                            pgrep -f ansible | xargs kill
                        fi
                        _execplaybook "ping"
                        break
                    elif [[ "${is_check}" == "no" ]]; then
                        _execplaybook "ping"
                        break
                    else
                        continue
                    fi
                done
                ;;
            s) # 开始巡检（完成上述三项操作，即可开始巡检）
                while true; do
                    is_exec=""
                    read -p "是否继续 (yes/no) " is_check
                    if [[ "${is_check}" == "yes" ]]; then
                        is_exec="true"
                        break
                    elif [[ "${is_check}" == "no" ]]; then
                        is_exec="false"
                        break
                    else
                        continue
                    fi
                done
                if [[ "${is_exec}" == "true" ]]; then
                    _execplaybook "xunjian"
                    new_file=$(ls -t ${curdir}/xunjian-result/${date}/|grep 'md'|head -n 1)
                    echo "巡检结果：${curdir}/xunjian-result/${date}/${new_file}"
                fi
                ;;
            q) # 退出
                return
                ;;

        esac
    done
}


function _display_menu_entry() {
    echo -e "
\033[1;34m版本号:\033[0m"
    if [[ -z ${version} ]]; then
        echo -e "    \033[1;31m无法确定版本号！\033[0m"
    else
        echo -e "    \033[1;33m${version}\033[0m"
    fi
    echo -e "
\033[1m> 开始菜单 \033[0m

请选择:
    1) # 本机巡检
    2) # 多主机巡检
    3) # 整合巡检结果
    q) # 退出
"
}


function _entry() {
    while true; do
        _display_menu_entry
        read -p "执行项: " arg
        case ${arg} in
            1) # 本机巡检
                while true; do
                    is_exec=""
                    read -p "是否继续 (yes/no) " is_check
                    if [[ "${is_check}" == "yes" ]]; then
                        is_exec="true"
                        break
                    elif [[ "${is_check}" == "no" ]]; then
                        is_exec="false"
                        break
                    else
                        continue
                    fi
                done
                if [[ "${is_exec}" == "true" ]]; then
                    sh ${curdir}/roles/xunjian/templates/scripts/main.sh
                    mv -f ${curdir}/roles/xunjian/templates/scripts/log/* ${curdir}/xunjian-result/${date}/
                    new_file=$(ls -t ${curdir}/xunjian-result/${date}/|grep 'md'|head -n 1)
                    echo "巡检结果：${curdir}/xunjian-result/${date}/${new_file}"
                fi
                ;;
            2) # 多主机巡检
                _multi_host_inspection
                ;;
            3) # 整合巡检文档
                echo "" > ${curdir}/xunjian-result/`date +%Y%m%d`.md
                ls ${curdir}/xunjian-result/${date}/*|grep "${date}.md"|xargs cat >> ${curdir}/xunjian-result/`date +%Y%m%d`.md
                sed -i '/<details open>/s/.*/<details>/' ${curdir}/xunjian-result/`date +%Y%m%d`.md
                new_file=$(ls -t ${curdir}/xunjian-result/|grep 'md'|head -n 1)
                echo "整合的巡检结果：${curdir}/xunjian-result/${new_file}"
                ;;
            q) # 退出
                exit 0
                ;;
            *) # 其他
                continue
                ;;
        esac
    done
}

function _main() {
    _fetch_version
    _entry

}

_main
