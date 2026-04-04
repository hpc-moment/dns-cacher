#!/bin/sh

echo "=== Проверка DNSSEC через публичный валидирующий резолвер ==="
echo ""

for DOMAIN in nic.ru bank.ru gosuslugi.ru cloudflare.com isc.org; do

    # Метод 1: проверяем DNSKEY в самой зоне (через доверенный резолвер)
    DNSKEY=$(dig $DOMAIN DNSKEY +short @1.1.1.1 2>/dev/null | head -1)

    # Метод 2: проверяем AD-флаг (Authenticated Data) — резолвер подтвердил DNSSEC
    AD_FLAG=$(dig $DOMAIN A @1.1.1.1 +dnssec 2>/dev/null | grep -c "flags:.*ad")

    # Метод 3: DS в родительской зоне (копаем через корневые серверы)
    PARENT_DS=$(dig $DOMAIN DS +short @[jg:ip_address_40] 2>/dev/null | head -1)
    # где [jg:ip_address_41] — один из корневых серверов для .ru или .com

    if [ -n "$DNSKEY" ] || [ "$AD_FLAG" -gt 0 ]; then
        echo "✅ $DOMAIN — DNSSEC активен"
        echo "   DNSKEY: $(echo $DNSKEY | cut -c1-60)..."
        echo "   AD-флаг: $AD_FLAG"
    else
        echo "❌ $DOMAIN — DNSSEC не подтверждён"
    fi
    echo ""
done
