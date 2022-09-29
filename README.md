# STIG-Checklist-Upgrader

Use this script to 'upgrade' your DISA STIG checklist(s) from a previous version to a newer version.

Instead of having to re-do an entire checklist manually when DISA releases a new version, you can use this script to complete the newer checklist, and mark any new items as Not Reviewed.

For additional validation; any changes to the rule contents on the new STIG version, in comparison to your already-filled-out old checklist, will be marked as Not Reviewed.

Old checklist files are not altered during execution of this script and will be Archived in an 'Archive' folder created in the destination output directory.

REQUIREMENTS:
- A blank .ckl file of the new STIG checklist
- An already completed previous version of the STIG .ckl file (or directory)
- Powershell

HOW TO USE:

- Execute script

- You will be prompted for the location to the blank new version of the STIG checklist, the filepath of the completed checklist (or directory path) and desired output directory.



2022 UPDATE: I've recently learned that in newer versions (perhaps even older versions??) of STIGviewer you can upgrade checklists one at a time by opening the STIG checklist in STIG viewer, selecting the 'Import' tab in the top left, and then selecting 'Checklist Data'. This will import an older checklists data into your current checklist. Therefore this script is somewhat obsolete, HOWEVER you can use this script to upgrade an entire folder of checklists at a time. Enjoy!
