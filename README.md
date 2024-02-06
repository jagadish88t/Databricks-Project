# Databricks-Project
Agenda:
 - Create Databricks Cluster.
 - Create Azure Key Vault.
 - Create Databricks secret scope with backend as Azure key vault.

Service Principal required for Terraform to create Databricks and it's secrets:

- Create a Service Principal and assign Role "Cloud Application Administrator".
- Service Principal used for creating Databricks and its secrets require "Cloud Application Administrator" Role.
- Assign the Service Principal to Subscription with Contributor Access for creating resources.
- Login to azure using Service Principal.
- Create AAD Token and use that token for creating Databricks secrets.
    -	```
      	$aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
  	```
    - resource "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d" is unique to Databricks 
        https://learn.microsoft.com/en-us/azure/databricks/dev-tools/service-prin-aad-token#:~:text=Generate%20the%20Microsoft%20Entra%20ID%20access%20token%20for%20the%20signed%2Din%20Microsoft%20Entra%20ID%20service%20principal%20by%20running%20the


Create Databricks secret scope using Terraform:

- Login to Azure using azure cli using Service Principal
    az login --service-principal -t $tenantId -u $clientId -p $clientSecret
- Generate AAD Token 
        $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
- Create provider.tf file with required providers. In provider "databricks" {} fill the required data as below  
  ```
  	provider "databricks" {
  		host  = <--Databricks URL-->("https://adb-1639784005057929.9.azuredatabricks.net/")
  		token = <--AAD TOKEN--> (use AAD TOKEN which is generated after logging into Azure)
	}
  ```
    -   AAD Token can be set as variable and passed during the run time 
    -   Create a variable in variables.tf file so that the add token can be used during the run time.
	```
		variable "databricks_aadtoken" {
			type = string
	    	}
  	```
    -   Use the variable in provider.tf file
    -   Use data block to get the databricks workspace url and pass the url in provider.tf file
   	```
	provider "databricks" {
		# Configuration options
		host = "https://${data.azurerm_databricks_workspace.name.workspace_url}/"
		token = var.databricks_aadtoken
	}
   	```
    -   During the terraform apply use the following command
        -   For creating resource - 
	```
    		terraform apply -auto-approve -var-file .\terraform.tfvars -var "databricks_aadtoken=$aadtoken"
  	```
        -   For destroying the resource -
   	```
                terraform apply -destroy -auto-approve -var-file .\terraform.tfvars -var "databricks_aadtoken=$aadtoken"
  	```

Test access from Databricks to Key vault:
    
-   Navigate to Databricks workspace and create new notebook.
-   use dbutils to get the details from secrets
	```
        	dbutils.secrets.listscopes()
        	dbutils.secrets.get(scope="scope_name", key = "kv_secret_name")
	```

Databricks CLI Setup on Local machine:

-   Download Databricks cli and install if not able to install cli and use .exe by setting it as system environmental variable on windows.
-   Download databricks cli from - https://docs.databricks.com/en/dev-tools/cli/install.html#:~:text=databricks_cli_X.Y.Z_windows_amd64.zip
-   Extract zip file and copy all files to C:\WorkSpace\databricks_cli
-   Set Environment variable variable_name = databricks, value = C:\WorkSpace\databricks_cli
-   Now databricks cli is ready to use.

	
Setup AAD Token for Databricks:

-   Login to azure using azure cli. (az login)
-   Get aad token using azure cli
    $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
-   Store this token as environment variable 
        Set-Item -Path Env:DATABRICKS_TOKEN -Value ($Env:DATABRICKS_TOKEN + "$aadtoken")
-   Verify environment variables using 
        Get-ChildItem -Path Env:
		
			
Databricks PAT token:

-   Login to Databricks Workspace Ui from Azure Portal.
-   Navigate to Admin Settings -> Developer -> Access tokens. Create one PAT token.

Create Databricks secret scope using Databricks CLI:

-   Use Databricks CLI on local machine:
    -   Login to Databricks
        -   Use command - databricks configure
            -   It will ask for host and PAT token 
                -   Host - https://adb-1639784005057929.9.azuredatabricks.net/ (databricks url)
                -   Token - Use Databricks PAT token
    -   Create secret scope
            Create scope command will use the environment variable "DATABRICKS_TOKEN" which is already created and stored.
            If any issues occurred, then recreate the environment variable "DATABRICKS_TOKEN" by following above mentioned process.
            Store all required information for creating Azure Key Vault backed secret scope in json file and store it locally. This file path will be used later for creating secret scope.
            
    -   Use command 
            databricks secrets create-scope --json @filepath\databrickssecretscope.json --initial-manage-principal users


Create Databricks and databricks secret scope using Terraform and Azure DevOps
-	While running Terraform on ADO for creating Databricks secret scope it does not require aadtoken.
-	As the terraform task already uses Service Principal it will get conflict if using AADToken again.
	-	If we use AAD token creation and use that to run terraform apply. Pipeline will fail with below error
	-	Error: validate: more than one authorization method configured: azure and pat. Config: token=***, azure_client_secret=***, azure_client_id=***, azure_tenant_id=*******. Env: DATABRICKS_TOKEN, ARM_CLIENT_SECRET, ARM_CLIENT_ID, ARM_TENANT_ID
	│ 
	│   with provider["registry.terraform.io/databricks/databricks"],
	│   on provider.tf line 25, in provider "databricks":
	│   25: provider "databricks" {
-	```
	  	provider "databricks" {
		  host = "https://${data.azurerm_databricks_workspace.databricks_data.workspace_url}/"
		  // token = var.databricks_aadtoken // token is not required when running the terraform code on ADO. As the Service Principal is going to be used during the runtime operations.
		}
  	```
-	To run the pipeline successfully Service Principal require "Cloud Application Administrator" role.
-	All resources will be created as required.
-	Testing can be done by using Databricks PAT token and Databricks cli from local machine.
  
