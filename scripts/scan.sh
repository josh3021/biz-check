#!/usr/bin/env bash
# biz-check: print only the locations of business keywords. 20 lines per category, 200 total.
# usage: scan.sh [path]
set -u
root="${1:-.}"
command -v rg >/dev/null || { echo "biz-check: ripgrep (rg) not found; install it and re-run" >&2; exit 1; }
excl=(-g '!node_modules' -g '!build' -g '!dist' -g '!.git' -g '!.biz' -g '!*.lock' -g '!*lock.yaml'
      -g '!*.min.*' -g '!*.g.dart' -g '!*.freezed.dart' -g '!openapi.json' -g '!**/packages/*_api/**'
      -g '!*.svg' -g '!*.map' -g '!coverage' -g '!.dart_tool' -g '!Pods' -g '!*.tsv' -g '!*.md')

scan() { # $1=category $2=regex
  echo "## $1"
  rg -n -i --sort path --no-heading --max-count 3 --max-columns 160 --max-columns-preview "${excl[@]}" -e "$2" "$root" 2>/dev/null | head -20
}

{
  scan pricing  'price|pricing|\bplan\b|\btiers?\b|subscription|구독|요금|가격|料金|価格|サブスク|订阅|价格|precio|suscripci'
  scan payment  'payment|checkout|billing|stripe|kcp|toss|paddle|결제|환불|決済|返金|支付|退款|pago'
  scan auth     'signup|sign_up|login|onboarding|가입|온보딩'
  scan metrics  'analytics|track\(|logEvent|amplitude|mixpanel|posthog|firebase_analytics'
} | head -200
exit 0
