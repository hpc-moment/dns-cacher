#import "touying/lib.typ": *
#import "touying/themes/university.typ": *
#import "touying/src/components.typ": side-by-side

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [САМТ: Кэширующий DNS-резолвер],
    subtitle: [Внешнее кэширование и управление зонами с DNSSEC],
    author: [Команда 5],
    date: datetime.today().display(),
  ),
)

// Настройка межстрочного интервала и отступов
#set text(size: 20pt, lang: "ru")
#set par(leading: 0.8em)
#show heading: it => it + v(0.5em)

#title-slide()

== Содержание

#set text(size: 13pt)
#outline(title: [Содержание], indent: 1em)

= Техническое задание и задачи

== Описание кейса и схема поиска

#slide[
  #set text(size: 13pt)
  #side-by-side[
    *Контекст и проблематика:*
    - DNS сопоставляет имена хостов с IP-адресами. При потере связности с авторитетными серверами, записи в обычном резолвере удаляются по истечении TTL.
    - *Решение:* Принудительное хранение информации во внешнем кэше (Redis) для доступа при "падении" апстрима.
    - *Безопасность:* Возможность обхода ограничений DNSSEC при локальной подмене данных.
    
    *Типы запросов:*
    1. Рекурсивный (клиент -> резолвер).
    2. Итеративный (резолвер -> иерархия серверов).
  ][
    #box(width: 95%)[
      #image("screenshots/dns_scheme.png", width: 100%)
      #align(center)[_Схема иерархического поиска_]
    ]
  ]
]

== Ключевые технические цели

- *Инфраструктура (W1):* Развертывание контейнеризированной среды Docker Compose с поддержкой DNSSEC и рекурсивной валидации (флаг `ad`).
- *Исследовательский анализ (W2):* Настройка лимитов кэша, запуск стресс-тестов на вытеснение (Eviction) и активация префетчинга для популярных имен.
- *Внешняя интеграция (W3):* Разработка Python-прокси для выноса кэширующего слоя в Redis с возможностью принудительного управления TTL.
- *Управление зонами (W4):* Реализация "Local Zones Collector" для нативной подмены данных в защищенных зонах через механизм `domain-insecure`.

= Архитектура системы

== Стек технологий

- *Резолвер:* Unbound 1.13.1 (модульность, Python-интеграция).
- *Хранилище:* Redis 7.4 (внешний кэш).
- *Разработка:* Python 3.9 + `dnspython`.
- *Среда:* Docker & Docker Compose.
- *Инструменты:* `unbound-control`, `dig`, `redis-cli`.

== Схема взаимодействия и сетевая топология

#slide[
  #align(center + horizon)[
    #box(width: 98%)[
      #set text(size: 13pt)
      #stack(
        dir: ltr,
        spacing: 1fr,
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [Клиент]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt)[Браузер / dig],
        ),
        stack(dir: ttb, spacing: 0.3em, align(center, [UDP/53]), sym.arrow.r),
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [dns-proxy]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: blue.lighten(92%))[Python \ 10.10.0.5],
        ),
        stack(dir: ttb, spacing: 0.3em, align(center, [TCP/6379]), sym.arrow.r),
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [dns-cache]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: red.lighten(92%), width: 7em)[Redis \ 10.10.0.3],
        ),
        stack(dir: ttb, spacing: 0.3em, align(center, [UDP/53]), sym.arrow.r),
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [dns-resolver]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: green.lighten(92%), width: 7em)[Unbound \ 10.10.0.2],
        ),
        sym.arrow.r,
        stack(dir: ttb, spacing: 0.5em, align(center, [Сеть]), block(stroke: 1pt, inset: 8pt, radius: 4pt)[Интернет]),
      )

      #v(0.8em)
      #align(left)[
        *Спецификация dns-lab (10.10.0.0/24):* Все компоненты изолированы в Docker-сети. Доступ извне только к порту 53/udp прокси-сервера. Redis и Unbound скрыты от прямого доступа клиента.
      ]
    ]
  ]
]

== Алгоритм работы прокси

#slide[
  #align(center + horizon)[
    #set text(size: 13pt)
    #rect(stroke: 0.5pt, inset: 12pt, radius: 10pt, fill: gray.lighten(95%))[
      #stack(
        dir: ttb,
        spacing: 0.8em,
        [#underline[Старт:] Получение UDP пакета],
        sym.arrow.b,
        stack(
          dir: ltr,
          spacing: 2em,
          block(stroke: 1pt, inset: 8pt, fill: red.lighten(90%))[Поиск в Redis],
          [#text(fill: green, [*HIT*]) -> Возврат из кэша],
        ),
        sym.arrow.b,
        [#text(fill: gray, [*MISS*]) -> Запрос к Unbound (Резолвинг)],
        sym.arrow.b,
        [Получение ответа (A-запись)],
        sym.arrow.b,
        block(stroke: 1pt, inset: 8pt, fill: blue.lighten(90%))[Переопределение TTL (3600с) + Запись в Redis],
        sym.arrow.b,
        [Отправка ответа клиенту],
      )
    ]
  ]
]

= Реализация

== Подготовка и DNSSEC (Неделя 1)

#slide[
  #set text(size: 14pt)
  #side-by-side[
    ```conf
    server:
        # Работа с кэшем
        prefetch: yes
        prefetch-key: yes
        cache-min-ttl: 330

        # Безопасность
        module-config: "validator iterator"
        auto-trust-anchor-file: "...root.key"

        # Мониторинг
        extended-statistics: yes
    ```
  ][
    1. *Prefetch:* Обновление популярных записей до их истечения.
    2. *Validator:* Обязательный модуль для работы DNSSEC.
    3. *Min-TTL:* Исключение слишком частых запросов к апстриму.
    4. *Statistics:* Сбор данных о вытеснении (eviction) для анализа лимитов.
  ]
]

