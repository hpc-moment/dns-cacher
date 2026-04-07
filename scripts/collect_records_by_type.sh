# Создать директорию для собранных данных
mkdir -p /tmp/zone-collection/isc.org
cd /tmp/zone-collection/isc.org

# Список типов записей для сбора
RECORD_TYPES="A AAAA NS MX SOA TXT CAA DNSKEY DS RRSIG NSEC3PARAM SRV"
NS_SERVER="ns1.isc.org"
DOMAIN="isc.org"

# Сбор записей для зоны (isc.org)
echo "=== Сбор записей для apex зоны $DOMAIN ==="
for TYPE in $RECORD_TYPES; do
    echo "Запрос: $DOMAIN $TYPE"
    dig $DOMAIN $TYPE @$NS_SERVER +dnssec +multiline \
        > "${DOMAIN}_${TYPE}.txt" 2>&1
    # Небольшая пауза чтобы не перегружать NS-сервер
    sleep 0.5
done

# Сбор записей для известных поддоменов
SUBDOMAINS="www ftp mail dl lists www.lists"
for SUB in $SUBDOMAINS; do
    FQDN="${SUB}.${DOMAIN}"
    echo "Запрос поддомена: $FQDN"
    for TYPE in A AAAA CNAME MX TXT; do
        dig $FQDN $TYPE @$NS_SERVER +dnssec \
            > "${FQDN//./_}_${TYPE}.txt" 2>&1
        sleep 0.3
    done
done
