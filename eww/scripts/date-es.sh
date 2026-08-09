#!/usr/bin/env bash
LC_TIME=es_AR.UTF-8 date '+%A %d de %B' | sed 's/^./\U&/'