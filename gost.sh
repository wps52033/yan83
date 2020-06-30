#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#付费维护脚本，请勿破解修改                                                                                                
#===================================================================#
#   System Required:  CentOS 7                                      #
#   Description: Install sspanel for CentOS7                        #
#   Author: Azure <563396148@qq.com>                                #
#===================================================================#
#一键脚本
#version=v1.1
#check root
[ $(id -u) != "0" ] && { echo "错误:请以root用户运行此脚本"; exit 1; }
rm -rf all
rm -rf $0
plain='\033[0m'
#
# 设置字体颜色函数
function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}
install_GOST(){
	if [ -f "/root/gost" ];then
   echo "编译文件已下载"
   else
wget -P /root https://jiaob.oss-cn-beijing.aliyuncs.com/gost
chmod +x gost
    fi
}
##返回菜单
before_show_menu() {
    echo && echo -n -e "${yellow}按回车返回主菜单: ${plain}" && read temp
    start_menu
}
##查询状态
status() {
    systemctl status $cxport.service --no-pager -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}
##卸载节点
uninstall() {
    echo "确定要卸载 $gbport端口中转 吗?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop $gbport.service
    systemctl disable $gbport.service
    rm /etc/systemd/system/$gbport.service -f
    systemctl daemon-reload
    systemctl reset-failed
    echo ""
    echo "卸载成功！$gbport端口已经删除！"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}
config_ZZ(){
	echo -n "落地鸡ip："
	read outip
	echo -n "后端节点端口（用户使用的单端口）："
	read userport
	echo -n "中转后的端口（中转端口）："
	read vpsport
	echo -n "VPS通信端口："
    read outport
    echo "安装GOST"
    install_GOST
    echo "正在生成配置文件"
	if [ -f "/etc/systemd/system/$vpsport.service" ];then
   echo "端口已经被使用请更换"
   else
    cat>/etc/systemd/system/$vpsport.service<<EOF
[Unit]
Description=hktcp$vpsport
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/root/gost -L=tcp://:$vpsport/$outip:$userport -L=udp://:$vpsport/$outip:$userport -F=ws://$outip:$outport
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    fi
	echo "创建开机启动指令..."
	systemctl enable $vpsport.service
	echo "启动端口转发指令..."
	systemctl start $vpsport.service
	echo "输出端口执行状态..."
	systemctl status $vpsport.service
	    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}
config_LD(){
	echo -n "VPS通信端口："
    read outport
    echo "安装GOST"
    install_GOST
    echo "正在生成配置文件"
		if [ -f "/etc/systemd/system/LD.service" ];then
   echo "中转后端已经部署过了....."
   else
    cat>/etc/systemd/system/LD.service<<EOF
[Unit]
Description=hkservice
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/root/gost -L=ws://:$outport
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    fi
	echo "创建开机启动指令..."
	systemctl enable LD.service
	echo "启动端口转发指令..."
	systemctl start LD.service
	echo "输出端口执行状态..."
	systemctl status LD.service
	    if [[ $# == 0 ]]; then
        before_show_menu
    fi

}
start_menu(){
    clear
	echo
    greenbg "==============================================================="
    greenbg "程序：GOST多端口一键中转                                       "
    greenbg "系统：Centos7、Ubuntu、Debian等                                "
    greenbg "脚本作者：ALICK  联系QQ：3074744699                            "
    greenbg "网站： https://www.yunni.shop                                   "
    greenbg "==============================================================="
	greenbg "                   SSBANEW多功能一键脚本                       "
    greenbg "==============================================================="
	greenbg "1.GOST一键中转机配置                   2.GOST一键落地鸡配置    "
	greenbg "3.指定端口转发状态查询                 4.指定端口转发状态重启  "
	greenbg "5.指定端口转发关闭                                             "
    greenbg "==============================================================="
	greenbg "0.退出脚本                                                     "	
    greenbg "==============================================================="		
    echo
	yellow "欢迎使用Alick一键gsot脚本                                 "
    echo
    read -p "请输入数字,退出请按0:" num
    case "$num" in
    1)
    greenbg "此脚本适用于Centos7、Ubutun、Debian等系统"
    config_ZZ
	;;
    2)
    greenbg "此脚本适用于Centos7、Ubutun、Debian等系统"
    config_LD
	;;
	3)
	echo -n "请输入需要查询的转发端口号："
    read cxport
	status
	;;
	4)
	echo -n "请输入需要重启的转发端口号："
    read cqport
	systemctl restart $cqport.service
	;;
	5)
	echo -n "请输入需要关闭的转发端口号："
    read gbport
	uninstall
	;;
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字,退出请按0："
	sleep 3s
	start_menu
	;;
    esac
}

start_menu