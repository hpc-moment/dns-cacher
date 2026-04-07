# Local zones collector

Написан скрипт, запускаемый в контейнере, позволяющий собирать информацию о доменной зоне
в формате RFC 1035.

# Options

Скрипт поддерживает несколько опций запуска, с помощью env переменных:
1. `TTL_MODE=respect` - оставить upstream TTL, не изменяя. Среди одинаковых доменов, оставить минимальный TTL.
2. `TTL_MODE=override` - насильно поставить TTL из переменной среды `TTL_OVERRIDE`
3. `TTL_MODE=min` - ограничить TTL снизу. При TTL в upstream меньше `TTL_MIN`, выставляется `TTL_MIN`, иначе upstream.

# Results

После получения скриптом файла `local-zones.conf`, он был проверен с помощью `unbound-checkconf`:

```shell
root@450a8bcae5a7:/# unbound-checkconf
unbound-checkconf: no errors in /etc/unbound/unbound.conf
```

# Examples

Примеры работы во всех режимах:
`TTL_MODE=override`:

```shell
server:

local-zone: "isc.org." transparent
domain-insecure: "isc.org."

local-data: "isc.org. 3600 IN A 151.101.130.217"
local-data: "isc.org. 3600 IN A 151.101.194.217"
local-data: "isc.org. 3600 IN A 151.101.2.217"
local-data: "isc.org. 3600 IN A 151.101.66.217"
local-data: "isc.org. 3600 IN AAAA 2a04:4e42:200::729"
local-data: "isc.org. 3600 IN AAAA 2a04:4e42:400::729"
local-data: "isc.org. 3600 IN AAAA 2a04:4e42:600::729"
local-data: "isc.org. 3600 IN AAAA 2a04:4e42::729"
local-data: "isc.org. 3600 IN MX 10 mx.ams1.isc.org."
local-data: "isc.org. 3600 IN MX 5 mx.pao1.isc.org."
local-data: "isc.org. 3600 IN NS ns.isc.afilias-nst.info."
local-data: "isc.org. 3600 IN NS ns1.isc.org."
local-data: "isc.org. 3600 IN NS ns2.isc.org."
local-data: "isc.org. 3600 IN NS ns3.isc.org."
local-data: "isc.org. 3600 IN NS nsp.dnsnode.net."
local-data: "isc.org. 3600 IN SOA ns-int.isc.org. hostmaster.isc.org. 2026040201 7200 3600 24796800 3600"
local-data: "mx.ams1.isc.org. 3600 IN A 199.6.1.65"
local-data: "mx.ams1.isc.org. 3600 IN AAAA 2001:500:60::65"
local-data: "mx.pao1.isc.org. 3600 IN A 149.20.2.50"
local-data: "mx.pao1.isc.org. 3600 IN AAAA 2001:500:6b:2::50"
local-data: "ns.isc.afilias-nst.info. 3600 IN A 199.254.63.254"
local-data: "ns.isc.afilias-nst.info. 3600 IN AAAA 2001:500:2c::254"
local-data: "ns1.isc.org. 3600 IN A 149.20.2.26"
local-data: "ns1.isc.org. 3600 IN AAAA 2001:500:6b:2::26"
local-data: "ns2.isc.org. 3600 IN A 199.6.1.52"
local-data: "ns2.isc.org. 3600 IN AAAA 2001:500:60:d::52"
local-data: "ns3.isc.org. 3600 IN A 51.75.79.143"
local-data: "ns3.isc.org. 3600 IN AAAA 2001:41d0:701:1100::2c92"
local-data: "nsp.dnsnode.net. 3600 IN A 194.58.198.32"
local-data: "nsp.dnsnode.net. 3600 IN AAAA 2a01:3f1:3032::53"
```

`TTL_MODE=respect`:

