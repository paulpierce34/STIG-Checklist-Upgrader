## The purpose of this script is to 'upgrade' a STIG checklist from one released version to the most recent version.




## REQUIREMENTS:
### - A new blank STIG checklist (the version you want to upgrade to)
### - An older, already completed STIG checklist (or directory of checklists) from a recent version of the STIG

## HOW TO USE:
# - Execute script, follow prompts

## USE CASE EXAMPLE:

## If you have a completed STIG checklist for "Microsoft Windows Server 2016 STIG-Ver 2,Rel 2" and  DISA releases Ver 2 Rel 3 tomorrow.... you can use this script to "upgrade" your old checklists to the newer version without having to re-do an entirely new checklist.
## This script checks for legacy IDs in the most recent version of the STIG, and then cross-references those to the old STIG to then fill out this new STIG checklist. 
## For validation purposes, any changes made to the rule contents on the new checklist, in comparison to your already-filled-out old checklist, will be marked as "Not Reviewed" on the upgraded checklists.



## BEGIN GLOBAL VARIABLES ##

$date = get-date -format yyyyhhmm


$fileorfolder = read-host "Are you upgrading a File or folder?: "


if ($fileorfolder -eq "folder"){

$targetdir = read-host "Please provide the directory where all OLD checklists can be found?: "

$eacholdckl = get-childitem $targetdir -file -filter "*.ckl" -name


}


if ($fileorfolder -eq "file"){

$oldckl = read-host "Please provide the full location for the old checklist file?: " ### C:\Users\example\Desktop\temp\New_completed\L3-AUG_30_NDM_L2_43250.ckl

}

$newckl = read-host "Please provide the full location for the new BLANK checklist file? (include blank filename): "

$Destination = read-host "Please provide the directory where you would like the new upgraded checklist(s) to be created?: "




foreach ($diffoption in $eacholdckl){

$oldckl = $targetdir + "\" + $diffoption

write-host $oldckl


#### FILEPATH FORMATTING 

## ValidatePath
if (test-path $oldckl){

[xml]$oldchecklist = get-content $oldckl

}
else {

write-host -Foregroundcolor Red "This is not a valid filepath. Please re-run the script with the correct filepath. Terminating script..."
break

}


$Strippedoldname = get-childitem $oldckl | foreach-object {$_.BaseName}


## ValidatePath
if (test-path $newckl){

[xml]$newchecklist = get-content $newckl

}

else {

write-host -Foregroundcolor Red "This is not a valid filepath. Please re-run the script with the correct filepath. Terminating script..."
break

}



 #### IF THIS IS A FILE
if ($fileorfolder -eq "file"){

if (Test-Path $Destination){

if ($Destination[-1] -ne "\"){

$FinalDestDir = $Destination + "\" + $oldckl + "upgradedchecklist.ckl"

}

else {

$FinalDestDir = $Destination + $oldckl + "upgradedchecklist.ckl"

}

}

else {

write-host -Foregroundcolor Red "This is not a valid output filepath. Please re-run the script with the correct filepath. Terminating script..."
break

}

} ## end of if file


#### IF THIS IS A FOLDER
if ($fileorfolder -eq "folder"){

if (Test-Path $Destination){

## ValidatePath

if ($Destination[-1] -ne "\"){

if ($newhostname -ne $null){

$FinalDestDir = $Destination + "\" + $Strippedoldname + "upgradedckl.ckl"

}

else {

$FinalDestDir = $Destination + "\" + $Strippedoldname + "newupgraded" + ".ckl"

}

}

else {

$FinalDestDir = $Destination + $Strippedoldname + "upgradedckl.ckl"

}

}

else {

write-host -Foregroundcolor Red "This is not a valid output filepath. Please re-run the script with the correct filepath. Terminating script..."
break

}

}  ## end of if folder


#### FILEPATH FORMATTING END #####  ##########  ##########  ##########  ##########  ##########  ##########  ##########  ##########  ##########  ##########  ##########  ##########  #####

## XML Settings to replicate those of STIGViewer #######################################################################################################################
$XMLSettings = New-Object -TypeName System.XML.XMLWriterSettings
$XMLSettings.Indent = $true;
$XMLSettings.IndentChars = "`t"
$XMLSettings.NewLineChars="`n"
$XMLSettings.Encoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList @($false)
$XMLSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document
### End of STIGViewer settings ########################################################################################################################################


$oldhostname = $oldchecklist.selectsinglenode("//HOST_NAME").innerxml


## BEGIN EXTRACTING FROM OLD CHECKLIST ##

$oldvulnarray = @()

$oldresultarray = @()

$vulnIDs = $oldchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Vuln_Num']")

$openornot = $oldchecklist.selectNodes("//VULN[STATUS]")

$extractstatus = $openornot.status

$extractvulnIDs = $vulnIDs.Attribute_data

$oldresultarray += $extractstatus

$oldvulnarray += $extractvulnIDs

### END OLD CHECKLIST EXTRACTION ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ##########



## New checklist  ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ########## ##########

##new checklist --- grabbing legacy vulnerability IDs, then going to match them with the old vuln numbers, and from there take the results of the old STIG and write them to the new checklist results

$newopenornot = $newchecklist.selectNodes("//VULN[STATUS]")

$newvalues = $newopenornot.Status

$newvulnIDs = $newchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Vuln_Num']")

$legacyvulnIDs = $newchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='LEGACY_ID']") #| select -Property ATTRIBUTE_DATA

