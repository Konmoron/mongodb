#!/usr/bin/env bash
#
# install mongodb
# 
# ATUHOR: IMER
# CREATED AT: 2018.8.1
# MODIFED AT: 2018.8.3


# define output color
# set echo
echo=echo
for cmd in echo /bin/echo; do
  $cmd >/dev/null 2>&1 || continue
  if ! $cmd -e "" | grep -qE '^-e'; then
    echo=$cmd
    break
  fi
done
# set color
CSI=$($echo -e "\033[")
CEND="${CSI}0m"
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CQUESTION="$CMAGENTA"
CWARNING="$CYELLOW"
CMSG="$CCYAN"
CIP="$CWARNING"


# set var
# mongodb name
mongodb_name='mongodb'
# install dir
install_dir="/data/apps/${mongodb_name}"
# mongodb tar file
mongodb_tar_file='mongodb-linux-x86_64-rhel70-4.0.0.tgz'
# mongodb file name
mongodb_file_name='mongodb-linux-x86_64-rhel70-4.0.0'
# set var
mongodb_service_file="/usr/lib/systemd/system/${mongodb_name}.service"


function print_mess() {
	echo -e "${CMSG}
===============================================================================================

	安装单点mongodb 4.0

	系统为：Centos 7

===============================================================================================
${CEND}"
}


function usage() {
	echo -e "${CMSG}
===============================================================================================

	mongodb已经安装成功！

	安装位置为：${install_dir}

	mongodb的启动文件的位置：${install_dir}/${mongodb_file_name}/bin

	已经将${install_dir}/${mongodb_file_name}/bin/mongo
	拷贝到/usr/bin/
	可以在命令行，直接输入：
		${CSUCCESS}mongo 127.0.0.1:27017${CMSG}
	连接mongodb

	安装完毕之后还需要进行其他的操作，参考：
		初始化mongodb：
			${CSUCCESS}https://github.com/Konmoron/mongodb/blob/master/articles/mongodb%E5%88%9D%E5%A7%8B%E5%8C%96.md${CMSG}
		mongodb常用命令：
			${CSUCCESS}https://github.com/Konmoron/mongodb/blob/master/articles/mongodb%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4.md${CMSG}

===============================================================================================
${CEND}"
}


function delete_test_mongodb() {
	systemctl stop mongodb
	rm ${install_dir} ${mongodb_service_file} /usr/bin/mongo -rf
}


# check soft
function check_soft() {
	# define var
	# soft arr
	# shell的使用空格分开，例如：arr=(a b c)
	soft_arr=(wget)

	# check soft arr
	for base_soft in ${soft_arr[@]}; do
		# serach base soft
		# if base soft installed,$?=0
		# if bash soft not installed,$?=1
		rpm -qa | grep ${base_soft}

		# 判断是否需要安装base soft
		if [[ $? -eq 1 ]]; then
			# install base soft
			yum install -y ${base_soft}
		fi
	done
}


function init_env_for_mongodb() {
	# create mongodb home
	[[ -d "${install_dir}" ]] && echo "${CFAILURE}${install_dir} is already exist${CEND}" && exit 1

	# create data dir
	mkdir -p ${install_dir}/data/{db,log}

	# create log file
	touch ${install_dir}/data/log/mongodb.log
}


function create_mongodb_service() {
	# 判断mongodb_service_file是否存在
	#	如果存在，则退出
	[[ -f "${mongodb_service_file}" ]] && echo -e "${CFAILURE}${mongodb_service_file} is already exist${CEND}" && delete_test_mongodb && exit 1

	# create file
	cat >> ${mongodb_service_file} << EOF
[Unit]
Description=${mongodb_name}
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
ExecStart=${install_dir}/${mongodb_file_name}/bin/mongod --config ${install_dir}/${mongodb_file_name}/conf/mongodb.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=${install_dir}/${mongodb_file_name}/bin/mongod --shutdown --config ${install_dir}/${mongodb_file_name}/conf/mongodb.conf
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

	# daemon reload
	systemctl daemon-reload
}


function create_mongodb_config() {
	# mkdir conf
	mkdir ${install_dir}/${mongodb_file_name}/conf

	# create conf
	cat >> ${install_dir}/${mongodb_file_name}/conf/mongodb.conf << EOF
systemLog:
  destination: file
  path: "${install_dir}/data/log/mongod.log"
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: "${install_dir}/data/db"
  mmapv1:
    smallFiles: true
processManagement:
  fork: true
net:
  bindIp: 0.0.0.0
  port: 27017
EOF
}


function install_mongodb() {
	# print message
	print_mess

	# download mongodb
	wget https://fastdl.mongodb.org/linux/${mongodb_tar_file}

	# tar mongodb file
	tar -xzvf ${mongodb_tar_file} -C ${install_dir}/

	# create mongodb conf
	create_mongodb_config

	# create mongodb service
	create_mongodb_service

	# start mongodb
	systemctl start ${mongodb_name}

	# enable mongodb
	systemctl enable ${mongodb_name}

	# status mongodb
	systemctl status ${mongodb_name}

	# cp mongo to /usr/bin
	/usr/bin/cp -f ${install_dir}/${mongodb_file_name}/bin/mongo /usr/bin/

	# delete mongodb tar file
	rm ${mongodb_tar_file} -f

	# print mess
	usage
}



init_env_for_mongodb && check_soft && install_mongodb

# delete_test_mongodb