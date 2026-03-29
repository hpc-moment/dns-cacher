# Скрипт массового заполнения кэша
# Генерируем запросы к уникальным поддоменам существующих зон
# (NXDOMAIN тоже кэшируются и занимают место!)

RESOLVER="127.0.0.1"
COUNT=0

echo "Начало заполнения кэша: $(date)"
echo "Размер кэша до: $(unbound-control stats_noreset | grep mem.cache.message)"

for i in $(seq 1 10000); do
    # Генерируем уникальные поддомены — они дадут NXDOMAIN,
    # но каждый займёт место в кэше
    DOMAIN="test-eviction-${i}-$(date +%s).example.com"
    dig "@$RESOLVER" "$DOMAIN" A +time=1 +tries=1 >/dev/null 2>&1

    COUNT=$((COUNT + 1))

    if [ $((COUNT % 500)) -eq 0 ]; then
        echo "=== Запросов: $COUNT, Время: $(date '+%H:%M:%S') ==="
        unbound-control stats_noreset | grep -E "mem\.cache|num\.cache"

        # grep -c всегда печатает число (0 если не найдено), поэтому || echo "0" не нужен
        YANDEX_IN_CACHE="$(unbound-control dump_cache 2>/dev/null | grep -c 'yandex\.ru')"
        echo "yandex.ru в кэше: $YANDEX_IN_CACHE записей"

        if [ "$YANDEX_IN_CACHE" -eq 0 ]; then
            echo "!!! EVICTION ОБНАРУЖЕН: yandex.ru вытеснен из кэша! Запросов: $COUNT"
            break
        fi
    fi
done

echo "Размер кэша после: $(unbound-control stats_noreset | grep mem.cache.message)"
