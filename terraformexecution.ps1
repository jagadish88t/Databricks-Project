param (
    [string]$Perform
)

$tenantId = ""
$clientId = ""
$clientSecret = ""


if ($Perform -eq "apply") {
    <# Action to perform if the condition is true #>
    try {
        Write-Output "Initialize terraform binaries"
        terraform init -upgrade
    
        Write-Output "Validate terraform"
        terraform validate
    
        Write-Output "Login to azure using service principal"
        az login --service-principal -t $tenantId -u $clientId -p $clientSecret

        az account set --subscription "MySubscription"
    
        Write-Output "Generate AAD Token for databricks"
        $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
        Write-Host $aadtoken
        
        #Method 1
        Write-Output "Generate terraform plan"
        terraform plan -var-file ./terraform.tfvars -var "databricks_aadtoken=$aadtoken" 
        
        Write-Output "Perform Terrafor apply"
        terraform apply -auto-approve -var-file ./terraform.tfvars -var "databricks_aadtoken=$aadtoken"

        #Method 2
        terraform plan -var-file ./terraform.tfvars -var "databricks_aadtoken=$aadtoken" -out tfplan
        terraform apply tfplan
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "Exception occurred while performing "
        Write-Output $_
    }
} else {
    <# Action when all if and elseif conditions are false #>
    try {
        Write-Output "Initialize terraform binaries"
        terraform init -upgrade
    
        Write-Output "Validate terraform"
        terraform validate
    
        Write-Output "Login to azure using service principal"
        az login --service-principal -t $tenantId -u $clientId -p $clientSecret

        az account set --subscription "MySubscription"
    
        Write-Output "Generate AAD Token for databricks"
        $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
        Write-Host $aadtoken
        
        Write-Output "Perform Terraform destroy"
        terraform apply -destroy -auto-approve -var-file ./terraform.tfvars -var "databricks_aadtoken=$aadtoken"
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output $_
    }
}
