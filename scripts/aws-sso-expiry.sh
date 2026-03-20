#!/bin/bash
# AWS SSO Expiry Checker
# Returns remaining time and color code for prompt integration

get_aws_sso_expiry() {
    local best_epoch=0
    local now_epoch=$(date +%s)
    
    # Check role session credentials first (cli/cache)
    for f in ~/.aws/cli/cache/*.json 2>/dev/null; do
        [ -f "$f" ] || continue
        local exp=$(grep -o '"Expiration"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" 2>/dev/null | sed 's/.*"\([^"]*\)"/\1/' | sed 's/+00:00$/Z/')
        [ -n "$exp" ] || continue
        local epoch=$(TZ=UTC /bin/date -jf "%Y-%m-%dT%H:%M:%SZ" "$exp" +%s 2>/dev/null) || continue
        (( epoch > best_epoch )) && best_epoch=$epoch
    done
    
    # Fall back to SSO access token
    if (( best_epoch == 0 )); then
        for f in ~/.aws/sso/cache/*.json 2>/dev/null; do
            [ -f "$f" ] || continue
            grep -q '"accessToken"' "$f" || continue
            local exp=$(grep -o '"expiresAt"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" 2>/dev/null | sed 's/.*"\([^"]*\)"/\1/')
            [ -n "$exp" ] || continue
            local epoch=$(TZ=UTC /bin/date -jf "%Y-%m-%dT%H:%M:%SZ" "$exp" +%s 2>/dev/null) || continue
            (( epoch > best_epoch )) && best_epoch=$epoch
        done
    fi
    
    # No credentials found
    (( best_epoch > 0 )) || return
    
    local remaining=$(( best_epoch - now_epoch ))
    
    if (( remaining <= 0 )); then
        echo "expired:red"
    elif (( remaining < 1800 )); then
        echo "$((remaining / 60))m:orange"
    elif (( remaining < 3600 )); then
        echo "$((remaining / 60))m:yellow"
    else
        local h=$((remaining / 3600))
        local m=$(( (remaining % 3600) / 60 ))
        echo "${h}h${m}m:green"
    fi
}

get_aws_sso_expiry
