# Script PowerShell pour effectuer un rollback après l'exécution de setup-postgres-replication.ps1

# Fonction pour vérifier si une commande Docker a réussi
function Test-DockerCommand {
    param (
        [string]$Command,
        [string]$ErrorMessage
    )

    $result = Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Error $ErrorMessage
        exit 1
    }
    return $result
}

# Step 1: Stop and remove Docker containers
Write-Host "Stopping and removing Docker containers..."
$containers = @("postgres-1", "postgres-2")
foreach ($container in $containers) {
    if (docker ps -a --filter "name=$container" -q) {
        Test-DockerCommand "docker stop $container" "Failed to stop container $container."
        Test-DockerCommand "docker rm $container" "Failed to remove container $container."
    } else {
        Write-Host "Container $container does not exist."
    }
}

# Step 2: Remove Docker network
Write-Host "Removing Docker network 'postgres'..."
if (docker network ls --filter name=^postgres$ -q) {
    Test-DockerCommand "docker network rm postgres" "Failed to remove Docker network 'postgres'."
} else {
    Write-Host "Docker network 'postgres' does not exist."
}

# Step 3: Remove all Docker volumes
Write-Host "Removing all Docker volumes..."
Write-Host "List of Docker volumes before removal:"
docker volume ls

$allVolumes = docker volume ls -q
if ($allVolumes) {
    try {
        docker volume rm $allVolumes
        Write-Host "All Docker volumes have been removed."
    } catch {
        Write-Error "Failed to remove some Docker volumes: $_"
    }
} else {
    Write-Host "No Docker volumes to remove."
}

Write-Host "List of Docker volumes after removal:"
docker volume ls

# Step 4: Remove local directories
Write-Host "Removing local directories..."
$directories = @(
    "c:\Users\33769\Desktop\my_docker_project\pg-cluster\postgres-1\pgdata", 
    "c:\Users\33769\Desktop\my_docker_project\pg-cluster\postgres-1\archive", 
    "c:\Users\33769\Desktop\my_docker_project\pg-cluster\postgres-2\pgdata", 
    "c:\Users\33769\Desktop\my_docker_project\pg-cluster\postgres-2\archive"
)
foreach ($directory in $directories) {
    if (Test-Path $directory) {
        try {
            Remove-Item -Recurse -Force $directory
            Write-Host "Directory $directory removed."
        } catch {
            Write-Error "Failed to remove directory ${directory}: $_"
        }
    } else {
        Write-Host "Directory $directory does not exist."
    }
}

# Step 5: Remove the SQL script from the primary container
Write-Host "Removing user_replication.sql from container postgres-1..."
docker exec -it postgres-1 bash -c "rm -f /tmp/user_replication.sql"
Write-Host "SQL script removed successfully."

Write-Host "Rollback completed. All created containers, networks, and directories have been removed."