How To Configure DNS (BIND) Server on CentOS 7 / RHEL 7
By Raj Last updated Jul 17, 2019
 7
 22
The Domain Name System (DNS) is a hierarchical distributed naming system for computers, services, or any resource connected to the Internet or a private network. It associates various information with domain names assigned to each of the participating entities.

Most importantly, it translates domain names meaningful to humans into the numerical identifiers associated with networking equipment for the purpose of locating and addressing these devices worldwide.

This guide will help you to set up DNS server on CentOS 7 / RHEL 7.

Environment
Server Name: primary.itzgeek.local

IP Address: 192.168.1.10

Install DNS (BIND)
BIND stands for Berkeley Internet Name Domain, a software which provides an ability to perform name to ip conversion.


yum -y install bind bind-utils
Configure DNS (BIND)
By defaulf, BIND listens on localhost. So, we will configure DNS server to listen on system IP address to let clients can reach to DNS server for resolving domain names.

vi /etc/named.conf
Configure BIND to listen on all IP addresses.

// listen-on port 53 { 127.0.0.1; };
// listen-on-v6 port 53 { ::1; };
OR

Configure BIND to listen on particular IP address.

listen-on port 53 { 127.0.0.1; 192.168.1.10; };
Add your network in the following line. This setting will allow clients from the mentioned network can query the DNS for the name to ip translation.


I’ve added 192.168.1.0/24 for this demo.

allow-query     { localhost; 192.168.1.0/24; };
Create Zones
Edit /etc/named.conf.


vi /etc/named.conf
Forward Zone
The following zone is the forward zone entry for the itzgeek.local domain.

zone "itzgeek.local" IN {
         type master;
         file "fwd.itzgeek.local.db";
         allow-update { none; };
};
itzgeek.local – Domain name
master – Primary DNS
fwd.itzgeek.local.db – Forward lookup file
allow-update – Since this is the primary DNS, it should be none

Reverse Zone
The following zone is the reverse zone entry.

zone "1.168.192.in-addr.arpa" IN {
          type master;
          file "1.168.192.db";
          allow-update { none; };
};

1.168.192.in-addr.arpa – Reverse lookup name
master – Primary DNS
1.168.192.db – Reverse lookup file
allow-update – Since this is the primary DNS, it should be none

Create Zone Files
By default, zone lookup files are placed under /var/named directory. Create a zone file called fwd.itzgeek.local.db for forward lookup under /var/named directory. All domain names should end with a dot (.).

vi /var/named/fwd.itzgeek.local.db
There are some special keywords for Zone Files

A – A record
NS – Name Server
MX – Mail for Exchange
CNAME – Canonical Name

@   IN  SOA     primary.itzgeek.local. root.itzgeek.local. (
                                                1001    ;Serial
                                                3H      ;Refresh
                                                15M     ;Retry
                                                1W      ;Expire
                                                1D      ;Minimum TTL
                                                )

;Name Server Information
@      IN  NS      primary.itzgeek.local.

;IP address of Name Server
primary IN  A       192.168.1.10

;Mail exchanger
itzgeek.local. IN  MX 10   mail.itzgeek.local.

;A - Record HostName To IP Address
www     IN  A       192.168.1.100
mail    IN  A       192.168.1.150

;CNAME record
ftp     IN CNAME        www.itgeek.local.
Whenever you update the zone lookup file, you need to change/increment the serial like 1002 ;Serial.
Create a zone file called 1.168.192.db for the reverse zone under /var/named directory.

vi /var/named/1.168.192.db
Create a reverse pointer for the forward zone entries we created earlier.

PTR – Pointer
SOA – Start of Authority


@   IN  SOA     primary.itzgeek.local. root.itzgeek.local. (
                                                1001    ;Serial
                                                3H      ;Refresh
                                                15M     ;Retry
                                                1W      ;Expire
                                                1D      ;Minimum TTL
                                                )

;Name Server Information
@ IN  NS      primary.itzgeek.local.

;Reverse lookup for Name Server
8        IN  PTR     primary.itzgeek.local.

;PTR Record IP address to HostName
100      IN  PTR     www.itzgeek.local.
150      IN  PTR     mail.itzgeek.local.
Whenever you update the zone lookup file, you need to change/increment the serial like 1002 ;Serial.
Once zone files are created, restart bind service.

systemctl restart named
Enable it on system startup.

systemctl enable named
Firewall
Add a allow rule in firewall to let clients can connect to DNS server for name resolution.

firewall-cmd --permanent --add-port=53/udp

firewall-cmd --reload
Verify Zones
Visit any client machine and add a DNS server ip address in /etc/resolv.conf.

nameserver 192.168.1.10
If Network Manager manages the networking then place the following entry in /etc/sysconfig/network-scripts/ifcfg-eXX file.

DNS1=192.168.1.10
Restart network service.

systemctl restart NetworkManager
Use the following command to verify the forward lookup.

dig www.itzgeek.local
Output: The DNS server should give 192.168.1.100 as ip for www.itzgeek.local.


; <<>> DiG 9.9.4-RedHat-9.9.4-74.el7_6.1 <<>> www.itzgeek.local
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35563
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.itzgeek.local.             IN      A

;; ANSWER SECTION:
www.itzgeek.local.      86400   IN      A       192.168.1.100

;; AUTHORITY SECTION:
itzgeek.local.          86400   IN      NS      primary.itzgeek.local.

;; ADDITIONAL SECTION:
primary.itzgeek.local.  86400   IN      A       192.168.1.10

;; Query time: 0 msec
;; SERVER: 192.168.1.10#53(192.168.1.10)
;; WHEN: Wed Jul 03 02:00:40 EDT 2019
;; MSG SIZE  rcvd: 100
Install BIND utilities yum install -y bind-utils package to get nslookup or dig command.
Confirm the reverse lookup.

dig -x 192.168.1.100
Output: The DNS server gives www.itzgeek.local as a name for 192.168.12.100.

; <<>> DiG 9.9.4-RedHat-9.9.4-74.el7_6.1 <<>> -x 192.168.1.100
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4807
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;100.1.168.192.in-addr.arpa.    IN      PTR

;; ANSWER SECTION:
100.1.168.192.in-addr.arpa. 86400 IN    PTR     www.itzgeek.local.

;; AUTHORITY SECTION:
1.168.192.in-addr.arpa. 86400   IN      NS      primary.itzgeek.local.

;; ADDITIONAL SECTION:
primary.itzgeek.local.  86400   IN      A       192.168.1.10

;; Query time: 0 msec
;; SERVER: 192.168.1.10#53(192.168.1.10)
;; WHEN: Wed Jul 03 02:02:47 EDT 2019
;; MSG SIZE  rcvd: 124
It is now confirmed that both forward and reverse lookups are working fine.

Conclusion
That’s All. You have successfully installed BIND on CentOS 7 / RHEL 7 as the master server. You can configure a slave DNS server for reduntancy.

source:

https://www.itzgeek.com/how-tos/linux/centos-how-tos/configure-dns-bind-server-on-centos-7-rhel-7.html
