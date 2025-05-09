# Add a new customer
$BaseUrl = "http://localhost:8080/api.php"
$PostBody = @{ firstname = "NewCustomer" } | ConvertTo-Json -Depth 10
Write-Host "Adding a new customer..."
Invoke-RestMethod -Method POST -Uri $BaseUrl -Body $PostBody -ContentType "application/json"
