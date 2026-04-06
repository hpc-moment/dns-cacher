echo "=== Тест redirect для поддоменов isc.org ==="

for SUBDOMAIN in www ftp mail dl; do
    RESULT=$(dig @127.0.0.1 ${SUBDOMAIN}.isc.org A +short)
    echo "${SUBDOMAIN}.isc.org → ${RESULT}"
done