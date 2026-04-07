# Шаг 5.8: Полная сравнительная таблица для протокола
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Верификация: авторитетный сервер vs наш резолвер (Redis data) ║"
echo "╠══════════════════════════════════════════════════════════════════╣"

for TYPE in A AAAA NS MX TXT; do
    AUTH=$(dig isc.org $TYPE @ns2.isc.org +short 2>/dev/null | head -2)
    LOCAL=$(dig isc.org $TYPE @127.0.0.1 +short 2>/dev/null | head -2)
    echo ""
    echo "  Тип $TYPE:"
    echo "    Авторитетный: $AUTH"
    echo "    Наш резолвер: $LOCAL"
done

echo ""
echo "  TTL сравнение (A-запись):"
echo "    DNS TTL (от авторитетного): $(dig isc.org A @ns2.isc.org | grep 'IN A' | awk '{print $2}')s"
echo "    Redis TTL (управляемый):    $(redis-cli TTL dns:isc.org:A)s"
echo "╚══════════════════════════════════════════════════════════════════╝"
