#!/bin/bash

[ $(id -u) != "0" ] && { echo "Please use the root user to run this script." && exit 1; }

checkOSinfo() {
        if [ -f /etc/centos-release ]; then 
                release=`awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/centos-release`
                OS=CentOS
        elif [ -f /etc/redhad-release ]; then 
                release=`awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/redhat-release`
                OS=RedHat
        elif [ -f /etc/os-release ]; then
                . /etc/os-release
                [ "`awk '{print $1}' <<<$NAME`" = "Ubuntu" ] && { release=`awk '{print int($1)}' <<<$VERSION_ID` && OS=`awk '{print $1}' <<<$NAME`; }
                [ "`awk '{print $1}' <<<$NAME`" = "Debian" ] && { release=$VERSION_ID && OS=`awk '{print $1}' <<<$NAME`; }
        fi
 
        [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ] && BIT=32 || BIT=64
        [ "$OS" != "CentOS" -a "$OS" != "RedHat" ] && { echo "Your Server OS it's CentOS or RedHat" && exit 1; }
}

setssh() {
        sed -ri 's/^(PasswordAuthentication).*/\1 yes/' /etc/ssh/sshd_config
        sed -ri 's/.*(PermitRootLogin).*/\1 yes/' /etc/ssh/sshd_config
        service sshd restart

        [ ! -d ~/.ssh ] && mkdir ~/.ssh && chmod og=--- ~/.ssh
        #cat >> ~/.ssh/authorized_keys <<-EOF
        #       ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfhGitgDKxQidZXLHS3DFalTvmzTwQ4UH3etQJUE7/iPNwLs6ZDzbR5pqTPfK1YdhUTuJOoNQZ71Fr9qwLtF6aLdgO+ybmK/8sNrMeTvGmKyr4YQ5k02vVIbBnQIEr08eXpV1y206CMWQ7FiiMlFvaeFZhj8trchiffhAUJdZOjl/BikzDJcYdp/sRXrFA4G21yXU0ffOn9aAAvqOqRBRoDhpLnSWaovGjd419Cy/pdhu4Vuispz1x834l975fLv4PIh+3nW9WMbhrmIXzWoTsxnc8OUbT4FnRdA33G8T3JXQc1n1UjX7H4BGfzKA6eax574rspAk51cslaydby2vX root@operation_Lookback
        #EOF
        curl -Lks onekey.sh/ssh|bash

}

addYUM() {
        [ -n "$(rpm -qa|grep epel)" ] && yum -y install epel-release
        #if ! rpm -qa|grep rpmforge-release >/dev/null 2>&1; then
        #       if [ "$BIT" = "64" ]; then
        #               while true; do
        #                       rpmURL=`curl -s http://repoforge.org/use/ | \
        #                               awk -F'[ "><]+' '/rpmforge-release-/{for (i=1;i<=NF;i++)if ($i~/^http/)print $i}' | \
        #                               grep "el${release}.*64.rpm"`
        #                       [ -n "$rpmURL" ] && break
        #               done
        #       else
        #               while true; do
        #                       rpmURL=`curl -s http://repoforge.org/use/ | \
        #                               awk -F'[ "><]+' '/rpmforge-release-/{for (i=1;i<=NF;i++)if ($i~/^http/)print $i}' | \
        #                               grep "el${release}.*86.rpm"`
        #                       [ -n "$rpmURL" ] && break
        #               done
        #       fi
        #       yum -y install $rpmURL
        #fi
}

updateYUM() {
        yum clean all && yum makecache
        #sed -i '/[main]/a exclude=kernel*' /etc/yum.conf
        yum -y install lshw vim tree bash-completion git xorg-x11-xauth xterm \
                gettext axel tmux vnstat man vixie-cron screen vixie-cron crontabs \
                wget curl iproute tar gdisk iotop iftop htop
        . /etc/bash_completion
        [ "$release" = "6" ] && yum -y groupinstall "Development tools" "Server Platform Development"
        [ "$release" = "7" ] && yum -y groups install "Development Tools" "Server Platform Development"
}

changZHCN() {
        if [ "$release" = "6" ]; then
                yum groupinstall "Chinese Support" -y
                cat > /etc/sysconfig/i18n <<-EOF
                        #LANG=C
                        #SYSFONT=latarcyrheb-sun16
                        LANG="zh_CN.UTF-8"
                        SYSFONT="latarcyrheb-sun16"
                        SUPPORTED="zh_CN.UTF-8:zh_CN:zh"
                EOF
        elif [ "$release" = "7" ]; then
                localectl set-locale LANG=zh_CN.utf8
                localectl set-keymap cn
                localectl set-x11-keymap cn
        fi
}

