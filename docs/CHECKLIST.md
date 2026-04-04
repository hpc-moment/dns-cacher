# CHECKLIST

## Общие правила
- [ ] Для каждого выполненного пункта есть минимум один скриншот
- [ ] Для каждого выполненного пункта есть текстовый лог команды
- [ ] Для каждого выполненного пункта указаны входные условия
- [ ] Для каждого выполненного пункта указан ожидаемый результат
- [ ] Для каждого выполненного пункта указан фактический результат
- [ ] Все скриншоты имеют осмысленные имена
- [ ] Все скриншоты лежат в папке нужной недели
- [ ] Все логи лежат в `docs/logs/...`
- [ ] Все артефакты упомянуты в протоколе

## Week 1
- [x] Есть `docs/README.md`
- [x] Есть `docs/TEST_PLAN.md`
- [x] Есть `docs/CHECKLIST.md`
- [x] Есть `docs/protocols/PROTOCOL_WEEK1.md`
- [x] Созданы папки `docs/screenshots/week1/...`
- [x] Созданы папки `docs/logs/week1/...`
- [x] Сохранен `docker compose ps`
- [x] Сохранен `docker network inspect dns-lab`
- [x] Сохранен `systemctl is-system-running`
- [x] Сохранен `systemctl status unbound`
- [x] Сохранен `unbound -V`
- [x] Сохранен `unbound -V | grep "Linked modules"`
- [x] Сохранен `unbound-checkconf /etc/unbound/unbound.conf`
- [ ] Сохранен DNSSEC-запрос к `example.com`
- [x] Сохранены логи `docker logs dns-resolver`
- [x] Сохранена версия Redis
- [ ] Сохранен `redis-cli ping`
- [x] Есть скриншот RedisInsight
- [x] В протоколе Week 1 перечислены открытые риски и замечания