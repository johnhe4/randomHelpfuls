#!/bin/bash

# Uses the "unofficial" Yahoo finance APIs to find today's top $NUM_SYMS US-based "gainers",
# then print a comparison to the closing price $NUM_DAYS ago.
# I made an effort to not touch the filesystem in this script in order to showcase propsync's in-memory prowess;
# that said, this script would be more readable if files were used between steps.
NUM_SYMS=5
NUM_DAYS=5

PS=~/code/libpropsync/build/bin/propsync

# xargs acts as a "foreach" between steps.
# awk provides a nice way to present the result.
$PS "https://query2.finance.yahoo.com/v1/finance/screener/predefined/saved?scrIds=day_gainers&count=${NUM_SYMS}&region=US" out --ser pcsv filter '/root/finance/result/*[1]/quotes/*/symbol' 2>/dev/null \
| xargs -I %SYMBOL $PS "https://query1.finance.yahoo.com/v8/finance/chart/%SYMBOL?range=${NUM_DAYS}d&interval=1d" out --ser PCSV filter '/root/chart/result/*[1]/concat(meta/symbol, ",", indicators/quote/*[1]/close)' 2>/dev/null \
| awk -F',' '{printf "%s    today: +%.1f%%    %i day: +%.1f%%\n",    $1, (($NF-$(NF-1))/$(NF-1))*100, NF-1, (($NF-$2)/$2)*100}'