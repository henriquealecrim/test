  ###########################################
  #---------) Network Information (---------#
  ###########################################
  printf $B"===================================( "$GREEN"Network Information"$B" )====================================\n"$NC

  #-- NI) Hostname, hosts and DNS
  printf $Y"[+] "$GREEN"Hostname, hosts and DNS\n"$NC
  cat /etc/hostname /etc/hosts /etc/resolv.conf 2>/dev/null | grep -v "^#" | grep -Ev "\W+\#|^#" 2>/dev/null
  dnsdomainname 2>/dev/null || echo_not_found "dnsdomainname" 
  echo ""

  #-- NI) /etc/inetd.conf
  printf $Y"[+] "$GREEN"Content of /etc/inetd.conf & /etc/xinetd.conf\n"$NC
  (cat /etc/inetd.conf /etc/xinetd.conf 2>/dev/null | grep -v "^#" | grep -Ev "\W+\#|^#" 2>/dev/null) || echo_not_found "/etc/inetd.conf" 
  echo ""

  #-- NI) Interfaces
  printf $Y"[+] "$GREEN"Interfaces\n"$NC
  cat /etc/networks 2>/dev/null
  (ifconfig || ip a) 2>/dev/null
  echo ""

  #-- NI) Neighbours
  printf $Y"[+] "$GREEN"Networks and neighbours\n"$NC
  (route || ip n || cat /proc/net/route) 2>/dev/null
  (arp -e || arp -a || cat /proc/net/arp) 2>/dev/null
  echo ""

  #-- NI) Iptables
  printf $Y"[+] "$GREEN"Iptables rules\n"$NC
  (timeout 1 iptables -L 2>/dev/null; cat /etc/iptables/* | grep -v "^#" | grep -Ev "\W+\#|^#" 2>/dev/null) 2>/dev/null || echo_not_found "iptables rules"
  echo ""

  #-- NI) Ports
  printf $Y"[+] "$GREEN"Active Ports\n"$NC
  printf $B"[i] "$Y"https://book.hacktricks.xyz/linux-unix/privilege-escalation#open-ports\n"$NC
  (netstat -punta || ss --ntpu || (netstat -a -p tcp && netstat -a -p udp) | grep -i listen) 2>/dev/null | sed -E "s,127.0.[0-9]+.[0-9]+,${C}[1;31m&${C}[0m,"
  echo ""

  #-- NI) tcpdump
  printf $Y"[+] "$GREEN"Can I sniff with tcpdump?\n"$NC
  timeout 1 tcpdump >/dev/null 2>&1
  if [ $? -eq 124 ]; then #If 124, then timed out == It worked
      printf $B"[i] "$Y"https://book.hacktricks.xyz/linux-unix/privilege-escalation#sniffing\n"$NC
      echo "You can sniff with tcpdump!" | sed -E "s,.*,${C}[1;31m&${C}[0m,"
  else echo_no
  fi
  echo ""

  #-- NI) Internet access
  if ! [ "$SUPERFAST" ] && ! [ "$NOTEXPORT" ] && [ -f "/bin/bash" ]; then
    printf $Y"[+] "$GREEN"Internet Access?\n"$NC
    check_tcp_80 &
    check_tcp_443 &
    check_icmp &
    timeout 10 /bin/bash -c '(( echo cfc9 0100 0001 0000 0000 0000 0a64 7563 6b64 7563 6b67 6f03 636f 6d00 0001 0001 | xxd -p -r >&3; dd bs=9000 count=1 <&3 2>/dev/null | xxd ) 3>/dev/udp/1.11.1.1/53 && echo "DNS available" || echo "DNS not available") 2>/dev/null | grep "available"' 2>/dev/null &
    wait
    echo ""
  fi
  echo ""
  if [ "$WAIT" ]; then echo "Press enter to continue"; read "asd"; fi
fi
