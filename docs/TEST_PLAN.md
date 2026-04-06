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

### 1.1.A Проверка стандартного TTL-кэширования
**Статус:** DONE
**Баллы:** 5 / 5

### 1.1.Б Проверка prefetch
**Статус:** DONE
**Баллы:** 5 / 5

### 1.1.В Принудительный min/max TTL
**Статус:** DONE
**Баллы:** 5 / 5

### 1.1.Г Вытеснение записей из кэша при ограниченном размере
**Статус:** DONE
**Баллы:** 10 / 10

---

## Week 3. External Redis cache

### 1.2.А Подключение внешнего Redis-кэша
**Статус:** TODO

### 1.2.Б Проверка механизма кэширования через Redis
**Статус:** TODO

### 1.2.В Реализация ответов из Redis
**Статус:** TODO

### 1.2.Г Настройка кастомного времени хранения в Redis
**Статус:** TODO

---

## Week 4. DNSSEC bypass

### 1.3.А Выбор и локальное размещение DNSSEC-зоны
**Статус:** TODO

### 1.3.Б Настройка ответов по зоне из локального описания
**Статус:** TODO

### 1.3.В Сбор данных по зоне и создание zone-file
**Статус:** TODO

### 1.3.Г Демонстрация ответов из локальной базы резолвера
**Статус:** TODO