## Legacy vuln ID array
$legacyarray += $legacyvulnIDs

## Legacy rule ID array 
$legacyruleID += $legacyvulnIDs

[System.Collections.ArrayList]$FinalLegacy=@()

[System.Collections.ArrayList]$FinalRuleLegacy=@()

## This for loop grabs every even index (including zero) of the legacyvulnids array.... to eliminate the SV- options which are found at odd intervals ##
for ($x =0; $x -lt $legacyvulnids.count; $x++){

while ($x % 2 -eq 0){

$legelmt = $legacyvulnids[$x]

$FinalLegacy.add($legelmt)

$x++

}
}




### The array $FinalLegacy is built, which has all of just the legacy IDs


$newfinallegacy = $Finallegacy.attribute_data
$newvulnidarray = $newvulnids.attribute_data

## Time to compare oldvulnids with newfinallegacy array elements
$allstatus = $newchecklist.GetElementsByTagName('STATUS')


$allfindingdetails = $newchecklist.GetElementsByTagName('FINDING_DETAILS')
$oldfindingdetails = $oldchecklist.GetElementsByTagName('FINDING_DETAILS')



$newcomments = $newchecklist.GetElementsByTagName('COMMENTS')
$oldcomments = $oldchecklist.GetelementsByTagName('COMMENTS')


$oldcommentstext = $oldcomments.innerxml

$findoldhostname = $oldchecklist.selectsinglenode("//HOST_NAME").innerxml

$setnewhostname = $newchecklist.selectsinglenode("//HOST_NAME")

$writenewhost = $setnewhostname.innertext = "$findoldhostname"


## Get inner xml for each of the finding details (new/old checklists)
$newfindingdetails = $allfindingdetails.innerxml
$oldfindings = $oldfindingdetails.innerxml





for ($y=0; $y -lt $oldvulnarray.Length + 1; $y++){

if ($oldvulnarray -contains $newfinallegacy[$y]){

# Status
$allstatus[$y].innerText = $oldresultarray[$y]

# Finding Details
$allfindingdetails[$y].innerText = $oldfindings[$y]

# Comments
$newcomments[$y].innerText = $oldcommentstext[$y]

}

if ($oldvulnarray -contains $newvulnidarray[$y]){

# Status
$allstatus[$y].innerText = $oldresultarray[$y]

# Finding Details
$allfindingdetails[$y].innerText = $oldfindings[$y]

# Comments
$newcomments[$y].innerText = $oldcommentstext[$y]

}

}

############### ############### ############### ############### ############### ############### ############### ###############
## Let's build some Rule ID Logic for future STIG Upgrades ##

$oldrules = $oldchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Rule_ID']")
$newrules = $newchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Rule_ID']")

$oldrulearray = $oldrules.Attribute_data
$newrulearray = $newrules.Attribute_data


$oldruletext = $oldchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Rule_Title']")
$newruletext = $newchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Rule_Title']")

$oldruletextarray = $oldruletext.Attribute_data
$newruletextarray = $newruletext.Attribute_data

## This pulls all of the odd numbered indexes in the legacyvulnids array  (aka the Rule IDs)
for ($z = 0; $z -lt $legacyvulnids.count; $z++){

while ($z % 2 -eq 1){

$legelmtrule = $legacyvulnids[$z]

$FinalRuleLegacy.add($legelmtrule)

$z++

}
}

## Getting the legacy rules to look the same as the old rule Id's --- for example, adding "_rule" to after each number
$onlylegacyrules = $FinalRuleLegacy.Attribute_data

$completedlegacyrulearrayr1 = @()
$completedlegacyrulearrayr2 = @()

