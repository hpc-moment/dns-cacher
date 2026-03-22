## Checks to meet requirements 
### Main checks 
```bash 
unbound-checkconf /etc/unbound/unbound.conf
```
`unbound-checkconf: no errors in /etc/unbound/unbound.conf`

```bash
unbound-control status
```
```version: 1.13.1
verbosity: 2
threads: 2
modules: 2 [ validator iterator ]
uptime: 13495 seconds
options: reuseport control(ssl)
unbound (pid 41) is running...
```
```bash
dig @127.0.0.1 yandex.ru AD
```
<details>
  <summary>results</summary>

  ```bash
; <<>> DiG 9.18.39-0ubuntu0.22.04.2-Ubuntu <<>> @127.0.0.1 yandex.ru AD
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42357
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;yandex.ru.                     IN      A

;; ANSWER SECTION:
yandex.ru.              600     IN      A       5.255.255.77
yandex.ru.              600     IN      A       77.88.55.88
yandex.ru.              600     IN      A       77.88.44.55

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 22 13:46:52 UTC 2026
;; MSG SIZE  rcvd: 86

;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43464
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;AD.                            IN      A

;; AUTHORITY SECTION:
AD.                     3600    IN      SOA     anycast9.irondns.net. dnsmaster.corenic.org. 2603221345 7200 7200 604800 7200

;; Query time: 310 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 22 13:46:52 UTC 2026
;; MSG SIZE  rcvd: 108

  ```
</details>