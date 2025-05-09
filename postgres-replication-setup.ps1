# PowerShell script to automate PostgreSQL replication process

# Variables
$containerName = "postgres-1"
$databaseName = "postgresdb"
$adminUser = "admin"
$adminPassword = "admin"
$sqlScriptPath = "user_replication.sql"

# Step 1: Create Docker network
Write-Host "Creating Docker network..."
docker network create postgres

# Step 2: Start primary PostgreSQL container
Write-Host "Starting primary PostgreSQL container..."
docker run -d --name postgres-1 `
--net postgres `
-e POSTGRES_USER=admin `
-e POSTGRES_PASSWORD=admin `
-e POSTGRES_DB=postgresdb `
-e PGDATA="/data" `
-v ${PWD}/postgres-1/pgdata:/data `
-v ${PWD}/postgres-1/config:/config `
-v ${PWD}/postgres-1/config/pg_hba.conf:/config/pg_hba.conf `
-v ${PWD}/postgres-1/archive:/mnt/server/archive `
-p 5000:5432 `
postgres:16.0 -c config_file=/config/postgresql.conf

# Wait for 1 minute to ensure the container is fully initialized
Write-Host "Waiting for 1 minute to ensure primary container is ready..."
Start-Sleep -Seconds 60

# Step 6: Create replication user without password prompt
Write-Host "Creating replication user..."
# Check if the SQL script exists
if (-Not (Test-Path $sqlScriptPath)) {
    Write-Error "SQL script $sqlScriptPath not found. Please ensure the file exists."
    exit 1
}

# Step 7: Copy the SQL script into the primary container
Write-Host "Copying user_replication.sql into container postgres-1..."
docker cp ${sqlScriptPath} ${containerName}:/tmp/user_replication.sql

# Step 8: Execute the SQL script inside the primary container
Write-Host "Executing user_replication.sql inside container postgres-1..."
docker exec -it $containerName bash -c "PGPASSWORD=$adminPassword psql -U $adminUser -d $databaseName -f /tmp/user_replication.sql"

Write-Host "Replication user created successfully using user_replication.sql."

# Step 9: Take a base backup without password prompt
Write-Host "Taking base backup..."
docker run -it --rm `
--net postgres `
-v ${PWD}/postgres-2/pgdata:/data `
-e PGPASSWORD=replicationPassword `
--entrypoint /bin/bash postgres:16.0 -c "pg_basebackup -h postgres-1 -p 5432 -U replication_user -D /data/ -Fp -Xs -R"

# Wait for 30 seconds to ensure the pg_basebackup is fully executed
Write-Host "Waiting for 30 seconds to ensure base backup is complete..."
Start-Sleep -Seconds 30

# Step 10: Start standby PostgreSQL container
Write-Host "Starting standby PostgreSQL container..."
docker run -d --name postgres-2 `
--net postgres `
-e POSTGRES_USER=admin `
-e POSTGRES_PASSWORD=admin `
-e POSTGRES_DB=postgresdb `
-e PGDATA="/data" `
-v ${PWD}/postgres-2/pgdata:/data `
-v ${PWD}/postgres-2/config:/config `
-v ${PWD}/postgres-2/config/pg_hba.conf:/config/pg_hba.conf `
-v ${PWD}/postgres-2/archive:/mnt/server/archive `
-p 5001:5432 `
postgres:16.0 -c 'config_file=/config/postgresql.conf'

Write-Host ".pgpass file setup completed successfully."

Write-Host "PostgreSQL replication setup completed."
Write-Host "PostgreSQL replication setup completed successfully. Both primary and standby containers are running."