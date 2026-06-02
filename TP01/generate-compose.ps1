# Charge les variables du .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.+)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim())
    }
}

# Génère le fichier
(Get-Content docker-compose.yml) `
  -replace '\$\{APP_NETWORK\}', $env:APP_NETWORK `
  -replace '\$\{PROXY_NETWORK\}', $env:PROXY_NETWORK `
  | Set-Content docker-compose.generated.yml

docker compose -f docker-compose.generated.yml up -d