```shell
server:

local-zone: "isc.org." transparent
domain-insecure: "isc.org."

local-data: "isc.org. 168 IN A 151.101.130.217"
local-data: "isc.org. 168 IN A 151.101.194.217"
local-data: "isc.org. 168 IN A 151.101.2.217"
local-data: "isc.org. 168 IN A 151.101.66.217"
local-data: "isc.org. 168 IN AAAA 2a04:4e42:200::729"
local-data: "isc.org. 168 IN AAAA 2a04:4e42:400::729"
local-data: "isc.org. 168 IN AAAA 2a04:4e42:600::729"
local-data: "isc.org. 168 IN AAAA 2a04:4e42::729"
local-data: "isc.org. 168 IN MX 10 mx.ams1.isc.org."
local-data: "isc.org. 168 IN MX 5 mx.pao1.isc.org."
local-data: "isc.org. 7068 IN NS ns.isc.afilias-nst.info."
local-data: "isc.org. 7068 IN NS ns1.isc.org."
local-data: "isc.org. 7068 IN NS ns2.isc.org."
local-data: "isc.org. 7068 IN NS ns3.isc.org."
local-data: "isc.org. 7068 IN NS nsp.dnsnode.net."
local-data: "isc.org. 7068 IN SOA ns-int.isc.org. hostmaster.isc.org. 2026040201 7200 3600 24796800 3600"
local-data: "mx.ams1.isc.org. 7069 IN A 199.6.1.65"
local-data: "mx.ams1.isc.org. 7069 IN AAAA 2001:500:60::65"
local-data: "mx.pao1.isc.org. 7069 IN A 149.20.2.50"
local-data: "mx.pao1.isc.org. 7070 IN AAAA 2001:500:6b:2::50"
local-data: "ns.isc.afilias-nst.info. 770 IN A 199.254.63.254"
local-data: "ns.isc.afilias-nst.info. 770 IN AAAA 2001:500:2c::254"
local-data: "ns1.isc.org. 7070 IN A 149.20.2.26"
local-data: "ns1.isc.org. 7070 IN AAAA 2001:500:6b:2::26"
local-data: "ns2.isc.org. 7071 IN A 199.6.1.52"
local-data: "ns2.isc.org. 7071 IN AAAA 2001:500:60:d::52"
local-data: "ns3.isc.org. 7069 IN A 51.75.79.143"
local-data: "ns3.isc.org. 7069 IN AAAA 2001:41d0:701:1100::2c92"
local-data: "nsp.dnsnode.net. 4574 IN A 194.58.198.32"
local-data: "nsp.dnsnode.net. 7071 IN AAAA 2a01:3f1:3032::53"
```

`TTL_MODE=min`:

```shell
server:

local-zone: "isc.org." transparent
domain-insecure: "isc.org."

local-data: "isc.org. 300 IN A 151.101.130.217"
local-data: "isc.org. 300 IN A 151.101.194.217"
local-data: "isc.org. 300 IN A 151.101.2.217"
local-data: "isc.org. 300 IN A 151.101.66.217"
local-data: "isc.org. 300 IN AAAA 2a04:4e42:200::729"
local-data: "isc.org. 300 IN AAAA 2a04:4e42:400::729"
local-data: "isc.org. 300 IN AAAA 2a04:4e42:600::729"
local-data: "isc.org. 300 IN AAAA 2a04:4e42::729"
local-data: "isc.org. 300 IN MX 10 mx.ams1.isc.org."
local-data: "isc.org. 300 IN MX 5 mx.pao1.isc.org."
local-data: "isc.org. 7059 IN NS ns.isc.afilias-nst.info."
local-data: "isc.org. 7059 IN NS ns1.isc.org."
local-data: "isc.org. 7059 IN NS ns2.isc.org."
local-data: "isc.org. 7059 IN NS ns3.isc.org."
local-data: "isc.org. 7059 IN NS nsp.dnsnode.net."
local-data: "isc.org. 7060 IN SOA ns-int.isc.org. hostmaster.isc.org. 2026040201 7200 3600 24796800 3600"
local-data: "mx.ams1.isc.org. 7060 IN A 199.6.1.65"
local-data: "mx.ams1.isc.org. 7060 IN AAAA 2001:500:60::65"
local-data: "mx.pao1.isc.org. 7060 IN A 149.20.2.50"
local-data: "mx.pao1.isc.org. 7061 IN AAAA 2001:500:6b:2::50"
local-data: "ns.isc.afilias-nst.info. 761 IN A 199.254.63.254"
local-data: "ns.isc.afilias-nst.info. 761 IN AAAA 2001:500:2c::254"
local-data: "ns1.isc.org. 7061 IN A 149.20.2.26"
local-data: "ns1.isc.org. 7062 IN AAAA 2001:500:6b:2::26"
local-data: "ns2.isc.org. 7062 IN A 199.6.1.52"
local-data: "ns2.isc.org. 7062 IN AAAA 2001:500:60:d::52"
local-data: "ns3.isc.org. 7060 IN A 51.75.79.143"
local-data: "ns3.isc.org. 7060 IN AAAA 2001:41d0:701:1100::2c92"
local-data: "nsp.dnsnode.net. 4565 IN A 194.58.198.32"
local-data: "nsp.dnsnode.net. 7062 IN AAAA 2a01:3f1:3032::53"
```
