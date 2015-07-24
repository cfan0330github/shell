#!/usr/bin/env bash

#
# Hello, lovely FastNetMon customer! I'm really happy to see you here!
#  Pavel Odintsov, author
#

# This script will get following params:
#  $1 client_ip_as_string
#  $2 data_direction
#  $3 pps_as_string
#  $4 action (ban or unban)
#  
#  2015-07-22  change ban func,auto ban ip.    cfan0330@gmail.com
#
#

email_notify="root,please_fix_this_email@domain.ru"
banok="success"
#
# Please be carefult! You should not remove cat >
#

if [ "$4" == "unban" ]; then
    # No details arrived to stdin here

    # Unban actions if used
    exit 0
fi

#
# For ban and attack_details actions we will receive attack details to stdin
# if option notify_script_pass_details enabled in FastNetMon's configuration file
#
# If you do not need this details, please set option notify_script_pass_details to "no".
#
# Please do not remove "cat" command if you have notify_script_pass_details enabled, because
# FastNetMon will crash in this case (it expect read of data from script side).
#

if [ "$4" == "ban" ]; then
	bip=$1
        user="admin"
        pass="admin"
        export bip
        export user
        export pass
        ret=$(expect <<'END'
        log_user 0
        set B_ip $env(bip)
        set User_N $env(user)
        set Pass_D $env(pass)
        spawn telnet 1.1.1.1
        expect {
                "Username:" {
                        send "$User_N\n";
                }
                "Password:" {
                        send "$User_N\n";
                }
        }
        expect {
                "Password:" {send "$Pass_D\n";}
                ">" {send "en\n" ;send "$Pass_D\n";}
        }
        expect {
                -re "Login invalid" {
                                set results $expect_out(buffer)
                                puts $results
                                exit 1;
                }
                "#" {send "conf t\n"}
        }
        expect -re "configuration" {
                        send "ip route $B_ip 255.255.255.255 Null0\n"
        }
        expect -re "#" {send "exit\n"}
        expect -re "#" {send "show ip route static | i $B_ip/32\n"}
        expect -re "Null0"
        set results $expect_out(buffer)
        puts $results
        expect eof
END
)
        ret=`echo $ret|grep $bip`
        if [ -z "$ret" ]; then
                banok=""
        fi
	cat | mail -s "$banok FastNetMon Guard: IP $1 blocked because $2 attack with power $3 pps" $email_notify;
   
    exit 0
fi

if [ "$4" == "attack_details" ]; then
       # cat | mail -s "$banok FastNetMon Guard: IP $1 blocked because $2 attack with power $3 pps" $email_notify;
        exit 0
fi
