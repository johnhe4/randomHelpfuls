#!/bin/bash

PATTERN=*.swift
find . -name "$PATTERN" | xargs wc -l | tail -n 1
