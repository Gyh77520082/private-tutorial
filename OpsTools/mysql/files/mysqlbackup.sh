#!/usr/bin/env bash
# Datetime: 2023-07-18
# Author: .Rody
# Description: MySQL Database Backup Script Using mysqldump.
# Note: For MySQL 8.0

BACKUP_TYPE="db"

# 备份目标
CURRENT_IP=""
MYSQL_HOST="localhost"
MYSQL_USER="backup"
MYSQL_PASSWD="vn7xJc5LnG3@2JzX"
MYSQL_DATA_BASE_DIR="/data/mysql"
MYSQL_LOGS_DIR="${MYSQL_DATA_BASE_DIR}/logs"
MYSQL_BINLOG_INDEX="${MYSQL_LOGS_DIR}/mysql-bin.index"

# 远程服务器
REMOTE_IP=""
REMOTE_PORT=22
REMOTE_USER="lmode"
REMOTE_PASSWD=""
REMOTE_DIR="/data/backups/remote/${BACKUP_TYPE}_${CURRENT_IP}"
REMOTE_FULL_DIR="${REMOTE_DIR}/fulldump"

# 备份路径信息
BACKUP_BASE_DIR="/data/backups/mysql/fulldump"
CURRENT_BACKUP_DATE="$(date +%Y-%m-%d)"
CURRENT_BACKUP_DATETIME="$(date +%Y-%m-%d_%H-%M-%S)"
CURRENT_BACKUP_TIMESTAMP="$(date +%s)"
CURRENT_BACKUP_DIR="${BACKUP_BASE_DIR}/${CURRENT_IP}_${CURRENT_BACKUP_DATETIME}"
CURRENT_BACKUP_LOG="${CURRENT_BACKUP_DIR}/full_backup_${CURRENT_BACKUP_DATETIME}.log"
CURRENT_BACKUP_SQL="${CURRENT_BACKUP_DIR}/full_backup_${CURRENT_BACKUP_DATETIME}.sql"
BACKUP_KEEP_DAYS=3

# CLI
MYSQLADMIN_CLI="/usr/local/mysql/bin/mysqladmin -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWD}"
MYSQLDUMP_CLI="/usr/local/mysql/bin/mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWD}"

init_backup() {
    mkdir -p ${CURRENT_BACKUP_DIR}
    #rm -rf ${CURRENT_BACKUP_DIR}/*
    echo "Begin Backup. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
}

run_backup() {
    ${MYSQLDUMP_CLI} --flush-logs --flush-privileges --set-gtid-purged=OFF --single-transaction --source-data=2 \
        -A --triggers --events --routines -f > ${CURRENT_BACKUP_SQL} 2>> ${CURRENT_BACKUP_LOG}
    if [ $? -eq 0 ];then
        echo "Backup Successful. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
    else
        echo "Backup Fail. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
        exit 1
    fi
    gzip -9 ${CURRENT_BACKUP_SQL}
    if [ $? -eq 0 ];then
        echo "Gzip Successful. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
    else
        echo "Gzip Fail. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
        exit 1
    fi
}

transfor_backup() {
    SSHPASS=$(which sshpass)
    echo "Transfor Backup. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
    if [ -n ${SSHPASS} ];then
        # 创建远程备份目录
        ${SSHPASS} -p${REMOTE_PASSWD} ssh -o StrictHostKeyChecking=no -p${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_IP} "mkdir -p ${REMOTE_FULL_DIR}"
        ${SSHPASS} -p${REMOTE_PASSWD} rsync -av -e "ssh -o StrictHostKeyChecking=no -p${REMOTE_PORT}" ${CURRENT_BACKUP_DIR} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_FULL_DIR} >> ${CURRENT_BACKUP_LOG} 2>&1
        if [ $? -eq 0 ];then
            echo "Transfor Backup Successful. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
        else
            echo "Transfor Backup Fail. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
            exit 1
        fi
    else
        echo "sshpass not found. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
        exit 1
    fi
}

clean_backup() {
    # 本地备份保留5天，使用BACKUP_KEEP_DAYS参数控制保留天数
    echo "Clean Backup. ($(date '+%Y-%m-%d %H:%M:%S'))" >> ${CURRENT_BACKUP_LOG}
    find ${BACKUP_BASE_DIR} -mindepth 1 -type d -mtime +${BACKUP_KEEP_DAYS} | xargs rm -rf
}

init_backup
run_backup
#transfor_backup
clean_backup