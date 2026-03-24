#!/bin/bash
# automated-checks.sh - Automated health check for the DNS Lab environment

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Starting Automated Health Checks...${NC}"

# 1. Check if container is running
CONTAINER_NAME="dns-resolver"
if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" == "true" ]; then
    echo -e "${GREEN}[PASS]${NC} Container '$CONTAINER_NAME' is running."
else
    echo -e "${RED}[FAIL]${NC} Container '$CONTAINER_NAME' is NOT running or doesn't exist."
    exit 1
fi

# 2. Check if systemd is initialized
STATUS=$(docker exec $CONTAINER_NAME systemctl is-system-running 2>/dev/null)
if [[ "$STATUS" == "running" || "$STATUS" == "degraded" ]]; then
    echo -e "${GREEN}[PASS]${NC} Systemd state: $STATUS"
else
    echo -e "${RED}[FAIL]${NC} Systemd state: $STATUS (expected 'running' or 'degraded')"
fi

# 3. Check if unbound service is active
if docker exec $CONTAINER_NAME systemctl is-active --quiet unbound; then
    echo -e "${GREEN}[PASS]${NC} Unbound service is active."
else
    echo -e "${RED}[FAIL]${NC} Unbound service is NOT active."
fi

# 4. Check configuration hash parity
HOST_HASH=$(sha256sum unbound.conf | awk '{print $1}')
CONT_HASH=$(docker exec $CONTAINER_NAME sha256sum /etc/unbound/unbound.conf | awk '{print $1}')

if [ "$HOST_HASH" == "$CONT_HASH" ]; then
    echo -e "${GREEN}[PASS]${NC} Configuration hashes match (bind mount working)."
else
    echo -e "${RED}[FAIL]${NC} Configuration hashes mismatch!"
    echo "       Host: $HOST_HASH"
    echo "       Cont: $CONT_HASH"
fi

# 5. Functional Check: DNS resolution
# Checking if it can resolve a root hint (requires internet access in container)
# or just checking if it responds to any query.
if docker exec $CONTAINER_NAME dig @127.0.0.1 . NS +short +timeout=2 > /dev/null; then
    echo -e "${GREEN}[PASS]${NC} Functional test: Unbound is responding to DNS queries."
else
    echo -e "${RED}[FAIL]${NC} Functional test: Unbound is NOT responding to DNS queries."
fi

# 6. Network Check: IP Address
CONT_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
EXPECTED_IP="10.10.0.2"
if [ "$CONT_IP" == "$EXPECTED_IP" ]; then
    echo -e "${GREEN}[PASS]${NC} Container IP is $CONT_IP (matches expectation)."
else
    echo -e "${RED}[FAIL]${NC} Container IP is $CONT_IP (expected $EXPECTED_IP)."
fi

echo -e "${BLUE}>>> All checks completed.${NC}"
