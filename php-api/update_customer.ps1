# Update an existing customer
$BaseUrl = "http://localhost:8080/api.php"
$PutBody = @{ customer_id = 1; firstname = "UpdatedCustomer" } | ConvertTo-Json -Depth 10
Write-Host "Updating customer with ID 1..."
Invoke-RestMethod -Method PUT -Uri $BaseUrl -Body $PutBody -ContentType "application/json"
