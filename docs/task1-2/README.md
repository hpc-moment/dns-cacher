# Task 1-2, [P3]
## Instruction to run 
```bash
# clean up if needed
docker compose down -v
docker network rm dns-lab
docker rm -f dns-resolver


# build docker compose 
docker compose up -d --build
```

## Checks to meet requirements 
### Automated Checks
```bash 
./check.sh
```
This script validates:
- Container status
- Systemd initialization
- Unbound service state
- Configuration hash parity
- DNS resolution functionality

### Manual checks 
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

Check `unbound.conf` copied correctly
```bash
HOST_HASH=$(sha256sum unbound.conf | awk '{print $1}')
CONT_HASH=$(docker exec -i dns-resolver sha256sum /etc/unbound/unbound.conf | awk '{print $1}')

echo "Host hash:      $HOST_HASH"
echo "Container hash: $CONT_HASH"

if [ "$HOST_HASH" = "$CONT_HASH" ]; then
    echo "SUCCESS: Hashes match! Bind mount is working perfectly."
else
    echo "ERROR: Hashes differ."
fi
```

<details>
  <summary>results</summary>

  ```bash
Host hash: <...>      
Container hash: <...>
SUCCESS: Hashes match! Bind mount is working perfectly.
  ```
</details>

Check if docker logs work 
```bash
docker logs dns-resolver
```

