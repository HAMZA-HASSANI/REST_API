# Script to check the synchronization status between primary and standby PostgreSQL databases

Write-Host "Checking synchronization status of the primary PostgreSQL database..."
$primaryStatus = docker exec -i postgres-1 bash -c "psql -U admin -d postgresdb -tA -c 'SELECT pg_current_wal_lsn();'"
Write-Host "Primary WAL LSN: $primaryStatus"

Write-Host "Checking synchronization status of the standby PostgreSQL database..."
$standbyStatus = docker exec -i postgres-2 bash -c "psql -U admin -d postgresdb -tA -c 'SELECT pg_last_wal_replay_lsn();'"
Write-Host "Standby WAL Replay LSN: $standbyStatus"

if ($primaryStatus -eq $standbyStatus) {
    Write-Host "The primary and standby databases are synchronized."
} else {
    Write-Host "The primary and standby databases are not synchronized."
}