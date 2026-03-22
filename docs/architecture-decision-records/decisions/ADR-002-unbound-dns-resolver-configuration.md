# ADR-002: Unbound DNS Resolver Network and Security Configuration

## Status
Accepted

## Date
2026-03-22

## Context
After setting up the containerized Unbound DNS resolver (ADR-001), we needed to determine the exact networking, performance, and security profiles for the unbound daemon itself. The DNS resolver must serve local and specific subnet queries efficiently, employ cryptographic validation (DNSSEC), restrict exposure, and manage internal caching to guarantee high performance and security.

## Decision
The `unbound.conf` is configured with the following decisive parameters:
1. **Access Control:** The resolver listens on `0.0.0.0:53`. Queries are strictly refused globally (`0.0.0.0/0 refuse`), but allowed from localhost (`127.0.0.0/8 allow`) and the isolated Docker lab network (`10.10.0.0/24 allow`).
2. **Protocol Limitations:** TCP and UDP are enabled for IPv4 (`do-ip4: yes`, `do-udp: yes`, `do-tcp: yes`), while IPv6 is explicitly disabled (`do-ip6: no`).
3. **Performance Optimization:** 
   - Multi-threading is enabled (`num-threads: 2`).
   - Memory allocation is proportioned for caches: Message cache (`64m`), RRset cache (`128m`), and Negative cache (`16m`).
4. **Security Enhancements:** 
   - Identity and version hiding are enabled (`hide-identity: yes`, `hide-version: yes`).
   - DNSSEC is strictly enforced (`harden-dnssec-stripped: yes`) and the `validator` module is mandated alongside the `iterator`.

## Rationale
- **Network Isolation:** Explicitly allowing standard internal networks while aggressively blocking public routes prevents the server from becoming an open DNS amplification vector, adhering to best security practices.
- **Cache Sizing and Threads:** Splitting the memory correctly between message caches (DNS headers) and RRset caches (actual record data, sized at 2x message cache) ensures high hit rates. Utilizing 2 threads efficiently leverages modern multi-core container allocations without excessive context switching.
- **Security Posture:** Hiding the version mitigates automated vulnerability scanning. Forcing DNSSEC prevents cache poisoning and man-in-the-middle attacks, ensuring the integrity of the resolved queries.

## Consequences
- The resolver is restricted to IPv4 only. Any internal lab components relying strictly on IPv6 DNS resolution will require adjustments.
- High memory cache sizes (`>200MB` total) mean the container will consume a non-trivial footprint. Host node monitoring must account for this baseline.
- `remote-control` via port 8953 requires internal access to localhost to execute commands like `unbound-control status`.

## Alternatives Considered
- **Public Open Resolver:** Evaluated but rejected due to the extreme security risks of DNS amplification attacks.
- **No DNSSEC Validation:** Evaluated for faster query speeds, but rejected because data integrity and security validation outweigh minor latency improvements.
