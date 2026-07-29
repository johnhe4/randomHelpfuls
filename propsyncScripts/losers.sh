#!/bin/bash

# Uses the "unofficial" Yahoo finance APIs to find today's top $NUM_SYMS US-based "losers",
# then print a comparison to the closing price $NUM_DAYS ago.
# I made an effort to not touch the filesystem in this script in order to showcase propsync's in-memory prowess;
# that said, this script would be more readable if files were used between steps.
NUM_SYMS=5
NUM_DAYS=5

PS=~/code/libpropsync/build/bin/propsync

# xargs acts as a "foreach" between steps.
# awk provides a nice way to present the result.
$PS "https://query2.finance.yahoo.com/v1/finance/screener/predefined/saved?scrIds=day_losers&count=${NUM_SYMS}&region=US" out --ser pcsv filter '/root/finance/result/*[1]/quotes/*/symbol' 2>/dev/null \
| xargs -I %SYMBOL $PS "https://query1.finance.yahoo.com/v8/finance/chart/%SYMBOL?range=${NUM_DAYS}d&interval=1d" out --ser PCSV filter '/root/chart/result/*[1]/concat(meta/symbol, ",", meta/regularMarketPrice, ",", meta/chartPreviousClose, ",", indicators/quote/*[1]/close/*[1])' 2>/dev/null \
| awk -F',' -v days="$NUM_DAYS" '{printf "%s    today: %.1f%%    %s day: %.1f%%\n",    $1, (($2-$3)/$3)*100, days, (($2-$4)/$4)*100}'