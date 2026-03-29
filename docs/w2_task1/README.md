# Проверка кэширования — убывание TTL

Запросы с выводом TTL и проверкой dnssec выполняются следующей командой

```shell
dig @127.0.0.1 example.com A +ttl +dnssec
```

# Подключение prefetch — принудительное обновление кэша

Prefetch будет выполняться в случае, когда пользователь запрашивает закешированное имя домена, оставшийся TTL которого
меньше 10% от изначального (значение по умолчанию). Например, TTL <33 сек для изначального TTL=330. <br>
Соответственно, для проверки работы prefetch, требуется выполнять команды `dig @127.0.0.1 example.com A +ttl` в 
определенное время и смотреть на TTL и Response time.

# Принудительное кэширование нестандартным TTL

Необходимо сделать запрос в upstream, минуя наш резолвер, и сравнить TTL. Для запроса к upstream можно использовать 
команду
```shell
dig @8.8.8.8 example.com A +ttl
```

# Eviction кэша при переполнении

Команды для проверки:
1. Кеширование yandex.ru `dig @127.0.0.1 yandex.ru A +ttl`
2. Запуск скрипта нагрузки 
```shell
chmod +x fill_cache.sh
./scripts/fill_cache.sh 2>&1 | tee /tmp/eviction_log.txt
```
3. Просмотр статистики Ubound `unbound-control stats | grep -E "cache|queries" `
4. Просмотр кэша (для yandex.ru) `unbound-control dump_cache | grep -A2 "yandex.ru"`

Ожидаемый вывод:

```shell
 dig @127.0.0.1  yandex.ru A +ttl

; <<>> DiG 9.18.39-0ubuntu0.22.04.2-Ubuntu <<>> @127.0.0.1 yandex.ru A +ttl
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7746
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;yandex.ru.                     IN      A

;; ANSWER SECTION:
yandex.ru.              600     IN      A       77.88.55.88
yandex.ru.              600     IN      A       5.255.255.77
yandex.ru.              600     IN      A       77.88.44.55

;; Query time: 60 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 29 18:19:53 UTC 2026
;; MSG SIZE  rcvd: 86

# ./scripts/fill_cache.sh 2>&1 | tee /tmp/eviction_log.txt
Начало заполнения кэша: Sun Mar 29 18:20:10 UTC 2026
Размер кэша до: mem.cache.message=718821
=== Запросов: 500, Время: 18:20:35 ===
thread0.num.cachehits=0
thread0.num.cachemiss=254
thread1.num.cachehits=0
thread1.num.cachemiss=246
total.num.cachehits=0
total.num.cachemiss=500
mem.cache.rrset=589498
mem.cache.message=871713
yandex.ru в кэше: 11 записей
=== Запросов: 1000, Время: 18:21:01 ===
thread0.num.cachehits=0
thread0.num.cachemiss=501
thread1.num.cachehits=0
thread1.num.cachemiss=499
total.num.cachehits=0
total.num.cachemiss=1000
mem.cache.rrset=589008
mem.cache.message=1024714
yandex.ru в кэше: 11 записей
=== Запросов: 1500, Время: 18:21:27 ===
thread0.num.cachehits=0
thread0.num.cachemiss=173
thread1.num.cachehits=0
thread1.num.cachemiss=207
total.num.cachehits=0
total.num.cachemiss=380
mem.cache.rrset=589240
mem.cache.message=1114107
yandex.ru в кэше: 0 записей
!!! EVICTION ОБНАРУЖЕН: yandex.ru вытеснен из кэша! Запросов: 1500
Размер кэша после: mem.cache.message=1114107
# dig @127.0.0.1  yandex.ru A +ttl

; <<>> DiG 9.18.39-0ubuntu0.22.04.2-Ubuntu <<>> @127.0.0.1 yandex.ru A +ttl
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36666
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;yandex.ru.                     IN      A

;; ANSWER SECTION:
yandex.ru.              600     IN      A       77.88.55.88
yandex.ru.              600     IN      A       5.255.255.77
yandex.ru.              600     IN      A       77.88.44.55

;; Query time: 110 msec <- ЗАПРОС НЕ БЫЛ В КЕШЕ
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Mar 29 18:21:58 UTC 2026
;; MSG SIZE  rcvd: 86

```
