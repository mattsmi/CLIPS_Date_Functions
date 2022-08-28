Date Functions for the CLIPS Expert System (rules engine) tool.
===============================================================

Errors are flagged by returning nil in most cases.

Earlier versions of these functions used the Unix time (i.e. seconds from the Unix Epoch) for the actual
date calculations. The functions now use the Chronological Julian Day Number (CJDN). They are thus only date functions;
they ignore the time.

UNIX Epoch date, where 0 = 1970-01-01T00:00:00Z (ISO 8601 format), is taken as the first date allowed in these calculation.

Date and Calendar Functions
---------------------------

- `isThisALeapYear`: checks for a Gregorian Leap Year. Returns TRUE, FALSE, or nil.
- `isThisAGLeapYear`: calls the function "isThisALeapYear".
- `isThisAnOLeapYear`: checks whether a year is a leap year on the Revised Julian (or Orthodox or Milanković) calendar.
- `isThisAJLeapYear`: checks whether a year is a leap year on the Julian calendar.
- `yearFromDateINT`: returns a year from a given date.
- `monthFromDateINT`: returns the month from a given date.
- `dayFromDateINT`: returns the day of the month from a given date.
- `unmakeDate`: converts a date (i.e. a CJDN) to an ISO 8601 date string (YYYY-MM-DD).
- `DoW`: returns the day of the week for a given date, where Monday = 1 and Sunday = 7.
- `clFindSun`: finds a Sunday between two given dates.
- `clFindSat`: finds a Saturday between two given dates.
- `makeTwoDigits`: returns a string two digits in length, when passed an integer. Helps prepare days and months for ISO 8601 strings.
- `daysAdd`: adds a number of days to a given date.
- `mkDate`: converts a ISO 8601 date string to a date (CJDN). Expects a year, a month, and a day of the month to be passed as arguments &mdash; all integers.
- `string-to-integer`: converts a string of digits to integers.
- `floor`: implements the mathematical floor function.
- `CalcDayDiffJulianCal`: calculates the difference between the Gregorian date passed in as an argument and the equivalent in the Julian calendar.
- `pGregorianToCJDN`: converts a date in the Gregorian calendar to its Chronological Julian Day Number (CJDN).
- `pCJDNToGregorian`: converts a CJDN to a date in the Gregorian calendar.
- `pMilankovicToCJDN`: converts a date in the Revised Julian calendar to its Chronological Julian Day Number.
- `pCJDNToMilankovic`: converts a CJDN to a date in the Revised Julian calendar.
- `pJulianToCJDN`: converts a date in the Julian calendar to its CJDN.
- `pCJDNToJulian`: converts a CJDN to a date in the Julian calendar.
- `mkODate`: converts a date in the Revised Julian calendar to a date string. Expects a year, a month, and a day of the month to be passed as arguments &mdash; all integers.
- `mkJDate`: converts a date in the Julian calendar to a date string. Expects a year, a month, and a day of the month to be passed as arguments &mdash; all integers.
- `mkDateForCurrentCal`: determines the type of calendar in use and calls the appropriate mkDate function.
- `NumDaysOfWeekBetwee`n: calculates the number of a given day of the week (e.g. a Monday) between two dates.


The calendar functions handle three calendars: Julian, Gregorian, Revised Julian (or Milanković) calendars. In doing so,
they depend on the following three global variable.
- `(defglobal ?*iEDM_JULIAN* = 1)`
- `(defglobal ?*iEDM_ORTHODOX* = 2)`
- `(defglobal ?*iEDM_WESTERN* = 3)`


To test these functions, execute the following commands within a CLIPS shell.
- `(batch* "global_stuff.clp") ; load globals`
- `(batch* "VariousDateFuncs.clp") ; load calendar functions`
- `(pGregorianToCJDN 2022 8 28) ; convert 28 April 2022 to CJDN`
- `(pCJDNToGregorian 2459820); convert the same CJDN to date` 
- `(DoW 2459820) ; Find the day of the week for 28 April 2022, Gregorian`


