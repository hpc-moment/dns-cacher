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
#set text(size: 20pt, lang: "ru") // Установка языка для авто-заголовков
#set par(leading: 0.8em) // Межстрочный интервал (возврат к разумному значению)
#show heading: it => it + v(0.5em) // Отступ после заголовка (возврат к разумному значению)

#title-slide()

== Содержание

#set text(size: 13pt)
#outline(title: [Содержание], indent: 1em)

= Техническое задание и задачи

== Описание кейса

Проект реализует гибкую DNS-инфраструктуру для решения ограничений стандартных систем:
- *Управление временем жизни (TTL):* переопределение политик хранения записей.
- *Внешнее кэширование:* вынос данных в Redis для масштабируемости.
- *Управление зонами DNSSEC:* механизмы подмены данных в подписанных зонах.

== Ключевые технические цели

1. Рекурсивная валидация DNSSEC (флаг `ad`).
2. Упреждающее кэширование (Prefetch) и анализ вытеснения.
3. Разработка Proxy-посредника для интеграции с Redis.
4. Подмена записей в локальных зонах (Spoofing) с обходом валидатора.

= Архитектура системы

== Архитектурные решения (ADR)

#set text(size: 14pt)
#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt,
  inset: 5pt,
  fill: (x, y) => if y == 0 { gray.lighten(80%) },
  [*ID*], [*Название решения*], [*Статус*],
  [ADR-001], [Отказ от BIND9 в пользу Unbound], [Отклонено],
  [ADR-002], [Контейнеризация Unbound через Systemd], [Принято],
  [ADR-003], [Базовая конфигурация сети и безопасности], [Принято],
  [ADR-004], [Стратегии кэширования и мониторинг], [Принято],
  [ADR-005], [Разработка Python DNS-прокси с Redis], [Принято],
  [ADR-006], [Использование iptables DNAT для подмены], [Отклонено],
  [ADR-007], [Реализация Spoofing и политик TTL], [Принято],
)

== Стек технологий

- *Резолвер:* Unbound 1.13.1 (модульность, Python-интеграция).
- *Хранилище:* Redis 7.4 (внешний кэш).
- *Разработка:* Python 3.9 + `dnspython`.
- *Среда:* Docker & Docker Compose.
- *Инструменты:* `unbound-control`, `dig`, `redis-cli`.

== Схема взаимодействия компонентов

#slide[
  #align(center + horizon)[
    #box(width: 95%)[
      #set text(size: 14pt)
      #stack(
        dir: ltr,
        spacing: 1fr,
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [Клиент]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt)[Браузер / dig],
        ),
        sym.arrow.r,
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [Прокси (53)]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: blue.lighten(92%))[Python (UDP)],
        ),
        sym.arrow.r,
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [Хранилище]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: red.lighten(92%), width: 7em)[Redis],
        ),
        sym.arrow.r,
        stack(
          dir: ttb,
          spacing: 0.5em,
          align(center, [Резолвер]),
          block(stroke: 1pt, inset: 8pt, radius: 4pt, fill: green.lighten(92%), width: 7em)[Unbound],
        ),
        sym.arrow.r,
        stack(dir: ttb, spacing: 0.5em, align(center, [Сеть]), block(stroke: 1pt, inset: 8pt, radius: 4pt)[Интернет]),
      )

      #v(0.8em)
      #align(left)[
        *Инфраструктурная роль:* proxy на python - это точка входа, изолирующая клиентские запросы от логики рекурсивного резолвинга и базы данных.
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
    - Развернута сеть `dns-lab`.
    - Подтверждена валидация DNSSEC (флаг `ad`).
    - Модульная поддержка Unbound (python, validator).
  ][
    #image("screenshots/week1/unbound_service_active.jpg", height: 90%)
    #align(center)[_Служба Unbound активна_]
  ]
]

== Кэширование и Лимиты (Неделя 2)

#slide[
  #set text(size: 14pt)
  #side-by-side[
    - `prefetch: yes` (фоновый префетчинг).
    - Стресс-тест `fill_cache.sh`.
    - Фиксация вытеснения (`eviction`).
  ][
    #image("screenshots/week2/eviction_run_3.jpg", height: 90%)
    #align(center)[_Процесс вытеснения записей_]
  ]
]

== Внешний кэш и Proxy (Неделя 3)

#slide[
  #set text(size: 14pt)
  #side-by-side[
    - Интеграция с Redis.
    - Переопределение TTL на 3600с.
    - Логирование MISS/HIT переходов.
  ][
    ```python
    # MISS: Запрос к Unbound
    # и переопределение TTL
    resp = dns.query.udp(query,
           UNBOUND_IP, port=53)
    for rrset in resp.answer:
        rrset.ttl = 3600
    r.setex(key, 3600,
        resp.to_wire())
    ```
    #align(center)[_Фрагмент логики прокси_]
  ]
]

= Управление зонами DNSSEC

== Механизм подмены (ADR-007)

#set text(size: 16pt)
*Проблема:* DNSSEC блокирует изменение данных (`SERVFAIL`).

*Техническое решение:*
1. Резолвер — "авторитет": `local-zone: "isc.org" redirect`.
2. Исключение из валидации: `domain-insecure: "isc.org"`.
3. Подмена IP: `local-data: "isc.org A 10.10.0.100"`.

== Обоснование выбора (ADR-006)

*Почему не iptables DNAT?*
- Высокая сложность управления UDP-сессиями.
- Проблемы с фрагментированными пакетами.
- Нативная подмена в Unbound проще в дебаге и конфигурации.

= Итоги

== Технические результаты

- Валидация DNSSEC работает (флаг `ad`).
- Спуфинг зон реализован без нарушения работы резолвера.
- Redis обеспечивает персистентность кэша.
- TTL переопределяется на 1 час (3600с).

// == Возможные вопросов

// #set text(size: 14pt)
// - *Актуальность кэша:* через `SETEX` в Redis (авто-удаление).
// - *Отказоустойчивость:* Proxy работает напрямую with Unbound при сбое Redis.
// - *Обход подписи:* `domain-insecure` помечает зону как доверенную без проверки ключей.

== Список литературы

#set text(size: 14pt)
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
