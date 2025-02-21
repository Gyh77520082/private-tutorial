#!/usr/bin/env bash
# Datetime: 2023-07-19
# Author: .Rody
# Description: MySQL Instance bin log backup.
# Note: For MySQL 8.0

BACKUP_TYPE="db"

# 备份目标
CURRENT_IP="10.0.2.248"
MYSQL_HOST="localhost"
MYSQL_USER="backup"
MYSQL_PASSWD="vn7xJc5LnG3@2JzX"
MYSQL_DATA_BASE_DIR="/data/mysql"
MYSQL_LOGS_DIR="${MYSQL_DATA_BASE_DIR}/logs"
MYSQL_BINLOG_INDEX="${MYSQL_LOGS_DIR}/mysql-bin.index"

# 远程服务器
REMOTE_IP="10.0.2.234"
REMOTE_PORT=22
REMOTE_USER="lmode"
REMOTE_PASSWD="rztUTwZ!@LTUG6CZ"
REMOTE_DIR="/data/backups/remote/${BACKUP_TYPE}_${CURRENT_IP}"
REMOTE_BINLOG_DIR="${REMOTE_DIR}/binlog"

# 备份路径信息
BACKUP_BASE_DIR="/data/backups/mysql/binlog"
CURRENT_BACKUP_DATE="$(date +%Y-%m-%d)"
CURRENT_BACKUP_DATETIME="$(date +%Y-%m-%d_%H-%M-%S)"
CURRENT_BACKUP_TIMESTAMP="$(date +%s)"
CURRENT_BACKUP_DIR="${BACKUP_BASE_DIR}"
CURRENT_BACKUP_LOG="${CURRENT_BACKUP_DIR}/binlog_sync_${CURRENT_BACKUP_DATE}.log"
BINLOG_SYNC_INDEX="${BACKUP_BASE_DIR}/binlog.sync"
KEEP_DAYS=3

init_binlog_backup() {
    mkdir -p ${BACKUP_BASE_DIR}
    MYSQL_BINLOG_LIST=$(cat ${MYSQL_BINLOG_INDEX})

    # 查找本次备份起始binlog，末尾binlog
    if [ -f "${BINLOG_SYNC_INDEX}" ];then
        FIRST_BINLOG="$(cat ${BINLOG_SYNC_INDEX})"
    else
        FIRST_BINLOG="$(basename $(head -1 ${MYSQL_BINLOG_INDEX}))"
    fi
    LAST_BINLOG="$(basename $(tail -1 ${MYSQL_BINLOG_INDEX}))"

    # 验证起始binlog是否可用
    num=$(grep -wc "${FIRST_BINLOG}" "${MYSQL_BINLOG_INDEX}")
    if [ ${num} -eq 1 ];then
        echo "Find ${FIRST_BINLOG} From ${MYSQL_BINLOG_INDEX}." >> ${CURRENT_BACKUP_LOG}
    else
        echo "Unable to find ${FIRST_BINLOG} from ${MYSQL_BINLOG_INDEX}." >> ${CURRENT_BACKUP_LOG}
        exit 1
    fi

    # 从起始binlog取出待同步binlog列表
    BINLOG_SYNC_LIST=$(sed -n "/${FIRST_BINLOG}/,\$p" ${MYSQL_BINLOG_INDEX})
}

local_binlog_backup() {
    echo "Binlog local backup start. $(date '+%Y-%m-%d %H:%M:%S')" >> ${CURRENT_BACKUP_LOG}
    for BINLOG in ${BINLOG_SYNC_LIST[@]}
    do
        CURRENT_SYNC_BINLOG="$(basename $(echo "${BINLOG}"))"
        # 本地备份
        mkdir -p ${BACKUP_BASE_DIR}
        echo "copy ${CURRENT_SYNC_BINLOG}." >> ${CURRENT_BACKUP_LOG}
        if [ "${CURRENT_SYNC_BINLOG}" != "${LAST_BINLOG}" ];then
            cp -a ${MYSQL_LOGS_DIR}/${CURRENT_SYNC_BINLOG} ${BACKUP_BASE_DIR}
        else
            echo "Binlog local no copy. $(date '+%Y-%m-%d %H:%M:%S')" >> ${CURRENT_BACKUP_LOG}
        fi
    done
    echo "Binlog local backup end. $(date '+%Y-%m-%d %H:%M:%S')" >> ${CURRENT_BACKUP_LOG}

    # 记录当前binlog备份列表的最后一个文件
    echo ${LAST_BINLOG} > ${BINLOG_SYNC_INDEX}
}

remote_binlog_backup() {
    # 远程备份
    echo "Binlog remote backup start. $(date '+%Y-%m-%d %H:%M:%S')" >> ${CURRENT_BACKUP_LOG}
    SSHPASS=$(which sshpass)
    ${SSHPASS} -p${REMOTE_PASSWD} ssh -o StrictHostKeyChecking=no -p${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_IP} "mkdir -p ${REMOTE_BINLOG_DIR}"
    ${SSHPASS} -p${REMOTE_PASSWD} rsync -avu -e "ssh -o StrictHostKeyChecking=no -p${REMOTE_PORT}" ${CURRENT_BACKUP_DIR}/mysql-bin.* ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_BINLOG_DIR} >> ${CURRENT_BACKUP_LOG} 2>&1
    if [ $? -eq 0 ];then
        echo "Binlog rsync successful." >> ${CURRENT_BACKUP_LOG}
    else
        echo "Binlog rsync fail." >> ${CURRENT_BACKUP_LOG}
        exit 1
    fi
    echo "Binlog remote backup end. $(date '+%Y-%m-%d %H:%M:%S')" >> ${CURRENT_BACKUP_LOG}
}

clean_binlog_backup() {
    # 清理备份的历史binlog
    find ${BACKUP_BASE_DIR} -mindepth 1 -name "mysql-bin.*" -type f -mtime +${KEEP_DAYS} | xargs rm -f
    # 清理备份日志
    find ${BACKUP_BASE_DIR} -mindepth 1 -name "*.log" -type f -mtime +${KEEP_DAYS} | xargs rm -f
}

init_binlog_backup
local_binlog_backup
remote_binlog_backup
clean_binlog_backup
