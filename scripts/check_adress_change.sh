# Шаг 4.4: Сравнительная таблица — запрос к upstream vs к нашему резолверу
echo "=== Реальный IP isc.org (авторитетный сервер) ==="
dig isc.org A @ns1.isc.org +short

echo ""
echo "=== Подменный IP isc.org (наш резолвер) ==="
dig isc.org A @127.0.0.1 +short

echo ""
echo "=== Разница в флагах ==="
echo "Публичный резолвер 8.8.8.8 (с DNSSEC):"
dig isc.org A @8.8.8.8 +dnssec | grep "flags:"

echo "Наш резолвер (локальная зона):"
dig isc.org A @127.0.0.1 +dnssec | grep "flags:"
