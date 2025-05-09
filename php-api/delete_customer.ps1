# Delete a customer by firstname
$BaseUrl = "http://localhost:8080/api.php"
$Firstname = "John"
$DeleteBody = @{ firstname = $Firstname } | ConvertTo-Json -Depth 10
Write-Host "Deleting customer with firstname $Firstname..."
Invoke-RestMethod -Method DELETE -Uri $BaseUrl -Body $DeleteBody -ContentType "application/json"
