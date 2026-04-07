# TEST_PLAN

## Статусы
- TODO — не начато
- IN_PROGRESS — в работе
- DONE — выполнено и подтверждено артефактами
- BLOCKED — выполнение заблокировано

---

## Week 1. Foundation

### W1-01. Развертывание лабораторного стенда
**Цель:** подтвердить, что стенд развёрнут в Docker Compose и использует сеть `dns-lab` с подсетью `10.10.0.0/24`.  
**Артефакты:** `docker-compose.yml`, `docs/logs/week1/01_docker_compose_ps.txt`, `docs/logs/week1/02_docker_network_inspect.json`  
**Статус:** DONE

### W1-02. Установка и запуск Unbound
**Цель:** подтвердить, что контейнер `dns-resolver` запущен, systemd работает, сервис unbound активен.  
**Артефакты:** `Dockerfile`, `docs/logs/week1/04_systemd_state.txt`, `docs/logs/week1/05_unbound_status.txt`  
**Статус:** DONE

### W1-03. Проверка версии Unbound и модульной поддержки
**Цель:** подтвердить версию Unbound и наличие linked modules.  
**Артефакты:** `docs/logs/week1/06_unbound_version.txt`, `docs/logs/week1/07_unbound_modules.txt`  
**Статус:** DONE

### W1-04. Проверка конфигурации Unbound
**Цель:** подтвердить корректность `unbound.conf`, bind-mount и базовые параметры резолвера.  
**Артефакты:** `unbound.conf`, `docs/logs/week1/08_unbound_checkconf.txt`, `docs/logs/week1/09_unbound_conf_hash_match.txt`  
**Статус:** DONE

### W1-05. Проверка DNSSEC-валидации
**Цель:** подтвердить, что резолвер выполняет DNSSEC-валидацию.  
**Артефакты:** `docs/logs/week1/10_dig_example_com_dnssec.txt`, `docs/logs/week1/11_dns_resolver_logs.txt`  
**Статус:** DONE

### W1-06. Установка и запуск Redis
**Цель:** подтвердить, что Redis установлен, контейнер запущен и отвечает на PING.  
**Артефакты:** `docs/logs/week1/12_redis_version.txt`, `docs/logs/week1/13_redis_ping.txt`, `docs/logs/week1/14_dns_cache_inspect.json`  
**Статус:** DONE

### W1-07. Проверка RedisInsight
**Цель:** подтвердить наличие наблюдаемости по Redis через web UI.  
**Артефакты:** `docs/screenshots/week1/05_redis_install/01_redisinsight_key_ttl.png`, `task6/README.md`  
**Статус:** DONE

### W1-08. Подготовка документационного каркаса
**Цель:** создать структуру папок, test-plan, checklist и протокол Week 1.  
**Артефакты:** `docs/README.md`, `docs/TEST_PLAN.md`, `docs/CHECKLIST.md`, `docs/protocols/PROTOCOL_WEEK1.md`  
**Статус:** DONE

---

## Week 2. Standard cache experiments

### W2-01. 1.1.А Проверка стандартного TTL-кэширования
**Цель:** подтвердить, что TTL записи `yandex.ru` в кэше Unbound убывает между двумя последовательными запросами.
**Артефакты:** `docs/logs/week2/...` с первым и вторым запросом, `docs/screenshots/week2/...`
**Статус:** DONE
**Официальные баллы:** 5 / 5

### W2-02. 1.1.Б Проверка prefetch
**Цель:** подтвердить срабатывание prefetch при снижении TTL ниже порогового значения.
**Артефакты:** лог prefetch, статистика `unbound-control`, скриншот `docs/screenshots/week2/...`
**Статус:** DONE
**Официальные баллы:** 5 / 5

### W2-03. 1.1.В Принудительный min/max TTL
**Цель:** подтвердить, что локальный резолвер повышает TTL записи выше исходного TTL апстрима.
**Артефакты:** лог `api.telegram.org` через `8.8.8.8` и через `@127.0.0.1`, скриншот `docs/screenshots/week2/...`
**Статус:** DONE
**Официальные баллы:** 5 / 5

