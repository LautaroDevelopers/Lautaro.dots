#!/usr/bin/env bash
# Últimos repos de GitHub (privados y públicos), vía `gh` (ya
# autenticado, sin token propio que gestionar).
/home/linuxbrew/.linuxbrew/bin/gh repo list --json name,url,isPrivate --limit 12 2>/dev/null || echo "[]"
