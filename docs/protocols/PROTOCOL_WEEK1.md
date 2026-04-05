## Week 1. Foundation

### W1-01. Развертывание лабораторного стенда
**Цель:** подтвердить, что стенд развёрнут в Docker Compose и использует сеть `dns-lab` с подсетью `10.10.0.0/24`.
**Артефакты:** `docker-compose.yml`, `docs/logs/week1/01_docker_compose_ps.txt`, `docs/logs/week1/02_docker_network_inspect.json`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-02. Установка и запуск Unbound
**Цель:** подтвердить, что контейнер `dns-resolver` запущен, systemd работает, сервис unbound активен.
**Артефакты:** `Dockerfile`, `docs/logs/week1/03_systemd_state.txt`, `docs/logs/week1/04_unbound_status.txt`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-03. Проверка версии Unbound и модульной поддержки
**Цель:** подтвердить версию Unbound и наличие linked modules.
**Артефакты:** `docs/logs/week1/05_unbound_version.txt`, `docs/logs/week1/06_unbound_modules.txt`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-04. Проверка конфигурации Unbound
**Цель:** подтвердить корректность `unbound.conf`, bind-mount и базовые параметры резолвера.
**Артефакты:** `unbound.conf`, `docs/logs/week1/07_unbound_checkconf.txt`, `docs/logs/week1/08_unbound_conf_key_lines.txt`, `docs/logs/week1/09_unbound_conf_hash_match.txt`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-05. Проверка DNSSEC-валидации
**Цель:** подтвердить, что резолвер выполняет DNSSEC-валидацию для `yandex.ru` и возвращает ответ с флагом `AD`.
**Артефакты:** `docs/logs/week1/10_dig_yandex_ru_dnssec.txt`, `docs/logs/week1/11_dns_resolver_logs.txt`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-06. Установка и запуск Redis
**Цель:** подтвердить, что Redis установлен, контейнер запущен и отвечает на PING.
**Артефакты:** `docs/logs/week1/12_redis_version.txt`, `docs/logs/week1/13_redis_ping.txt`, `docs/logs/week1/14_dns_cache_inspect.json`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-07. Проверка RedisInsight
**Цель:** подтвердить наличие наблюдаемости по Redis через web UI.
**Артефакты:** `docs/logs/week1/15_redis_webui_status.txt`, `docs/screenshots/week1/05_redis_install/02_redisinsight_ui.png`
**Статус:** DONE
**Официальные баллы:** не предусмотрены

### W1-08. Подготовка документационного каркаса
**Цель:** создать структуру папок, test-plan, checklist и протокол Week 1.
**Артефакты:** `docs/README.md`, `docs/TEST_PLAN.md`, `docs/CHECKLIST.md`, `docs/protocols/PROTOCOL_WEEK1.md`
**Статус:** DONE
**Официальные баллы:** не предусмотрены