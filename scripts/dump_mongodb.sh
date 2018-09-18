#!/usr/bin/env bash
#
# backup mongodb
#
# 保留30天的备份记录
# 
# ATUHOR: IMER
# CREATED AT: 2018.9.17
# MODIFED AT: 2018.9.17


# mongodb name
mongodb_name='mongodb'
# install dir
install_dir="/data/apps/${mongodb_name}"
# backup dir
backup_dir="/data/apps/${mongodb_name}/backup"
# date
back_date=$(date "+%Y-%m-%d")

# 如果文件夹不存在，就创建
[[ ! -d ${backup_dir} ]] && mkdir -p ${backup_dir}

# 备份所有的数据库
/data/apps/mongodb/mongodb-linux-x86_64-rhel70-3.0.6/bin/mongodump -u admin -p feemockplatform -o ${backup_dir}/${mongodb_name}-${back_date}

# 删除30天之前的备份
find ${backup_dir} -type d -name "${mongodb_name}" -mtime +30 -exec rm -rf {} \;