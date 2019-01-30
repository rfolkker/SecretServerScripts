param(
    [Parameter(Mandatory=$True)]
    [string]$Site,
    [Parameter(Mandatory=$True)]
    [string]$AuthUser,
    [Parameter(Mandatory=$True)]
    [string]$AuthPass,
    [Parameter(Mandatory=$True)]
    [string]$Name,
    [Parameter(Mandatory=$True)]
    [string]$ID,
    [Parameter(Mandatory=$True)]
    [string]$Domain,
    [Parameter(Mandatory=$True)]
    [string]$Password,
    [Parameter(Mandatory=$True)]
    [Int32]$TemplateType,
    [Parameter(Mandatory=$True)]
    [string]$Primary,
    [Parameter(Mandatory=$True)]
    [string]$Secondary,
    [Parameter(Mandatory=$True)]
    [String]$Usage,
    [Parameter(Mandatory=$True)]
    [String]$Folder,
    [Parameter(Mandatory=$False)]
    [String]$Notes=,
    [Parameter(Mandatory=$False)]
    [Boolean]$AutoChange=$False
)

function createSecret{
    try
    {  
       $api = "$Site/api/v1"
       $creds = @{
           username = $AuthUser
           password = $AuthPass
           grant_type = "password"
       }
    
        $token = ""

        $response = Invoke-RestMethod "$site/oauth2/token" -Method Post -Body $creds
        $token = $response.access_token;

        Write-Host $token

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $token")
        # Find folder
        $folderSearchFilter ="?filter.folderPath=$($Folder)"
        $folderSearchResults = Invoke-RestMethod $api"/folders$($folderSearchFilter)" -Method GET -Headers $headers -ContentType "application/json"
        $folder = $folderSearchResults.records[0]

        #stub
        $templateId = $TemplateType # Found by looking in URL after selecting to create a secret from web
        $secret = Invoke-RestMethod $api"/secrets/stub?filter.secrettemplateid=$templateId&filter.folderId=121" -Headers $headers

        #modify
        $timestamp = Get-Date
    
        $secret.name = $Name
        $secret.secretTemplateId = $templateId
        $secret.AutoChangeEnabled = $AutoChange
        ## $secret.autoChangeNextPassword = "$($Password)"
        $secret.SiteId = 1
                                          
        ## $secret.IsDoubleLock = $true

        foreach($item in $secret.items)
        {
          if($item.fieldName -eq "Domain")
          {
              $item.itemValue = "$($Domain)"
          }
          if($item.fieldName -eq "Username")
          {
              $item.itemValue = "$($ID)"
          }
          if($item.fieldName -eq "Password")
          {
              $item.itemValue = "$($Password)"
          }
          if($item.fieldName -eq "Notes")
          {
              $item.itemValue = "$($Notes)"
          }  
          if($item.fieldName -eq "AccountPrimary")
          {
              $item.itemValue = "$($Primary)"
          }  
          if($item.fieldName -eq "AccountSecondary")
          {
              $item.itemValue = "$($Secondary)"
          }  
          if($item.fieldName -eq "Account Usage")
          {
              $item.itemValue = "$($Usage)"
          }  
        }

        $body = ConvertTo-Json $secret

        #create
        Write-Host ""
        Write-Host "-----Create secret -----"

        $secret = Invoke-RestMethod $api"/secrets/" -Method Post -Body $body -Headers $headers -ContentType "application/json"

        $secret1 = $secret | ConvertTo-Json
        Write-Host $secret1
        Write-Host $secret.id
    }
    catch [System.Net.WebException]
    {
        Write-Host "----- Exception -----"
        Write-Host  $_.Exception
        Write-Host  $_.Exception.Response.StatusCode
        Write-Host  $_.Exception.Response.StatusDescription
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()

        Write-Host $responseBody 
    }
}

createSecret
# e.g.
# .\ad_secret_create.ps1 -Site "https://secretserver.corp.com/SecretServer" -AuthName "corp.com\username" -AuthPass "Password#1" -Name "AddedUser" -ID "CmdlineTest" -Domain "corp.com" -Password "AddedUserPass#1" -Folder "\Personal Folders\username" -TemplateType 1234 -Primary "username@corp.com" -Secondary "otheruser@corp.com" -Usage "Meh" -Notes "Blah" -AutoChange $True
