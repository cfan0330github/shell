#! /bin/sh

PATH="/sbin:/usr/sbin:/bin:/usr/bin"
export PATH

cd /root/networkdev
[ -f swbak.log ] || touch swbak.log
newbakdir=`date +%Y%m`
basedir='switch/'


/usr/bin/ftp -n <<EOF
open 1.1.1.1
user username passwd
pass off
prompt
bin
cd switch
mkdir $newbakdir
cd $newbakdir
bye
EOF

while read line; do
  if [ '#' == "${line:0:1}" ]; then continue;fi
  echo $line|awk -F"," '{print $1,$2,$3,$4,$5}'|(read ip user pass conf dir;\
# echo result=$ip,$user,$pass,$conf,$dir
  exec=`whereis expect|awk '{print $2}'`
  $exec -f atelnet.sh $ip $user $pass `date +%Y_%m`_$conf $basedir$newbakdir"/"$dir 
  if [ $? -ne 0 ]; then
	echo `date +%Y_%m` $ip back error>>swbak.log
  fi
)
done<switch.conf
