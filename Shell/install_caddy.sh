#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}本脚本必须以 root 身份运行，请切换到 root 用户后再执行本脚本!${plain}"
  exit 1
fi

install_caddy() {
    # 更新并安装必要的软件包
    apt update
    apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

    # 添加 Caddy 的 GPG 密钥
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

    # 添加 Caddy 的软件源
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list

    # 更新软件包列表
    apt update

    # 安装 Caddy
    apt install -y caddy

    # 添加 Caddy 的扩展包
    caddy add-package github.com/caddyserver/replace-response

    echo -e "${GREEN}Caddy 安装完成并添加了扩展包${plain}"
}

edit_config() {
    # 修改配置文件
    vi /etc/caddy/Caddyfile
    echo -e "${GREEN}配置文件修改完成${plain}"
}

reload_caddy() {
    # 重启 Caddy
    systemctl reload caddy
    echo -e "${GREEN}Caddy 已重启${plain}"
}

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
plain='\033[0m' # 无颜色

echo -e "
${GREEN}###########################################################${plain}
${GREEN}#                                                         #${plain}
${GREEN}#                 Caddy 一键安装脚本                      #${plain}
${GREEN}#                                                         #${plain}
${GREEN}###########################################################${plain}"

main() {
    echo -e "\n${RED}0. 退出脚本${plain}\n${YELLOW}1. 安装 Caddy\n2. 修改配置文件\n3. 重启 Caddy\n${plain}"
    # shellcheck disable=SC2162
    read -p "请输入数字：" num

    case "$num" in
        0)
            exit 0
            ;;
        1)
            install_caddy
            ;;
        2)
            edit_config
            # shellcheck disable=SC2162
            read -p "是否要重启 Caddy (Y/N): " tag
            if [[ "$tag" == "Y" || "$tag" == "y" ]]; then
                reload_caddy
            fi
            main
            ;;
        3)
            reload_caddy
            ;;
        *)
            echo -e "${RED}请输入正确数字 [0-3]${plain}"
            sleep 1s
            main
            ;;
    esac
}
main