<details>
  <summary>results</summary>

  ```bash
systemd 249.11-0ubuntu3.17 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY -P11KIT -QRENCODE +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
Detected virtualization docker.
Detected architecture x86-64.

Welcome to Ubuntu 22.04.5 LTS!

Queued start job for default target Graphical Interface.
[  OK  ] Created slice Slice /system/modprobe.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[  OK  ] Set up automount Arbitrary…s File System Automount Point.
[  OK  ] Reached target Local Encrypted Volumes.
[  OK  ] Reached target Path Units.
[  OK  ] Reached target Slice Units.
[  OK  ] Reached target Swaps.
[  OK  ] Reached target Local Verity Protected Volumes.
[  OK  ] Listening on Journal Audit Socket.
[  OK  ] Listening on Journal Socket (/dev/log).
[  OK  ] Listening on Journal Socket.
[  OK  ] Reached target Socket Units.
         Mounting Huge Pages File System...
         Mounting Kernel Debug File System...
         Mounting Kernel Trace File System...
         Starting Journal Service...
         Starting Load Kernel Module configfs...
         Starting Load Kernel Module fuse...
         Starting Remount Root and Kernel File Systems...
         Starting Apply Kernel Variables...
[  OK  ] Mounted Huge Pages File System.
[  OK  ] Mounted Kernel Debug File System.
[  OK  ] Mounted Kernel Trace File System.
modprobe@configfs.service: Deactivated successfully.
[  OK  ] Finished Load Kernel Module configfs.
modprobe@fuse.service: Deactivated successfully.
[  OK  ] Finished Load Kernel Module fuse.
[  OK  ] Finished Remount Root and Kernel File Systems.
[  OK  ] Reached target Preparation for Local File Systems.
[  OK  ] Reached target Local File Systems.
         Mounting FUSE Control File System...
         Starting Set Up Additional Binary Formats...
         Starting Create System Users...
[  OK  ] Finished Apply Kernel Variables.
[  OK  ] Mounted FUSE Control File System.
proc-sys-fs-binfmt_misc.automount: Got automount request for /proc/sys/fs/binfmt_misc, triggered by 29 (systemd-binfmt)
         Mounting Arbitrary Executable File Formats File System...
[  OK  ] Mounted Arbitrary Executable File Formats File System.
[  OK  ] Finished Set Up Additional Binary Formats.
[  OK  ] Finished Create System Users.
[  OK  ] Started Journal Service.
[287174.858424] systemd[24]: modprobe@configfs.service: Executable /sbin/modprobe missing, skipping: No such file or directory
[  OK  ] Reached target System Initialization.
[  OK  ] Started Daily Cleanup of Temporary Directories.
[  OK  ] Reached target Basic System.
[287174.858654] systemd[25]: modprobe@fuse.service: Executable /sbin/modprobe missing, skipping: No such file or directory
[  OK  ] Reached target Timer Units.
[287174.858821] systemd[1]: Reached target System Initialization.
[  OK  ] Listening on D-Bus System Message Bus Socket.
[287174.859013] systemd[1]: Started Daily Cleanup of Temporary Directories.
[287174.859193] systemd[1]: Reached target Basic System.
[287174.859397] systemd[1]: Reached target Timer Units.
[287174.859590] systemd[1]: Listening on D-Bus System Message Bus Socket.
         Starting Flush Journal to Persistent Storage...
[287174.866245] systemd[1]: Starting Flush Journal to Persistent Storage...
         Starting Unbound DNS server...
[287174.867411] systemd[1]: Starting Unbound DNS server...
[287174.895082] package-helper[37]: /var/lib/unbound/root.key does not exist, copying from /usr/share/dns/root.key
[  OK  ] Finished Flush Journal to Persistent Storage.
[287174.895979] systemd[1]: Finished Flush Journal to Persistent Storage.
[287174.915497] unbound[42]: [1774208422] unbound[42:0] notice: init module 0: validator
[287174.915645] unbound[42]: [1774208422] unbound[42:0] notice: init module 1: iterator
[287174.946377] unbound[42]: [1774208422] unbound[42:0] info: start of service (unbound 1.13.1).
[  OK  ] Started Unbound DNS server.
[287174.946484] systemd[1]: Started Unbound DNS server.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
[  OK  ] Reached target Host and Network Name Lookups.
[287174.946583] systemd[1]: Reached target Multi-User System.
[287174.946701] unbound[42]: [1774208422] unbound[42:0] info: resolving . DNSKEY IN
[287174.946779] systemd[1]: Reached target Graphical Interface.
[287174.946875] unbound[42]: [1774208422] unbound[42:0] info: priming . IN NS
[287174.946945] systemd[1]: Reached target Host and Network Name Lookups.
[287174.947053] systemd[1]: Startup finished in 279ms.
[287175.083064] unbound[42]: [1774208422] unbound[42:0] info: response for . NS IN
[287175.083264] unbound[42]: [1774208422] unbound[42:0] info: reply from <.> 199.7.91.13#53
[287175.083347] unbound[42]: [1774208422] unbound[42:0] info: query response was ANSWER
[287175.083409] unbound[42]: [1774208422] unbound[42:0] info: priming successful for . NS IN
[287175.467083] unbound[42]: [1774208422] unbound[42:0] info: response for . DNSKEY IN
[287175.467247] unbound[42]: [1774208422] unbound[42:0] info: reply from <.> 192.203.230.10#53
[287175.467333] unbound[42]: [1774208422] unbound[42:0] info: query response was ANSWER
[287175.467408] unbound[42]: [1774208422] unbound[42:0] info: prime trust anchor
[287175.467465] unbound[42]: [1774208422] unbound[42:0] info: generate keytag query _ta-4f66-9728. NULL IN
[287175.467511] unbound[42]: [1774208422] unbound[42:0] info: resolving . DNSKEY IN
[287175.470161] unbound[42]: [1774208422] unbound[42:0] info: validate keys with anchor(DS): sec_status_secure
[287175.470229] unbound[42]: [1774208422] unbound[42:0] info: Successfully primed trust anchor . DNSKEY IN
[287175.470283] unbound[42]: [1774208422] unbound[42:0] info: resolving _ta-4f66-9728. NULL IN
[287175.470397] unbound[42]: [1774208422] unbound[42:0] info: validate(positive): sec_status_secure
[287175.470454] unbound[42]: [1774208422] unbound[42:0] info: validation success . DNSKEY IN
[287175.583496] unbound[42]: [1774208423] unbound[42:0] info: response for _ta-4f66-9728. NULL IN
[287175.583605] unbound[42]: [1774208423] unbound[42:0] info: reply from <.> 198.41.0.4#53
[287175.583665] unbound[42]: [1774208423] unbound[42:0] info: query response was NXDOMAIN ANSWER
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
