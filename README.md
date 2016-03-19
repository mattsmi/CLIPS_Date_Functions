Date Functions for the CLIPS Expert System (rules engine) tool.
===============================================================

Errors are flagged by returning nil in most cases.
UNIX Epoch date, where 0 = 1970-01-01T00:00:00Z (ISO 8601 format), is taken as the first date allowed in these calculation.

Date and Calendar Functions
---------------------------

- `isThisALeapYear`: checks for a Gregorian Leap Year. Returns TRUE, FALSE, or nil.
- `isThisAGLeapYear`: calls the function "isThisALeapYear".
- `isThisAnOLeapYear`: checks whether a year is a leap year on the Revised Julian (or Orthodox or Milanković) calendar.
- `isThisAJLeapYear`: checks whether a year is a leap year on the Julian calendar.
- `yearFromDateINT`: returns a year from a given UNIX date (i.e. the number of seconds since the UNIX Epoch date).
- `monthFromDateINT`: returns the month from a given UNIX date.
- `dayFromDateINT`: returns the day of the month from a given UNIX date.
- `unmakeDate`: converts a UNIX date to an ISO 8601 date string (YYYY-MM-DD).
- `DoW`: returns the day of the week for a given UNIX date, where Monday = 1 and Sunday = 7.
- `clFindSun`: finds a Sunday between two given UNIX dates.
- `clFindSat`: finds a Saturday between two given UNIX dates.
- `makeTwoDigits`: returns a string two digits in length, when passed an integer. Helps prepare days and months for ISO 8601 strings.
- `daysAdd`: adds a number of days to a given UNIX date.
- `mkDate`: converts a date to a UNIX date. Expects a year, a month, and a day of the month to be passed as arguments -- all integers.
string-to-integer: converts a string of digits to integers.
- `floor`: implements the mathematical floor function.
CalcDayDiffJulianCal: calculates the difference between the Gregorian date passed in as an argument and the equivalent in the Julian calendar.
- `pGregorianToCJDN`: converts a date in the Gregorian calendar to its Chronological Julian Day Number.
- `pCJDNToGregorian`: converts a CJDN to a date in the Gregorian calendar.
- `pMilankovicToCJDN`: converts a date in the Revised Julian calendar to its Chronological Julian Day Number.
- `pCJDNToMilankovic`: converts a CJDN to a date in the Revised Julian calendar.
- `pJulianToCJDN`: converts a date in the Julian calendar to its CJDN.
- `pCJDNToJulian`: converts a CJDN to a date in the Julian calendar.
- `mkODate`: converts a date in the Revised Julian calendar to a UNIX date. Expects a year, a month, and a day of the month to be passed as arguments -- all integers.
- `mkJDate`: converts a date in the Julian calendar to a UNIX date. Expects a year, a month, and a day of the month to be passed as arguments -- all integers.
- `mkDateForCurrentCal`: determines the type of calendar in use and calls the appropriate mkDate function.
- `NumDaysOfWeekBetwee`n: calculates the number of a given day of the week (e.g. a Monday) between two UNIX dates. 


The calendar functions handle three calendars: Julian, Gregorian, Revised Julian (or Milanković) calendars.
