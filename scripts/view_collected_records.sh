# Сводный просмотр собранных данных
echo "=== Собранные файлы ==="
ls -la /tmp/zone-collection/isc.org/

echo ""
echo "=== A-записи isc.org ==="
cat /tmp/zone-collection/isc.org/isc.org_A.txt

echo ""
echo "=== MX-записи isc.org ==="
cat /tmp/zone-collection/isc.org/isc.org_MX.txt

echo ""
echo "=== TXT-записи isc.org (SPF и др.) ==="
cat /tmp/zone-collection/isc.org/isc.org_TXT.txt

echo ""
echo "=== DNSKEY isc.org ==="
cat /tmp/zone-collection/isc.org/isc.org_DNSKEY.txt
