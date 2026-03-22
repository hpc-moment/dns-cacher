## Checks to meet requirements 
### Main checks 
#### 1 Проверка конфигурационного файла
```bash 
unbound-checkconf /etc/unbound/unbound.conf
```
`unbound-checkconf: no errors in /etc/unbound/unbound.conf`
#### 2 Проверка статуса
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
#### 3 Проверка DNSSEC
```bash
dig @127.0.0.1 example.com A +dnssec
```
Требуется наличие флага `ad` в `flags`.
<details>
  <summary>results</summary>

  ```bash
; <<>> DiG 9.18.39-0ubuntu0.22.04.2-Ubuntu <<>> @127.0.0.1 example.com A +dnssec
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3058
;; flags: qr rd ra ad; ← КРИТИЧЕСКИ ВАЖНО: флаг AD присутствует
QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 1232
;; QUESTION SECTION:
;example.com.                   IN      A

;; ANSWER SECTION:
example.com.            300     IN      A       8.6.112.0
example.com.            300     IN      A       8.47.69.0
example.com.            300     IN      RRSIG   A 13 2 300 20260323194651 20260321174651 34505 example.com. Wgk+z4ypsx8SgxbaUo1JMz/z86gU5eKh6ep+TGJTDyM8MBdP4D0S0E0S qqPR9L9B7LQK/o5pYWGODSdy0F1x/g==

;; Query time: 150 msec ← Первый запрос: высокая задержка (рекурсия)
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 22 18:46:49 UTC 2026
;; MSG SIZE  rcvd: 179

  ```
</details>

#### 4 Проверка кэша
При повторном запросе `dig @127.0.0.1 example.com A +dnssec`, в ответе Unbound `Query time: <0-5> msec` - запрос 
закэширован
