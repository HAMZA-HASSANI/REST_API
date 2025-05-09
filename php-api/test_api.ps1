# Base URL of the API
$BaseUrl = "http://localhost:8080/api.php"

# Etape 1: Test GET request
Write-Host "Etape 1: Testing GET request..."
Invoke-RestMethod -Method GET -Uri $BaseUrl

# Etape 2: Test POST request
Write-Host "Etape 2: Testing POST request..."
$PostBody = @{ firstname = "Alice" } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method POST -Uri $BaseUrl -Body $PostBody -ContentType "application/json"

# Etape 3: Test PUT request
Write-Host "Etape 3: Testing PUT request..."
$PutBody = @{ customer_id = 1; firstname = "Bob" } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method PUT -Uri $BaseUrl -Body $PutBody -ContentType "application/json"

# Etape 4: Test DELETE request
Write-Host "Etape 4: Testing DELETE request..."
$DeleteBody = @{ customer_id = 1 } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Method DELETE -Uri $BaseUrl -Body $DeleteBody -ContentType "application/json"
