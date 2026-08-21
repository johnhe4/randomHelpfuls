#!/bin/bash

# Uses the "unofficial" Yahoo finance APIs to find today's top $NUM_SYMS US-based "gainers",
# then print a comparison to the closing price $NUM_DAYS ago.
# I made an effort to not touch the filesystem in this script in order to showcase propsync's in-memory prowess;
# that said, this script would be more readable if files were used between steps.
NUM_SYMS=5
NUM_DAYS=5
PREV_DAY_IDX=$((NUM_DAYS - 1))

PS=~/code/libpropsync/build/bin/propsync

# xargs acts as a "foreach" between steps.
# awk provides a nice way to present the result.
# meta/chartPreviousClose is unreliable for volatile movers (Yahoo returns a stale value
# that does not match the actual close series), so both comparisons are derived from the
# close-price series itself: *[1] is the close $NUM_DAYS ago, *[$PREV_DAY_IDX] is yesterday's close.
$PS "https://query2.finance.yahoo.com/v1/finance/screener/predefined/saved?scrIds=day_gainers&count=${NUM_SYMS}&region=US" out --ser pcsv filter '/root/finance/result/*[1]/quotes/*/symbol' 2>/dev/null \
| xargs -I %SYMBOL $PS "https://query1.finance.yahoo.com/v8/finance/chart/%SYMBOL?range=${NUM_DAYS}d&interval=1d" out --ser PCSV filter "/root/chart/result/*[1]/concat(meta/symbol, \",\", meta/regularMarketPrice, \",\", indicators/quote/*[1]/close/*[1], \",\", indicators/quote/*[1]/close/*[${PREV_DAY_IDX}])" 2>/dev/null \
| awk -F',' -v days="$NUM_DAYS" '{
    old  = $3
    prev = $4
    today = (prev=="" || prev+0==0) ? "n/a" : sprintf("%+.1f%%", (($2-prev)/prev)*100)
    nday  = (old=="" || old+0==0) ? "n/a" : sprintf("%+.1f%%", (($2-old)/old)*100)
    printf "%s    today: %s    %s day: %s\n", $1, today, days, nday
  }'