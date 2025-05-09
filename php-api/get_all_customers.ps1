# Get all customers
$BaseUrl = "http://localhost:8080/api.php"
Write-Host "Getting all customers..."
Invoke-RestMethod -Method GET -Uri $BaseUrl