### W2-04. 1.1.Г Вытеснение записей из кэша при ограниченном размере
**Цель:** подтвердить вытеснение ранее закэшированной записи при малом размере кэша и массовом заполнении.
**Артефакты:** лог `fill_cache.sh`, `unbound-control stats`, скриншот `docs/screenshots/week2/...`
**Статус:** DONE
**Официальные баллы:** 10 / 10

**Итог Week 2:** `25 / 25`

---

## Week 3. External Redis cache

### W3-01. 1.2.А Подключение внешнего Redis-кэша
**Цель:** подтвердить, что DNS-ответы сохраняются во внешний Redis-кэш.
**Артефакты:** лог первого запроса через `5300`, ключ Redis, TTL, скриншот `docs/screenshots/week3/...`
**Статус:** DONE
**Официальные баллы:** 10 / 10

### W3-02. 1.2.Б Проверка механизма кэширования через Redis
**Цель:** подтвердить последовательность `MISS -> HIT` и корректный клиентский ответ через прокси.
**Артефакты:** логи `dns-proxy`, TTL ключа в Redis, скриншот `docs/screenshots/week3/...`
**Статус:** DONE
**Официальные баллы:** 5 / 5

### W3-03. 1.2.В Реализация ответов из Redis
**Цель:** подтвердить, что повторный ответ выдаётся из Redis без повторного обращения к локальному резолверу.
**Артефакты:** лог очистки ключей, первый и второй запрос, журнал Unbound, скриншот `docs/screenshots/week3/...`
**Статус:** DONE
**Официальные баллы:** 10 / 10

### W3-04. 1.2.Г Настройка кастомного времени хранения в Redis
**Цель:** подтвердить, что TTL через прокси отличается от исходного TTL локального резолвера.
**Артефакты:** прямой запрос к Unbound, запрос через `5300`, TTL Redis-ключа, скриншот `docs/screenshots/week3/...`
**Статус:** DONE
**Официальные баллы:** 10 / 10

**Итог Week 3:** `35 / 35`

---

## Week 4. DNSSEC bypass

### W4-01. 1.3.А Выбор и локальное размещение DNSSEC-зоны
**Цель:** подтвердить, что выбрана DNSSEC-зона `isc.org`, и её локальное описание подключено в Unbound.  
**Артефакты:** `docs/logs/week4/01_1_3_A_zone_selection_and_local_zone_retest.txt`, `docs/screenshots/week4/01_1_3_A_*.jpg`  
**Статус:** DONE  
**Баллы:** 5 / 5

### W4-02. 1.3.Б Настройка ответов по зоне из локального описания
**Цель:** подтвердить, что `isc.org` и его поддомены обслуживаются локальной зоной и возвращают подменный IP.  
**Артефакты:** `docs/logs/week4/02_1_3_B_local_zone_priority_retest.txt`, `docs/screenshots/week4/02_1_3_B_*.jpg`  
**Статус:** DONE  
**Баллы:** 5 / 5

### W4-03. 1.3.В Сбор данных по зоне и создание zone-file
**Цель:** подтвердить сбор реальных записей зоны `isc.org` и генерацию локального описания зоны для Unbound.  
**Артефакты:** `docs/logs/week4/03_1_3_V_collect_records_by_type.txt`, `docs/logs/week4/04_1_3_V_view_collected_records.txt`, `docs/logs/week4/05_1_3_V_zone_collector_override.txt`, `docs/logs/week4/06_1_3_V_generated_local_zone_check.txt`, `docs/screenshots/week4/03_1_3_V_*.jpg`  
**Статус:** DONE  
**Баллы:** 10 / 10

### W4-04. 1.3.Г Демонстрация ответов из локальной базы резолвера
**Цель:** подтвердить, что ответы по `isc.org` выдаются из локальной базы без обращения к апстриму.  
**Артефакты:** `docs/logs/week4/07_1_3_G_local_vs_public_answer.txt`, `docs/logs/week4/08_1_3_G_stats_check.txt`, `docs/logs/week4/09_1_3_G_unbound_logs_before_after.txt`, `docs/screenshots/week4/04_1_3_G_*.jpg`  
**Статус:** DONE 
**Баллы:** 5 / 5

**Итог Week 4:** `25 / 25`
