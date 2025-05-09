# Script to check the status of both PostgreSQL containers

Write-Host "Checking the status of the primary PostgreSQL container..."
docker exec -it postgres-1 bash -c "pg_isready -U admin -d postgresdb"

Write-Host "Checking the status of the standby PostgreSQL container..."
docker exec -it postgres-2 bash -c "pg_isready -U admin -d postgresdb"

Write-Host "Status check completed for both PostgreSQL containers."