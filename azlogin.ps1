$tenantId = "4a1c61bf-11d9-4bcc-8493-2d40bb0e45b7"
$clientId = "e21fc4cc-3424-40d2-af2d-b86dc784e727"
$clientSecret = "23K8Q~JEv6lrnUYHvXiyJtnIvHIDXZQRTIklybmb"
az login --service-principal -t $tenantId -u $clientId -p $clientSecret
$aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv