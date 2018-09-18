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
mongodb_port=27017
# mongodb name
mongodb_name='mongodb'${mongodb_port}
# install dir
install_dir="/data/apps/${mongodb_name}"
# set var
mongodb_service_file="/usr/lib/systemd/system/${mongodb_name}.service"
# mongodb version
mongodb_version='4.0.0'
# mongodb tar file
mongodb_tar_file="mongodb-linux-x86_64-rhel70-${mongodb_version}.tgz"
# mongodb file name
mongodb_file_name="mongodb-linux-x86_64-rhel70-${mongodb_version}"


# exec help
[[ "x${1}" == "xhelp" || "x${1}" == "xh" || "x${1}" == "x--help" || "x${1}" == "x-h" ]] && usage_install && usage_del && exit 0


function print_mess() {
	echo -e "${CMSG}
===============================================================================================

	安装单点mongodb

	系统为：Centos 7

===============================================================================================
${CEND}"
}


function usage_install() {
	echo -e "${CMSG}

本脚本提供一些安装mongodb的常用操作：
	安装mongodb，如果不指定，则为默认端口为${CSUCCESS}27017${CEND}，默认版本为${CSUCCESS}4.0.0${CEND}

	指定端口的方法：
		${CSUCCESS}port${CEND}
		例如端口为${CSUCCESS}27018${CEND}，安装命令为：
			${CSUCCESS}脚本 27018${CEND}
	指定版本的方法：
		${CSUCCESS}version${CEND}
		例如版本为${CSUCCESS}3.0.6${CEND}，安装命令为：
			${CSUCCESS}脚本 3.0.6${CEND}
		version的查看方法，参考：
			https://www.mongodb.org/dl/linux/x86_64-rhel70?_ga=2.244393990.2045580309.1537169934-1971499088.1532748543
	指定端口和版本的方法：
		${CSUCCESS}port version${CEND}
		端口为27018，版本为${CSUCCESS}3.0.6${CEND}，安装命令为：
			${CSUCCESS}脚本 27018 3.0.6${CEND}

	del：删除测试数据
		具体的用法为：${CSUCCESS}del port${CEND}，删除指定端口的mongodb数据
		假设要删除端口为27018的mongodb，具体的命令为：
			${CSUCCESS}脚本 del 27018 ${CEND}

${CEND}"
}


function usage_del() {
	echo -e "${CMSG}

	del：删除测试数据
		具体的用法为：${CSUCCESS}del port${CEND}，删除指定端口的mongodb数据
		假设要删除端口为27018的mongodb，具体的命令为：
			${CSUCCESS}脚本 del 27018 ${CEND}

${CEND}"
}


function usage_after_installed() {
	echo -e "${CMSG}
===============================================================================================

	mongodb已经安装成功！

	version：${CSUCCESS}${mongodb_version}${CEND}

	安装位置为：${install_dir}${CEND}

	mongodb的启动文件的位置：${CSUCCESS}${install_dir}/${mongodb_file_name}/bin${CEND}

	已经将${install_dir}/${mongodb_file_name}/bin/mongo
	拷贝到/usr/bin/
	可以在命令行，直接输入：
		${CSUCCESS}mongo 127.0.0.1:${mongodb_port}${CMSG}
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
	systemctl stop ${mongodb_name}
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


function init_params() {
	# set var
	mongodb_port=${1}
	# mongodb name
	mongodb_name='mongodb'${mongodb_port}
	# install dir
	install_dir="/data/apps/${mongodb_name}"
	# set var
	mongodb_service_file="/usr/lib/systemd/system/${mongodb_name}.service"
}


function init_version() {
	# mongodb version
	mongodb_version=$1
	# mongodb tar file
	mongodb_tar_file="mongodb-linux-x86_64-rhel70-${mongodb_version}.tgz"
	# mongodb file name
	mongodb_file_name="mongodb-linux-x86_64-rhel70-${mongodb_version}"
}


function init_env_for_mongodb() {
	# 检查端口是否存在
	netstat -tunlp | grep ${mongodb_port} && echo "${CFAILURE}port ${mongodb_port} is already exist${CEND}" && exit 1

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
	[[ -f "${mongodb_service_file}" ]] && echo -e "${CFAILURE}${mongodb_service_file} is already exist${CEND}" && exit 1

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
  port: ${mongodb_port}
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
	usage_after_installed
}


# 执行脚本
function execShell() {
	if [[ -z $1 ]]; then
		init_env_for_mongodb && check_soft && install_mongodb
	else
		# 执行命令
		case $1 in
			# 判断是否为数字，参考：
			#	1.http://xiaohuafyle.iteye.com/blog/1812437
			[1-9][0-9]*)
				if [[ -n $2 ]]; then
					init_version $2
				fi
				init_params $1 && init_env_for_mongodb && check_soft && install_mongodb
				;;
			[1-9].[0-9].[0-9])
				init_version $1 && init_env_for_mongodb && check_soft && install_mongodb
				;;
			del)
				if [[ -z $2 ]]; then
					usage_del && exit 1
				else
					init_params $2 && delete_test_mongodb
				fi
				;;
			*)
				usage_install && usage_del && exit 0
				;;
		esac
	fi
}

execShell $*