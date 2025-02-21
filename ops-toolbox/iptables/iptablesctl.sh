#!/usr/bin/env bash
# Description: iptables规则管理脚本
# Author: .Rody
# Date: 2025-01-10 16:50:18

IPTABLES_CONFDIR="/etc/iptables"
IPTABLES_CONFIG_FILE="/etc/sysconfig/iptables"

# Chains INPUT
iptables_chain_input() {
    iptables -F INPUT
    iptables -P INPUT DROP
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp -s 192.168.56.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "SSH"
    iptables -A INPUT -p tcp -s 27.151.72.34/32 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "SSH"
    #iptables -A INPUT -j LOG --log-prefix "iptables denied: " --log-level 4
}

# Chain FORWARD
# Chain OUTPUT
iptables_chain_output() {
    iptables -F OUTPUT
    iptables -P OUTPUT DROP
    iptables -A OUTPUT -j ACCEPT
}

# Chains ALL
iptables_chain() {
    iptables_chain_input
    iptables_chain_output
    if [ ! -d "${IPTABLES_CONFDIR}" ];then
        mkdir -p ${IPTABLES_CONFDIR}
    fi
    iptables-save > ${IPTABLES_CONFDIR}/rules.v4
    ip6tables-save > ${IPTABLES_CONFDIR}/rules.v6
    iptables -nvL
}

iptables_chain