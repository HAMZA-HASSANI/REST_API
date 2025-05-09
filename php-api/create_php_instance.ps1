# Variables
$ImageName = "php:8.1-apache"
$ContainerName = "php-api"
$NetworkName = "postgres"
$VolumeName = "php-config-volume"
$ApiScriptPath = (Get-Location).Path + "\api.php"

# Step 1: Create a Docker network if it doesn't exist
if (-not (docker network ls --format "{{.Name}}" | Select-String -Pattern $NetworkName)) {
    Write-Host "Creating Docker network: $NetworkName"
    docker network create $NetworkName
} else {
    Write-Host "Docker network $NetworkName already exists."
}

# Step 2: Create a Docker volume for PHP configuration if it doesn't exist
if (-not (docker volume ls --format "{{.Name}}" | Select-String -Pattern $VolumeName)) {
    Write-Host "Creating Docker volume: $VolumeName"
    docker volume create $VolumeName
} else {
    Write-Host "Docker volume $VolumeName already exists."
}

# Step 3: Run the PHP container and mount index.html
Write-Host "Starting PHP container: $ContainerName"
docker run -d `
    --name $ContainerName `
    --network $NetworkName `
    -v "`"$ApiScriptPath`":/var/www/html/api.php" `
    -v "`"$(Get-Location)\index.html`":/var/www/html/index.html" `
    -p 8080:80 `
    $ImageName

# Step 4: Install required PostgreSQL libraries and pdo_pgsql extension
Write-Host "Installing required PostgreSQL libraries and pdo_pgsql extension in the PHP container..."
docker exec $ContainerName apt-get update

docker exec $ContainerName apt-get install -y libpq-dev

docker exec $ContainerName docker-php-ext-install pdo_pgsql

# Step 5: Restart the PHP container to apply changes
Write-Host "Restarting PHP container: $ContainerName"
docker restart $ContainerName
