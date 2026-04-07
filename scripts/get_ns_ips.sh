# Получить IP-адреса NS-серверов
for NS in $(dig isc.org NS +short); do
    echo "NS: $NS"
    dig $NS A +short
    dig $NS AAAA +short
    echo "---"
done