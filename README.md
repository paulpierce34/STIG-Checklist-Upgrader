# STIG-Checklist-Upgrader

Use this script to 'upgrade' your DISA STIG checklist(s) from a previous version to a newer version.

Instead of having to re-do an entire checklist manually when DISA releases a new version, you can use this script to complete the newer checklist, and mark any changes as Not Reviewed.

For additional validation, any changes to the rule contents on the new checklist, in comparison to your already-filled-out old checklist, will be marked as Not Reviewed.


REQUIREMENTS:
- A blank .ckl file of the new STIG checklist
- An already completed previous version of the STIG .ckl file (or directory)
- Powershell

HOW TO USE:

- Execute script

- You will be prompted for the location to the new .ckl, old .ckl, and desired output directory.
