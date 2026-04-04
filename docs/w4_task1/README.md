## Добавленные скрипты

check_adress_change.sh - проверка подмены адреса для isc.org
zone_check.sh - Проверка DNSSEC через публичный валидирующий резолвер

## Команды для проверки
### КОМАНДА 1: Доказательство DNSSEC на реальной зоне
`dig isc.org DS @8.8.8.8 +dnssec`

```
; <<>> DiG 9.18.39-0ubuntu0.22.04.3-Ubuntu <<>> isc.org DS @8.8.8.8 +dnssec
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23145
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 512
;; QUESTION SECTION:
;isc.org.                       IN      DS

;; ANSWER SECTION:
isc.org.                3600    IN      DS      7250 13 2 A30B3F78B6DDE9A4A9A2AD0C805518B4F49EC62E7D3F4531D33DE697 CDA01CB2
isc.org.                3600    IN      RRSIG   DS 8 2 3600 20260422153322 20260401143322 29805 org. leQpSbVTKlJOOoD/UxZd0Pbc/T4r6ABpTA0QL6PE1KMd2ECi6I9F0oJ4 ixFtr2uUkP+uAjWFW09jl0b+vqXy7HmKBjLonk4b/OBye9XtMpNSmusN ednJHTlwrnoF8w4tTJTtz7tDh/AOH26SwLyiL9autuuuufGxYUlp0TVv KOk=

;; Query time: 40 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Sat Apr 04 16:04:28 UTC 2026
;; MSG SIZE  rcvd: 247
```

### КОМАНДА 2: Реальный IP isc.org (от авторитетного сервера)
`dig isc.org A @ns1.isc.org +short`

```
151.101.194.217
151.101.2.217
151.101.66.217
151.101.130.217
```

### КОМАНДА 3: Подменный IP от нашего резолвера
`dig isc.org A @127.0.0.1 +short`

```
192.0.2.0
```

### КОМАНДА 4: Сравнение флагов (AD есть vs AA есть) через скрипт
`./scripts/check_adress_change.sh`

```
=== Реальный IP isc.org (авторитетный сервер) ===
151.101.194.217
151.101.130.217
151.101.2.217
151.101.66.217

=== Подменный IP isc.org (наш резолвер) ===
192.0.2.0

=== Разница в флагах ===
Публичный резолвер 8.8.8.8 (с DNSSEC):
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1
; EDNS: version: 0, flags: do; udp: 512
Наш резолвер (локальная зона):
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
; EDNS: version: 0, flags: do; udp: 1232
```

### КОМАНДА 5: NXDOMAIN для несуществующего поддомена
`dig nonexistent.isc.org A @127.0.0.1 +short`

```
; <<>> DiG 9.18.39-0ubuntu0.22.04.3-Ubuntu <<>> nonexistent.isc.org A @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 14618
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;nonexistent.isc.org.           IN      A

;; AUTHORITY SECTION:
isc.org.                300     IN      SOA     ns1.isc.org. support.isc.org. 2024011501 3600 900 604800 300

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sat Apr 04 16:09:56 UTC 2026
;; MSG SIZE  rcvd: 96
```

# КОМАНДА 6: Трассировка остановки рекурсии
`dig isc.org A @127.0.0.1 +trace`

```
; <<>> DiG 9.18.39-0ubuntu0.22.04.3-Ubuntu <<>> isc.org A @127.0.0.1 +trace
;; global options: +cmd
.                       81221   IN      NS      d.root-servers.net.
.                       81221   IN      NS      k.root-servers.net.
.                       81221   IN      NS      f.root-servers.net.
.                       81221   IN      NS      j.root-servers.net.
.                       81221   IN      NS      a.root-servers.net.
.                       81221   IN      NS      l.root-servers.net.
.                       81221   IN      NS      g.root-servers.net.
.                       81221   IN      NS      e.root-servers.net.
.                       81221   IN      NS      i.root-servers.net.
.                       81221   IN      NS      m.root-servers.net.
.                       81221   IN      NS      b.root-servers.net.
.                       81221   IN      NS      h.root-servers.net.
.                       81221   IN      NS      c.root-servers.net.
.                       81221   IN      RRSIG   NS 8 0 518400 20260417050000 20260404040000 54393 . rGyRorQ1O2mJolmPZ/hYNfdJzCbOlfkUBDooh33DlPrJlruI6TlmR9F9 Jn3acDhtqgZFjpoR1kCAPCI758FbP/dykC1iv3Z1dSHyJHK2aaG2Tk50 l3nMbvY3P99XHiQtGejyqxrqqLYIpD77KtiPdIRDHBn8khZHdHIlawMK FpT73COjUi5Dahe3AkH+4Uqs8TnMtuKHplQLmDODGVPqCCetBupVqLys UWBIWIpEMKOYmYRXMKk9cqve7749iYenA5lgmSxuatV0h7NiOKgJ3Fp8 6ms5uiDWlba7MuHlyBlGmw2c3WfO42Yw4CG6AKMJU9wbQVe3MPBbTFON Co/gZg==
;; Received 525 bytes from 127.0.0.1#53(127.0.0.1) in 0 ms
```
