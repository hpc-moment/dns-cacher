import dns.message
import dns.query
import dns.rdatatype
import dns.flags
import os
import redis
import socket

REDIS_HOST = "cache"
REDIS_PORT = 6379
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD")

UNBOUND_IP = "10.10.0.2"
DNS_PORT = 53
CUSTOM_TTL = 3600

r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    password=REDIS_PASSWORD,
    decode_responses=False
)

def make_key(qname, qtype):
    return f"dns:{qname}:{qtype}"

def make_servfail_response(query):
    """Generate a minimal SERVFAIL response so clients don't hang."""
    resp = dns.message.make_response(query)
    resp.set_rcode(dns.rcode.SERVFAIL)
    return resp

def handle_query(data):
    try:
        query = dns.message.from_wire(data)
    except dns.message.Truncated:
        print("[WARN] Received truncated query. Ignoring.")
        return None
    except Exception as e:
        print(f"[ERROR] Failed to parse query: {e}")
        return None

    if not query.question:
        return make_servfail_response(query)

    qname = str(query.question[0].name)
    qtype = dns.rdatatype.to_text(query.question[0].rdtype)
    key = make_key(qname, qtype)

    try:
        cached = r.get(key)
        if cached:
            print(f"[HIT] {key}")
            cached_response = dns.message.from_wire(cached)
            cached_response.id = query.id

            ttl_left = r.ttl(key)
            if ttl_left and ttl_left > 0:
                for rrset in cached_response.answer:
                    rrset.ttl = ttl_left
            return cached_response

        print(f"[MISS] {key}")
        
        response = dns.query.udp(query, UNBOUND_IP, port=53, timeout=5.0)        
        response.id = query.id

        for rrset in response.answer:
            rrset.ttl = CUSTOM_TTL
        
        r.setex(key, CUSTOM_TTL, response.to_wire())
        return response

    except Exception as e:
        print(f"[ERROR] DNS/Redis error: {e}")
        return make_servfail_response(query)

def run_dns_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", DNS_PORT))
    print(f"DNS proxy listening on port {DNS_PORT}...")

    while True:
        data, addr = sock.recvfrom(4096)
        try:
            response = handle_query(data)
            if response:
                sock.sendto(response.to_wire(), addr)
        except Exception as e:
            print(f"[FATAL] Socket error: {e}")

if __name__ == "__main__":
    run_dns_server()
