# Task 1-2, [P3]
## Instruction to run 
```bash
# clean up if needed
docker compose down -v

# build docker compose 
docker compose up -d --build
```

## Checks to meet requirements 
### Main checks 
```bash 
docker exec -it dns-resolver systemctl is-system-running

```
`running`

```bash
docker exec -it dns-resolver systemctl status unbound
```

<details>
  <summary>results</summary>

  ```bash
● unbound.service - Unbound DNS server
     Loaded: loaded (/lib/systemd/system/unbound.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2026-03-20 16:09:31 UTC; 28s ago
       Docs: man:unbound(8)
    Process: 34 ExecStartPre=/usr/lib/unbound/package-helper chroot_setup (code=exited, status=0/SUCCESS)
    Process: 37 ExecStartPre=/usr/lib/unbound/package-helper root_trust_anchor_update (code=exited, status=0/SUCCESS)
   Main PID: 41 (unbound)
      Tasks: 1 (limit: 11525)
     Memory: 7.2M
        CPU: 53ms
     CGroup: /system.slice/unbound.service
             └─41 /usr/sbin/unbound -d -p

3536d9faab7 systemd[1]: Starting Unbound DNS server...
b3536d9faab7 package-helper[37]: /var/lib/unbound/root.key does not exist, copying from /usr/share/dns/root.key
b3536d9faab7 unbound[41]: [41:0] notice: init module 0: subnet
b3536d9faab7 unbound[41]: [41:0] notice: init module 1: validator
b3536d9faab7 unbound[41]: [41:0] notice: init module 2: iterator
b3536d9faab7 unbound[41]: [41:0] info: start of service (unbound 1.13.1).
b3536d9faab7 systemd[1]: Started Unbound DNS server.
b3536d9faab7 unbound[41]: [41:0] info: generate keytag query _ta-4f66-9728. NULL IN

  ```
</details>

### Other checks
```bash
docker network inspect dns-lab | grep -A 5 -B 5 Subnet
```
<details>
    <summary>results</summary>

```bash
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.10.0.0/24",
                    "Gateway": "10.10.0.1"
                }
            ]
        },
        "Internal": false,
--
                "IPv6Address": ""
            }
        },
        "Status": {
            "IPAM": {
                "Subnets": {
                    "10.10.0.0/24": {
                        "IPsInUse": 4,
                        "DynamicIPsAvailable": 252
                    }
                }
```
</details>

```bash
$ docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dns-resolver
```
`10.10.0.2`
```bash
$ docker exec -it dns-resolver ip a | grep 10.10.0.2
```
`inet 10.10.0.2/24 brd 10.10.0.255 scope global eth0`
```bash
docker exec -it dns-resolver bash -c "unbound -V | grep modules"
```
`Linked modules: dns64 python subnetcache respip validator iterator`
