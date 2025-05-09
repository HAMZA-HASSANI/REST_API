# Simplified script to fetch a customer by firstname
Write-Host "Getting customer with firstname NewCustomer..."
Invoke-RestMethod -Method GET -Uri "http://localhost:8080/api.php?firstname=NewCustomer"
