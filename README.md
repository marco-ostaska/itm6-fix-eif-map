# itm6-fix-eif-map

* When you are creating/editing an ITM6 situation, if you click `ok` on "Edit EIF", you can change hthe mapping and it may cause problems in some situations.

* This script check for potential mapping changes and set it back to its original.

## Usage:

`./fixeifmap.sh <string to grep> <opt>` 

###  "example:"

`./fixeifmap.sh all_fss -fix` : this example will search errors in all situations with all_fss and fix it"

#### < opt >

* **-fix** - search potential errors and fix it
* **-report** - just verify for potential errors but don't fix it
* **-fixfile** - runs report and generate fix file but does not run the fix itself
* **-help** - display this screen :-p
