/*
*/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

say " If you have XWorkPlace or eWorkPlace this script will add an 'URL'"
say " item to the 'Create new' submenu of the objects context menu."
say " If you do not have any WPS extension installed an ordinary program"
say " object will be created on your desktop."
say " To abort the installation press Ctrl+C or close the window."
"@pause"

progPath = directory();
class = "WPProgram";
title = "URL"
if ObjectExists("<XWP_CFG2>") then
   location = "<XWP_CFG2>";
else
   location = "<WP_DESKTOP>";
setup = "EXENAME="progPath"\NEWURL.EXE"
option = "U";
if (\ SysCreateObject(class, title, location, setup, option)) then
   say " Failed to create the program objec in: "location
else
   say " The program object was succesfully created in the "location" folder"
"@pause"
exit

/* ------------------------------------------------------------------------- */
ObjectExists: procedure
   parse arg objectID
   rc = SysIni("USER", "PM_Workplace:Location", objectID);

return rc \= "ERROR:"
