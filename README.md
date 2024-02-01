# Databricks-Project
Databricks Setup:
	• Download Databricks cli if not able to install cli and use .exe by setting it as environmental variable.
		○ Download databricks cli from - https://docs.databricks.com/en/dev-tools/cli/install.html#:~:text=databricks_cli_X.Y.Z_windows_amd64.zip
		○ Extract zip file and copy all files to C:\WorkSpace\databricks_cli
		○ Set Environment variable variable name = databricks , value = C:\WorkSpace\databricks_cli
		○ Now databricks cli is ready to use.
	• Setup AAD Token for Databricks.
		○ Login to azure using azure cli. (az login)
		○ Get aad token using azure cli
			§ $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
		○ Store this token as environment variable 
			§ Set-Item -Path Env:DATABRICKS_TOKEN -Value ($Env:DATABRICKS_TOKEN + "$aadtoken")
		○ Verify environment variables using 
			§ Get-ChildItem -Path Env:
		
			
Databricks PAT token:
	• Login to Databricks Workspace Ui from Azure Portal.
	• Navigate to Admin Settings -> Developer -> Access tokens. Create one PAT token.

Create Databricks secret scope using Databricks CLI:

Use Databricks CLI on local machine:
	• Login to Databricks
		○ Use command
			§ databricks configure
				□ It will ask for host and PAT token 
					® Host - https://adb-1639784005057929.9.azuredatabricks.net/ (databricks url)
					® Token - Use Databricks PAT token
	• Create secret scope
		○ Create scope command will use the environment variable "DATABRICKS_TOKEN" which is already created and stored.
		○ If any issues occurred, then recreate the environment variable "DATABRICKS_TOKEN" by following above mentioned process.
		○ Store all required information for creating Azure Key Vault backed secret scope in json file "C:\WorkSpace\databricks\databrickssecretscope.json". This file path will be used later for creating secret scope.
			
			{
			    "scope" : "test-dev-01",
			    "scope_backend_type": "AZURE_KEYVAULT",
			    "backend_azure_keyvault": {
			        "resource_id": "/subscriptions/d5496deb-247a-4fbb-9f62-47db0cf2cac9/resourceGroups/rg-entlake-dev-01/providers/Microsoft.KeyVault/vaults/kv-entlake-dev-01",
			        "dns_name": "https://kv-entlake-dev-01.vault.azure.net/"
			    }
			}
			
		○ Use command 
			§ databricks secrets create-scope --json @C:\WorkSpace\databricks\databrickssecretscope.json --initial-manage-principal users


Create Databricks secret scope using Terraform:

	• Login to Azure using azure cli.
	• Generate AAD Token 
		○ $aadtoken = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" -o tsv
	• Create provider.tf file with required providers. In provider "databricks" {} fill the required data as below
		
		provider "databricks" {
		  # Configuration options
		  host  = <--Databricks URL-->("https://adb-1639784005057929.9.azuredatabricks.net/")
		  token = <--AAD TOKEN--> (use AAD TOKEN which is generated after logging into Azure)
		}
		○ AAD Token can be set as variable and passed during the run time 
		○ Create a variable in variables.tf file
			
			variable "aad_token" {
			  type = string
			}
		○ Use the variable in provider.tf file
		
			provider "databricks" {
			  # Configuration options
			  host  = "https://adb-1639784005057929.9.azuredatabricks.net/"
			  token = var.aad_token
			}
		
		○ During the terraform apply use the following command
			§ For creating resource - terraform apply -auto-approve -var-file .\terraform.tfvars -var "aad_token=$aadtoken"
			§ For destroying the resource - terraform apply -destroy -auto-approve -var-file .\terraform.tfvars -var "aad_token=$aadtoken"  
		

		
Service Principal required for Terraform to create Databricks and it's secrets:

	• Create a service principal and assign Role "Cloud Application Administrator".
	• Service Principal used for creating Databricks and its secrets require "Cloud Application Administrator" Role.
	• Login to azure using Service Principal.
	• Create AAD Token and use that token for creating Databricks secrets.
	
![image](https://github.com/jagadish88t/Databricks-Project/assets/107781655/b94f1d85-0002-41f1-97c3-442399a49e96)
