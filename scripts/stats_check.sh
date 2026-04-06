# Убедиться что запросы к isc.org не уходят к upstream
unbound-control stats_noreset > /tmp/stats_before.txt

# Выполнить несколько запросов к isc.org
for i in $(seq 1 10); do
    dig @127.0.0.1 isc.org A +short > /dev/null
    dig @127.0.0.1 www.isc.org A +short > /dev/null
done

unbound-control stats_noreset > /tmp/stats_after.txt

# Сравнить: num.cachemiss не должен расти для isc.org
echo "=== Изменение статистики после 20 запросов к isc.org ==="
diff /tmp/stats_before.txt /tmp/stats_after.txt | grep "^>"