== Кэширование и Лимиты (Неделя 2)

#slide[
  #set text(size: 13pt)
  #side-by-side[
  ```conf
  # unbound.conf
  server:
      verbosity: 3
      prefetch: yes         # Фоновое обновление
      prefetch-key: yes     # Обновление ключей
      cache-min-ttl: 330    # Минимум 5.5 минут
      
      module-config: "validator iterator"
      auto-trust-anchor-file: "...root.key"
      extended-statistics: yes 
  ```
  ][
  1. *Failsafe:* запуск через `systemd` внутри контейнера (ADR-002).
  2. *Healthcheck:* авто-проверка доступности порта 53 через `dig`.
  3. *Validator:* обязательная рекурсивная проверка DNSSEC.
  4. *Prefetch:* обновление популярных записей при TTL < 10%.
  ]
]

== Внешний кэш и Proxy (Неделя 3)

#slide[
  #set text(size: 13pt)
  #side-by-side[
    ```python
    # proxy/main.py
    
    # Проверка наличия в Redis
    if (cached := r.get(key)):
        resp = dns.message.from_wire(cached)
        return resp
        
    # MISS: Запрос к Unbound
    resp = dns.query.udp(query, IP, 53)
    
    # Переопределение TTL
    for rrset in resp.answer:
        rrset.ttl = 3600
        
    # Запись ответа в Redis
    r.setex(key, 3600, resp.to_wire())
    ```
  ][
  1. *Redis Integration:* вынос кэша в независимый контейнер.
  2. *TTL Override:* принудительное сохранение на 1 час (3600с).
  3. *Persistence:* кэш сохраняется даже после перезапуска Proxy.
  ]
]

= Управление зонами DNSSEC

== Механизм подмены (Неделя 4)

#slide[
  #set text(size: 13pt)
  #side-by-side[
  ```conf
  # local-zones.conf
  server:
      # Захват зоны isc.org
      local-zone: "isc.org." redirect
      
      # Подменные данные (A, SOA, NS)
      local-data: "isc.org. 3600 IN A 192.0.2.0"
      
      # Обход DNSSEC (Критично!)
      domain-insecure: "isc.org."
  ```
  ][
  1. *Redirect:* перехват всех запросов зоны.
  2. *Domain-insecure:* ручное исключение из валидации для обхода подписи.
  3. *AA-флаг:* резолвер выступает авторитетом для подмененных данных.
  ]
]

== Почему не сетевой перехват? (ADR-006)

#slide[
  #side-by-side[
    *Сложность сетевого уровня:*
    - Не видит контента (только "конверты").
    - Невозможен обход DNSSEC.
    - Требует опасных прав `NET_ADMIN`.
  ][
    *Наш выбор (Unbound):*
    - *Нативно:* понимает структуру DNS.
    - *Безопасно:* чистая конфигурация.
    - *Гибко:* управление TTL.
  ]
  
  #v(0.5em)
  *Аналогия:* Вместо перехвата писем на дороге (сложно и незаконно), мы договорились с почтальоном выдавать нужный адрес.
]

= Итоги

== Технические результаты

#set text(size: 13pt)
- *Безопасность (DNSSEC):* Стабильная рекурсивная валидация, флаг `ad`. Реализован обход проверки для подлежщих спуфингу зон (`domain-insecure`).
- *Производительность (Prefetch):* Механизм фонового обновления подтвержден ростом счетчика `total.num.prefetch` и обновлением записей при TTL < 10%.
- *Управление кэшем (Eviction):* Экспериментально подтверждено вытеснение записей при достижении лимита памяти (~540 КБ / 1500 уникальных запросов).
- *Redis-интеграция:* Внешний кэш обеспечивает персистентность. Подтвержден режим `HIT` без обращения к Unbound и переопределение TTL до 1 часа.
- *Гибкость:* Реализовано динамическое управление TTL (режимы `respect`, `override`, `min`) и нативная подмена через `local-zone` (AA-флаг).

== Список литературы

#set text(size: 13pt)
+ Команда 5, *SAMT: DNS Cacher (Source Code)*. [Электронный ресурс]. Доступно: https://github.com/hpc-moment/dns-cacher
+ П. Альбитц, К. Ли, *DNS и BIND. Руководство для системных администраторов*. [Электронный ресурс]. Доступно: https://disnetern.ru/wp-content/uploads/2016/11/DNS_BIND.pdf
+ RIPE NCC, *RIPE Database Documentation*. [Электронный ресурс]. Доступно: https://apps.db.ripe.net/docs/
+ P. Hoffman, P. McManus, *RFC 8484: DNS Queries over HTTPS (DoH)*. [Электронный ресурс]. Доступно: https://www.rfc-editor.org/rfc/rfc8484
+ ICANN, *Regional Internet Registry*. [Электронный ресурс]. Доступно: https://icannwiki.org/Regional_Internet_Registry
+ P. Hoffman, *RFC 9364: DNS Security Extensions (DNSSEC)*. [Электронный ресурс]. Доступно: https://datatracker.ietf.org/doc/html/rfc9364
+ Internet Systems Consortium, *BIND 9 Administrator Reference Manual*. [Электронный ресурс]. Доступно: https://www.isc.org/bind/
+ NLnet Labs, *Unbound DNS Resolver Documentation*. [Электронный ресурс]. Доступно: https://nlnetlabs.nl/projects/unbound/about/
+ PowerDNS.COM BV, *PowerDNS Authoritative Server and Recursor*. [Электронный ресурс]. Доступно: https://www.powerdns.com/


#focus-slide[
  Спасибо за внимание!
]
