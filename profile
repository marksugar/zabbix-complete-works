# /etc/profile

# System wide environment and startup programs, for login setup
# Functions and aliases go in /etc/bashrc

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}


if [ -x /usr/bin/id ]; then
    if [ -z "$EUID" ]; then
        # ksh workaround
        EUID=`/usr/bin/id -u`
        UID=`/usr/bin/id -ru`
    fi
    USER="`/usr/bin/id -un`"
    LOGNAME=$USER
    MAIL="/var/spool/mail/$USER"
fi

# Path manipulation
if [ "$EUID" = "0" ]; then
    pathmunge /usr/sbin
    pathmunge /usr/local/sbin
else
    pathmunge /usr/local/sbin after
    pathmunge /usr/sbin after
fi

HOSTNAME=`/usr/bin/hostname 2>/dev/null`
HISTSIZE=1000
if [ "$HISTCONTROL" = "ignorespace" ] ; then
    export HISTCONTROL=ignoreboth
else
    export HISTCONTROL=ignoredups
fi

export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL

# By default, we want umask to get set. This sets it for login shell
# Current threshold for system reserved uid/gids is 200
# You could check uidgid reservation validity in
# /usr/share/doc/setup-*/uidgid file
if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
    umask 002
else
    umask 022
fi

for i in /etc/profile.d/*.sh /etc/profile.d/sh.local ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then 
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done

unset i
unset -f pathmunge

unset MAILCHECK
[ -f ~/.bashrc ] && . ~/.bashrc
alias vi='vim'

NodeID=`ip a| awk '$1=="inet" && $2!~"^127"{print $2;exit}'|sed 's/\./_/g;s/\/.*$//'`
for i in static pretty transient; do hostnamectl set-hostname DS-VM-Node${NodeID}.cluster.com --$i; done
PS1='🌟 \[\033[1;33m\u\[\033[1;31m\]@\h 🎁 \[\033[1;32m\]\w 🎄 \[\033[1;36m\]\[\033[0;37m\]❄️ `date +%F" "%T` \n\[\033[1;37m\]$ \[\033[0m\]'
#PS1='🌟 \[\033[1;33m\u\[\033[1;31m\]@\h 🎁 \[\033[1;32m\]\w 🎄 \[\033[1;36m\]\[\033[0;37m\]❄️ `date +%F` \A  \n\[\033[1;37m\]$ \[\033[0m\]'
#PS1="\[$(tput bold; tput setaf 2)\]\s\[$(tput sgr0)\] \$"
#PS1="🎄\s \W \$ "
#PS1='[\[\033[0;34m\]\u\[\033[0;37m\]@\[\033[0;35m\]DT_Node-${NodeID}\[\033[0;33m\] \w\[\033[0;37m\]]\[\033[0;31m\]\$\[\033[00m\] '
#PS1='🌟 \033[34m🐳\[\033[1;33m\u\[\033[1;31m\]@\h \033[34m🐳 \[\033[1;32m\]\w ☸ 🎄  \[\033[1;36m\]\[\033[0;37m\] `date +%F" "%T` \n\[\033[1;37m\]$ \[\033[0m\]'
export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; });user=$(whoami); echo $(date "+%F %H:%M:%S"):$user:`pwd`:$msg ---- $(who am i); } >> /tmp/`date "+%F"`.`hostname`.`whoami`.history-timestamp'
