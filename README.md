# SecretServerScripts
Trying to build scripts for Secret Server

Currently I just have a simple example of a custom AD Secret.  The final line is a comment of a sample usage of the script.

To make this work, you would need to change customizations to fit your environment, such as finding the ID of the secret template you want to create.
Customize the fields you want to change (including incoming parmaeters to match).
That is part of the reason I left the clumsy for loop in; you can use this as a break point to analyze what your field names are; and adjust the script based on that.

All the information is here to make a custom commandline script, that script can be imported into RunDeck by simply setting up properties and using 
a command that includes the ${options.propertyName} for each property you need to set (sorry, I could not get this done in a reasonable time, however, I will try to get a template matching this script up later).

To get your template id, simply go into SecretServer, choose to Create a secret of the type you want, and the secret Template ID will be in the URL.

Sample commandline for ad_secret_create.ps1:
.\ad_secret_create.ps1 -Site "https://secretserver.corp.com/SecretServer" -AuthName "corp.com\username" -AuthPass "Password#1" -Name "AddedUser" -ID "CmdlineTest" -Domain "corp.com" -Password "AddedUserPass#1" -Folder "\Personal Folders\username" -TemplateType 1234 -Primary "username@corp.com" -Secondary "otheruser@corp.com" -Usage "Meh" -Notes "Blah" -AutoChange $True
