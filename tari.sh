#!/bin/bash
## https://github.com/tari-project/tari/releases

PASSWD="${1:-}"
AMOUNT="${2:-0}"
TARGET="${3:-}"
BASE="${4:-.tari}"
TARICMD=""


cd "$(dirname `readlink -f "$0"`)" && [ -f "./minotari_console_wallet" ] || exit 1

[ "$AMOUNT" == "seed" ] && {
  ./minotari_console_wallet --non-interactive-mode --network Mainnet --base-path "${BASE}" -p base_node.mining_enabled=false -p wallet.grpc_enabled=false --password "${PASSWD}" --recovery --seed-words "${TARGET}"
  exit "$?"
}

[ "$AMOUNT" == "ui" ] && {
  ./minotari_console_wallet --network Mainnet --base-path "${BASE}" -p base_node.mining_enabled=false -p wallet.grpc_enabled=false --password "${PASSWD}"
  exit "$?"
}

result=`./minotari_console_wallet --non-interactive-mode --network Mainnet --base-path "${BASE}" -p base_node.mining_enabled=false -p wallet.grpc_enabled=false --password "${PASSWD}" --command-mode-auto-exit sync 2>/dev/null`
block=`echo "$result" |grep -o '^Completed! Height: [0-9]\+,' |grep -o '[0-9]\+'`
[ -n "$block" ] && [ "$block" -gt "0"  ] && echo "Sync Block Height: ${block}"
echo "$result" |grep '^Available balance:\|^Pending incoming balance:\|^Pending outgoing balance:'
amount=`echo "$result" |grep '^Available balance:' |grep ' T$' |grep -o '[0-9]\+' |head -n1`
[ -n "$amount" ] && [ "$amount" -gt "0" ] || exit 1
[ -n "$AMOUNT" ] || AMOUNT="0"
[ "$AMOUNT" -eq "0" ] && exit 0
[ "$AMOUNT" -gt "0" ] && [ "$AMOUNT" -ge "$amount" ] && AMOUNT="$amount"
[ "$AMOUNT" -eq "-1" ] && AMOUNT="$amount"
[ "$AMOUNT" -le "-2" ] && MINAMOUNT="$((10 ** -AMOUNT))" && [ "$((AMOUNT + MINAMOUNT))" -ge "0" ] && AMOUNT="$amount" || exit 0
[ "$AMOUNT" -le "0" ] && exit 1

[ -n "$TARGET" ] || exit 2
[ ! -n "$TARICMD" ] && [ "${#TARGET}" -eq "91" ] && TARICMD="send-minotari"
[ ! -n "$TARICMD" ] && [ "${#TARGET}" -gt "91" ] && TARICMD="send-one-sided-to-stealth-address"
[ -n "$TARICMD" ] || exit 2
result=`./minotari_console_wallet --non-interactive-mode --network Mainnet --base-path "${BASE}" -p base_node.mining_enabled=false -p wallet.grpc_enabled=false --password "${PASSWD}" --command-mode-auto-exit "${TARICMD}" "${AMOUNT}T" "${TARGET}" 2>&1`
TxID=`echo "$result" |grep '^Transaction ID:' |grep -o '[0-9]\+'`
[ -n "$TxID" ] && echo -e "Sending: ${AMOUNT} XTM --> ${TARGET}\nTxID[$(date '+%Y/%m/%d %H:%M:%S')]: ${TxID}\n" && exit 0
exit 1
