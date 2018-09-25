#!/bin/bash
LSHPATH=/data/shell/
LSHFILE=/data/shell/cleanlog.sh
LOGPATH=/data/javalog/

[ -d ${LSHPATH} ] || mkdir ${LSHPATH} -p 
cat > ${LSHFILE} << EOF
#!/bin/bash
[ ! -d ${LOGPATH} ] || find ${LOGPATH} -name '*.log*' -mtime +10 -exec rm {} \;
EOF

chmod +x ${LSHFILE}
(crontab -l; echo -e "10 12 * * * ${LSHFILE}" ) | crontab -
