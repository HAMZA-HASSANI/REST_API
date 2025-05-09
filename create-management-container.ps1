# Script to create a management container for PostgreSQL supervision

# Step 1: Pull the official pgAdmin image
docker pull dpage/pgadmin4

# Step 2: Create the management container with servers.json mounted
docker run -d `
  --name management `
  --network postgres `
  -p 5050:80 `
  -e PGADMIN_DEFAULT_EMAIL=admin@admin.com `
  -e PGADMIN_DEFAULT_PASSWORD=admin `
  -v ${PWD}/pgadmin_data:/var/lib/pgadmin `
  dpage/pgadmin4
Write-Host "Management container created successfully with pgAdmin and volume mounted."