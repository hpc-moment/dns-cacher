import dns.resolver
import redis
import os
import sys

REDIS_HOST = "cache"
REDIS_PORT = 6379
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD")

RECORD_TYPES = ["A", "AAAA", "MX", "NS", "SOA"]

TTL_MODE = os.getenv("TTL_MODE", "respect")
TTL_MIN = int(os.getenv("TTL_MIN", "0"))
TTL_OVERRIDE = os.getenv("TTL_OVERRIDE")

r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    password=REDIS_PASSWORD,
    decode_responses=True
)

def fqdn(name):
    return name.rstrip(".") + "."

def apply_ttl_policy(ttl):
    if TTL_MODE == "override":
        return int(TTL_OVERRIDE)
    elif TTL_MODE == "min":
        return max(ttl, TTL_MIN)
    return ttl

def store_record(zone, name, rtype, ttl, value):
    key = f"zone:{zone}:{name}:{rtype}"

    ttl = apply_ttl_policy(ttl)

    if rtype == "SOA":
        r.set(key, value)
        r.set(f"{key}:ttl", ttl)
        return

    r.sadd(key, value)

    ttl_key = f"{key}:ttl"
    existing_ttl = r.get(ttl_key)

    if existing_ttl is None:
        r.set(ttl_key, ttl)
    else:
        existing_ttl = int(existing_ttl)

        if TTL_MODE == "override":
            ttl = int(TTL_OVERRIDE)
        elif TTL_MODE == "respect":
            ttl = min(existing_ttl, ttl)
        else:
            ttl = max(int(existing_ttl), ttl)

        r.set(ttl_key, ttl)

def resolve_and_store(resolver, zone, name, rtype):
    try:
        answers = resolver.resolve(fqdn(name), rtype)
        ttl = answers.rrset.ttl

        results = []
        for rdata in answers:
            value = rdata.to_text()
            store_record(zone, name, rtype, ttl, value)
            results.append(value)

        print(f"[OK] {name} {rtype}")
        return results

    except Exception as e:
        print(f"[MISS] {name} {rtype}: {e}")
        return []


def collect(zone):
    for key in r.keys(f"zone:{zone}:*"):
        r.delete(key)

    resolver = dns.resolver.Resolver()

    discovered_names = set([zone])

    for rtype in RECORD_TYPES:
        values = resolve_and_store(resolver, zone, zone, rtype)

        if rtype in ["MX", "NS"]:
            for v in values:
                parts = v.split()
                target = parts[-1].rstrip(".").lower()
                discovered_names.add(target)
    for name in discovered_names:
        resolve_and_store(resolver, zone, name, "A")
        resolve_and_store(resolver, zone, name, "AAAA")


def generate_config(zone, output_file="local-zones.conf"):
    keys = [k for k in r.keys(f"zone:{zone}:*") if not k.endswith(":ttl")]

    with open(output_file, "w") as f:
        f.write("server:\n\n")
        f.write(f'local-zone: "{zone}." transparent\n')
        f.write(f'domain-insecure: "{zone}."\n\n')

        for key in sorted(keys):
            _, z, name, rtype = key.split(":")

            ttl = r.get(f"{key}:ttl") or "300"

            if rtype == "SOA":
                value = r.get(key)
                if value:
                    f.write(f'local-data: "{fqdn(name)} {ttl} IN SOA {value}"\n')
                continue

            records = r.smembers(key)
            for value in sorted(records):
                f.write(f'local-data: "{fqdn(name)} {ttl} IN {rtype} {value}"\n')
    print(f"[DONE] Config written to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python collector.py <domain>")
        sys.exit(1)

    if TTL_MODE not in ['respect', 'min', 'override']:
        print(f"Incorrect TTL_MODE, expected on of: \"respect\", \"min\", \"override\", got: {TTL_MODE}")
        sys.exit(1)

    if TTL_OVERRIDE is None or int(TTL_OVERRIDE) > 0:
        print(f"Value of TTL_OVERRIDE was not correct: {TTL_OVERRIDE}")

    zone = sys.argv[1].rstrip(".")

    collect(zone)
    generate_config(zone)