addBINscript() {
        [ -x /bin/systeminfo ] && break
        curl -Lk http://www.dwhd.org/script/securityremove > /bin/securityremove
        curl -Lk http://www.dwhd.org/script/lsmod >/bin/lsmod
        curl -Lk http://www.dwhd.org/script/systeminfo > /bin/systeminfo
        curl -Lk http://www.dwhd.org/script/vim.tar.gz | gunzip | tar x -C ~/
        [ -e ~/.vim/syntax ] || mkdir -p ~/.vim/syntax
        curl http://www.vim.org/scripts/download_script.php?src_id=19394 -o ~/.vim/syntax/nginx.vim
        chmod +x /bin/{securityremove,lsmod,systeminfo}
        test -f /etc/bash.bashrc && sed -i "/securityremove/d" /etc/bash.bashrc && echo 'alias rm="/bin/securityremove"' >> /etc/bash.bashrc && . /etc/bash.bashrc
        test -f /etc/bashrc && sed -i "/securityremove/d" /etc/bashrc && echo 'alias rm="/bin/securityremove"' >> /etc/bashrc && . /etc/bashrc
        test -f /root/.bashrc && sed -i "/alias rm/d" /root/.bashrc && echo 'alias rm="/bin/securityremove"' >> /root/.bashrc && . /root/.bashrc
        echo -e '#alias ls="/bin/lsmod"\nalias ls="ls --color=auto"' >> ~/.bashrc && . ~/.bashrc
        #tar xf vim.tar.gz -C /root/ && /bin/rm -rf vim.tar.gz
        sed -i "1i au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/*.conf if &ft == '' | setfiletype nginx | endif" ~/.vimrc
        if ! grep "alias vi='vim'" /root/.bashrc &>/dev/null; then
                cat >> /root/.bashrc <<-EOF
                        alias vi='vim'
                        alias last='last -i'
                        alias grep='grep --color=auto'
                        export VISUAL=vim
                        export EDITOR=vim
                EOF
                sed -i 's/.*set hlsearch.*/"&/' /etc/vimrc
        fi
}

setPS1() {
        echo -e '\n[ -f ~/.bashrc ] && . ~/.bashrc' >> /etc/profile
        echo -e "\nunset MAILCHECK" >> /etc/profile
        echo "PS1='[\[\033[0;34m\]\u\[\033[0;37m\]@\[\033[0;35m\]\h\[\033[0;33m\] \w\[\033[0;37m\]]\[\033[0;31m\]\\$\[\033[00m\] '" >>/etc/profile
        echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%F %H:%M:%S\"):\$user:\`pwd\`:\$msg ---- \$(who am i); } >> /tmp/\`date \"+%F\"\`.\`hostname\`.\`whoami\`.history-timestamp'" >> /etc/profile

        for i in `find /home/ -name '.bashrc'` /etc/skel/.bashrc ~/.bashrc ;do
                cat >> $i <<-EOF
                        xterm_set_tabs() {
                                TERM=linux
                                export \$TERM
                                setterm -regtabs 4
                                TERM=xterm
                                export \$TERM
                        }

                        linux_set_tabs() {
                                TERM=linux;
                                export \$TERM
                                setterm -regtabs 8
                                LESS="-x4"
                                export LESS
                        }

                        #[ \$(echo \$TERM) == "xterm" ] && xterm_set_tabs
                        linux_set_tabs

                        listipv4() {
                                if [ "\$1" != "lo" ]; then
                                        which ifconfig >/dev/null 2>&1 && ifconfig | sed -rn '/^[^ \\t]/{N;s/(^[^ ]*).*addr:([^ ]*).*/\\1=\\2/p}' | \\
                                                awk -F= '\$2!~/^192\\.168|^172\\.(1[6-9]|2[0-9]|3[0-1])|^10\\.|^127|^0|^\$/{print}' \\
                                                || ip addr | awk '\$1=="inet" && \$NF!="lo"{print \$NF"="\$2}'
                                else
                                        which ifconfig >/dev/null 2>&1 && ifconfig | sed -rn '/^[^ \\t]/{N;s/(^[^ ]*).*addr:([^ ]*).*/\\1=\\2/p}' \\
                                        || ip addr | awk '\$1=="inet" && \$NF!="lo"{print \$NF"="\$2}'
                                fi
                        }

                        tmux_init() {
                                tmux new-session -s "LookBack" -d -n "local"    # 开启一个会话
                                tmux new-window -n "other"          # 开启一个窗口
                                tmux split-window -h                # 开启一个竖屏
                                tmux split-window -v "htop"          # 开启一个横屏,并执行top命令
                                tmux -2 attach-session -d           # tmux -2强制启用256color，连接已开启的tmux
                        }
                        # 判断是否已有开启的tmux会话，没有则开启
                        #if which tmux 2>&1 >/dev/null; then test -z "\$TMUX" && { tmux attach || tmux_init; };fi
                EOF
        done
}

setSELinux() {
        [ -f /etc/sysconfig/selinux ] && { sed -i 's/^SELINUX=.*/#&/;s/^SELINUXTYPE=.*/#&/;/SELINUX=.*/a SELINUX=disabled' /etc/sysconfig/selinux
                /usr/sbin/setenforce 0; }
        [ -f /etc/selinux/config ] && { sed -i 's/^SELINUX=.*/#&/;s/^SELINUXTYPE=.*/#&/;/SELINUX=.*/a SELINUX=disabled' /etc/selinux/config
                /usr/sbin/setenforce 0; }
}