foreach ($legrule in $onlylegacyrules) {

$addingending = $legrule + "r1" + "_rule"

$completedlegacyrulearrayr1 += $addingending

$addingendingr2 = $legrule + "r2" + "_rule"

$completedlegacyrulearrayr2 += $addingendingr2

}



for ($r=0; $r -lt $newvulnidarray.count; $r++){

if ($oldrulearray -contains $newrulearray[$r] -or $oldrulearray -contains $completedlegacyrulearrayr1[$r] -or $oldrulearray -contains $completedlegacyrulearrayr2[$r]){

## continue

}

else {

# $allstatus[$r].innerText = "Not_Reviewed"   #   In the future, this is where you can have these marked as "not reviewed" if the rule ID changes. Just not sure how the rule IDs will vary in the future since this is first release of new STIG templates. Release date 10-23-2020
## May not even need to check this logic given the below logic where we check the Rule Text itself 
}


if ($oldruletextarray -contains $newruletextarray[$r]){

## continue

}
else {

$allstatus[$r].innerText = "Not_Reviewed"    ## Mark as not reviewed if the rule title text changes in the STIG
$allfindingdetails[$r].innerText += "$date Re-review, Rule Changed" 
}


}
############   what im thinking ---  check if old rule ID matches new rule ID OR new legacy rule ID, if it does -- no changes needed. 
############   If doesn't match either, needs to be marked at not reviewed as this means there was content changes within the check_content section.



 ############### ############### ############### ############### ############### ############### ############### ############### ############### ############### ############### ############### ############### ############### ###############

## Creates the XML doc
$XMLWriter = [System.XML.XmlWriter]::Create($FinalDestDir, $XMLSettings)  ## creates file at $Destination location with $XMLSettings -- (blank)
$newchecklist.Save($XMLWriter) ## Saves the extract document changes above to the xml writer object (which follows the validation scheme for STIG viewer)
$XMLWriter.Flush()
$XMLWriter.Dispose()






### Prepare text for produce-log function as well as make-archive function ###########################################  ###########################################  ###########################################  ###########################################



## Grab stig title from new checklist for log file
$stigtitle = $newchecklist.selectNodes("//SI_DATA[SID_NAME='stigid']")
## Convert stig title to just the actual name
$stigtitletext = $stigtitle.SID_DATA


## Grab hostname for log file
$newhostname = $oldchecklist.selectsinglenode("//HOST_NAME").innerxml


## Get the total count of vulnerabilities for log file
$newvulncount = $newrules.count


## Get version

$stigversion = $newchecklist.selectNodes("//SI_DATA[SID_NAME='version']")
$stigrelease = $newchecklist.selectNodes("//SI_DATA[SID_NAME='releaseinfo']")

$stigversiontext = $stigversion.SID_Data
$stigreleasetext = $stigrelease.SID_Data


## Get the severity (category) of each item ##

$cat1 = 0
$cat2 = 0
$cat3 = 0

$severityarray = $newchecklist.selectNodes("//STIG_DATA[VULN_ATTRIBUTE='Severity']")

$severerating = $severityarray.Attribute_data

foreach ($severity in $severerating){

if ($severity -eq "high"){

$cat1 += 1

}
if ($severity -eq "medium"){

$cat2 += 1

}

if ($severity -eq "low"){

$cat3 += 1

}

}




Function Create-Archive{

cd "$Destination"
mkdir Archive
mv $oldckl "Archive"

}

Function Produce-Log {

if ($Destination[-1] -eq "\"){

$LogDest = $Destination + $date + "Upgraderlog" + ".log"

}
else {

$LogDest = $Destination + "\" + $date + "Upgraderlog" + ".log"

}

 ## Now that the log destination is settled, time for logic to write to .txt file 

write-output "STIG Title: $stigtitletext" >> $LogDest
write-output "STIG Version: $stigversiontext" >> $LogDest
write-output "STIG Release - $stigreleasetext`n`n" >> $LogDest
write-output "Host Name: $newhostname" >> $LogDest
write-output "Created: $FinalDestDir" >> $LogDest
write-output "Vulnerabilities Read: $newvulncount" >> $LogDest
write-output "Cat I: $cat1" >> $LogDest
write-output "Cat II: $cat2" >> $LogDest
write-output "Cat III: $cat3" >> $LogDest



if (Test-Path $LogDest){

write-host "Created Log file here: $LogDest"

}
else {

write-host -foregroundcolor red "Had some trouble attempting to create log file here: $LogDest .    Can you confirm this is a valid filepath?"

}


} ## end Produce-Log function

Produce-Log

}
