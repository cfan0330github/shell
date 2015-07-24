#! /usr/bin/expect -d
set timeout 10

set RET_VALUE 0
set SRC_IP  [lindex $argv 0]
set User_N  [lindex $argv 1]
set Pass_D  [lindex $argv 2]
set Con_f   [lindex $argv 3]
set Dir_d   [lindex $argv 4]
 
spawn telnet $SRC_IP
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
   -re "Login invalid" {exit 1}
   "#"  {send "copy running-config ftp://westserver:bingft22p2009@61.139.126.34\n"}
   ">"  {send "ftp 61.139.126.34\n"}
}
expect {
   -re "host" {send "\n"}
   -re "none"  {send "westserver\n"}
}
expect {
   -re "password:" {send "bingft22p2009\n"}
   -re "filename"  {send "$Dir_d/$Con_f\n"}
}
expect {
   -re "bytes copied" {
		send "exit\n"
		exit 0;
	}
   -re "ftp" {send "cd $Dir_d\n"}
}
expect {
    -re "ftp" {send "put vrpcfg.zip $Con_f\n"}
}
expect {
   -re "Transfer complete" {
		send "quit\n"
		exit 0;
	}
}
expect {
   "#" {
	send "exit\n"
	exit 1;
	}
   "]" {
	send "quit\n"
	exit 1;
	}
}