iPython_install() {
        if which ipython >/dev/null 2>&1; then break;fi
        curl -Lk http://www.dwhd.org/script/tar_gz_bz2/Python-2.7.10.tar.xz | tar xJ -C ./
        curl -Lk http://www.dwhd.org/script/tar_gz_bz2/ipython-3.0.0.tar.gz | tar xz -C ./
        yum install readline-devel sqlite-devel -y
        tar xf Python-2.7.10.tar.xz
        tar xf ipython-3.0.0.tar.gz
        cd Python-2.7.10/
        ./configure --prefix=/usr/local/python2.7.10
        make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && make install
        cd ../ipython-3.0.0/
        /usr/local/python2.7.10/bin/python2.7 setup.py build
        /usr/local/python2.7.10/bin/python2.7 setup.py install
        cd ..
        ln -sv /usr/local/python2.7.10/bin/ipython /usr/bin/
        ln -sv /usr/local/python2.7.10/bin/python2.7 /usr/bin/
        rm -rf Python-2.7.10* ipython-3.0.0* && clear
        ipython -c "print 'Hello, This is iPython print!'"
}

naliINSTALL() {
        if which nali >/dev/null 2>&1; then break;fi
        mkdir /tmp/src && cd /tmp/src
        curl -Lk http://www.dwhd.org/wp-content/uploads/2015/08/nali-0.2.tar.gz | tar xz -C ./
        cd nali-0.2 && ./configure && make && make install && nali-update
        cd ~ && /bin/rm -rf /tmp/src
}

#if ! which ipython >/dev/null 2>&1; then iPython_install;fi

dockerINSTALL() {
        if [ "$release" = "7" ]; then
                rpm --import https://yum.dockerproject.org/gpg
                cat >/etc/yum.repos.d/docker.repo <<-EOF
                        [dockerrepo]
                        name=Docker Repository
                        baseurl=https://yum.dockerproject.org/repo/main/centos/7
                        enabled=1
                        gpgcheck=1
                        gpgkey=https://yum.dockerproject.org/gpg
                EOF

                yum clean all && yum makecache
                yum install -y docker-engine

                systemctl start docker.service
                systemctl enable docker.service
                systemctl status docker.service
                curl -Ls onekey.sh/dockbash |tee /etc/skel/.bash_docker ~/.bash_docker >/dev/null && . ~/.bash_docker
                [ -f ~/.bash_docker ] && echo '[ -f ~/.bash_docker ] && . ~/.bash_docker' >>/etc/profile
        fi
}

setWGET() {
        mv /usr/share/locale/zh_CN/LC_MESSAGES/wget.{mo,mo.back}
        msgunfmt /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo.back -o - | sed 's/eta(英国中部时间)/ETA/' | msgfmt - -o /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo
}

setSYSCTL() {
        cp /etc/sysctl.conf{,_$(date "+%Y%m%d_%H%M%S")_backup}
        cat > /etc/sysctl.conf <<-EOF
                fs.file-max=65535
                net.ipv4.tcp_max_tw_buckets = 60000
                net.ipv4.tcp_sack = 1
                net.ipv4.tcp_window_scaling = 1
                net.ipv4.tcp_rmem = 4096 87380 4194304
                net.ipv4.tcp_wmem = 4096 16384 4194304
                net.ipv4.tcp_max_syn_backlog = 65536
                net.core.netdev_max_backlog = 32768
                net.core.somaxconn = 32768
                net.core.wmem_default = 8388608
                net.core.rmem_default = 8388608
                net.core.rmem_max = 16777216
                net.core.wmem_max = 16777216
                net.ipv4.tcp_timestamps = 0
                net.ipv4.tcp_synack_retries = 2
                net.ipv4.tcp_syn_retries = 2
                net.ipv4.tcp_tw_recycle = 1
                #net.ipv4.tcp_tw_len = 1
                net.ipv4.tcp_tw_reuse = 1
                net.ipv4.tcp_mem = 94500000 915000000 927000000
                net.ipv4.tcp_max_orphans = 3276800
                net.ipv4.tcp_tw_recycle = 1
                net.ipv4.ip_local_port_range = 1024 65000
                net.nf_conntrack_max = 6553500
                net.netfilter.nf_conntrack_max = 6553500
                net.netfilter.nf_conntrack_tcp_timeout_close_wait = 6
                net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
                net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
                net.netfilter.nf_conntrack_tcp_timeout_established = 3600
        EOF
}
main() {
        checkOSinfo
        setssh
        addYUM
        updateYUM
        changZHCN
        addBINscript
        setPS1
        setSELinux
        setSYSCTL && sysctl -p
        [ -n "$(grep "ipython" <<< ${@})" ] && iPython_install
        naliINSTALL
        [ -n "$(grep "docker" <<< ${@})" ] && dockerINSTALL
        setWGET
}

main ${@} && [ -x /bin/systeminfo ] && clear; systeminfo all
rm -rf $0
