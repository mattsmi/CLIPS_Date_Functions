;####################################################################################
;### These functions are used to manipulate and work with dates in CLIPS.         ###
;### As at v. 6.30, CLIPS has no internal date functions and these must be        ###
;###    supplied by internal CLIPS functions or external functions from the       ###
;###    surrounding programming language or scripting language.                   ###
;###                                                                              ###
;### All these functions are internal CLIPS functions and do not depend on any    ###
;###    external language or operating system.                                    ###
;###                                                                              ###
;### NB I have used the UNIX Epoch date as a starting point, and these functions  ###
;###    report an error, if the date requested is earlier than the UNIX Epoch     ###
;###    date. The UNIX Epoch or POSIX date is: 0000, 1 January 1970 UTC.          ###
;###    POSIX time counts in seconds, but ignores leap seconds. In ISO 8601       ###
;###    format, the UNIX Epoch date is: 1970-01-01T00:00:00Z.                     ###
;###    Where dates are strings, the functions use and expect ISO 8601.           ###
;####################################################################################

(deffunction isThisALeapYear
    (?baseYear)
    
    ;NB This functions for the Gregorian Calendar only.
    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    ;We assume the following definition of a Leap Year (or intercalary or bissextile year),
    ;   as defined in the Gregorian Calendar:
    ;      1. February has 28 days each year, but 29 in a Leap Year.
    ;      2. All years, except century years, that are evenly divisible by 4 are Leap Years.
    ;      3. Only century years evenly divisible by 400 are Leap Years.
    ;We may ignore the fact that the Gregorian calendar began in 1582 and in other years for
    ;   some countries, as our system date does not allow dates before 1970.
    
    ;Check that the argument is numeric
    (if (not (integerp ?baseYear)) then
        (return nil)
    )
    ;Check for legal values
    (if (< ?baseYear 1970) then
        (return nil)
    )
    
    ;Check for leap centuries, then leap years that are not centuries.
    (if (= (mod ?baseYear 400) 0) then
        ;We have a Leap Year century
        (return TRUE)
    )
    (if (= (mod ?baseYear 100) 0) then
        ;We have a standar year century
        (return FALSE)
    )
    (if (= (mod ?baseYear 4) 0) then
        ;We have a leap year that is not a century.
        (return TRUE)
    )
    
    ;If not a leap year, we fall out here.
    (return FALSE)
    
)
(deffunction isThisAGLeapYear
    (?baseYear)
	;Function for determining whether this year is a leap year
	;   according to the Gregorian calendar.
	
	(return (isThisALeapYear ?baseYear))
)
(deffunction isThisAnOLeapYear
    (?baseYear)
    ;Orthodox Leap Year or Revised Julian Leap Year:
    ; if year divisible by 100, then if remainder 200 or 600, when divided by 900
    ; if year divisible by 4, but not 100.
    
     ;Check that the argument is numeric
    (if (not (integerp ?baseYear)) then
        (return nil)
    )
    ;Check for legal values
    (if (< ?baseYear 1970) then
        (return nil)
    )
    
    ;Check for centuries
    (if (= (mod ?baseYear 100) 0) then
	(if (or (= (mod ?baseYear 900) 200) (= (mod ?baseYear 900) 600)) then
	    (return TRUE)
	else
	    (return FALSE)
	)
    )
    
    (if (= (mod ?baseYear 4) 0) then
        ;We have a leap year that is not a century.
        (return TRUE)
    )
    
    ;If not a leap year, we fall out here.
    (return FALSE)
)
(deffunction isThisAJLeapYear
    (?baseYear)
    
    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    ;We assume the following definition of a Leap Year (or intercalary or bissextile year),
    ;   as defined in the Julian Calendar:
    ;      1. February has 28 days each year, but 29 in a Leap Year.
    ;      2. All years that are evenly divisible by 4 are Leap Years.
    
    ;Check that the argument is numeric
    (if (not (integerp ?baseYear)) then
        (return nil)
    )
    ;Check for legal values
    (if (< ?baseYear 1970) then
        (return nil)
    )
    
    (if (= (mod ?baseYear 4) 0) then
        ;We have a leap year.
        (return TRUE)
    )
    
    ;If not a leap year, we fall out here.
    (return FALSE)
    
)
(deffunction yearFromDateINT
    (?dDate)
    (if (not (integerp ?dDate)) then
        (return nil)
    )

    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    ;Assumes the Gregorian year.
    
    ;To save some calculation time, we pre-calculate these base variables
    (bind ?yearSeconds 31536000) ; 365 * 24 * 60 * 60 . Number of seconds in a standard calendar year.
    (bind ?leapYearSeconds 31622400) ; 366 * 24 * 60 * 60 . Number of seconds in a leap year.
    (bind ?baseDate 0) ; 01 January 1970, 00.00 UTC.

    
    ;Check that the arguments are numeric
    (if (not (integerp ?dDate)) then
        (return nil)
    )
    ;Check that date is later than the epoch date
    (if (< ?dDate 0) then
        (return nil)
    )
    
    ;Loop through subtracting years until we find the year
    (bind ?iYear 1970) ; we assume beginning year to be 1970
    (bind ?iCounter ?dDate)
    (while (>= ?iCounter ?yearSeconds)
        (bind ?iYear (+ ?iYear 1))
        (bind ?bIsThisALeapYear (isThisALeapYear (- ?iYear 1)))
        (if (eq ?bIsThisALeapYear TRUE) then
            (bind ?iCounter (- ?iCounter ?leapYearSeconds))
        else
            (bind ?iCounter (- ?iCounter ?yearSeconds))
        )
        (if (< ?iCounter 0) then
            (bind ?iYear (- ?iYear 1))
        )
    )

    ?iYear
    
)

(deffunction monthFromDateINT
    (?dDate)
    (if (not (integerp ?dDate)) then
        (return nil)
    )

    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    
    ;To save some calculation time, we pre-calculate these base variables
    (bind ?yearSeconds 31536000) ; 365 * 24 * 60 * 60 . Number of seconds in a standard calendar year.
    (bind ?leapYearSeconds 31622400) ; 366 * 24 * 60 * 60 . Number of seconds in a leap year.
    (bind ?baseDate 0) ; 01 January 1970, 00.00 UTC.
    ;Pre-calculated: months of 31 days have 2678400 seconds; months of 30 days have 2592000 seconds.
    ;                months of 29 days have 2505600 seconds; months of 28 days have 2419200 seconds.
    (bind ?month31days 2678400)
    (bind ?month30days 2592000)
    (bind ?month29days 2505600)
    (bind ?month28days 2419200)
    
    ;Check that the arguments are numeric
    (if (not (integerp ?dDate)) then
        (return nil)
    )
    ;Check that date is later than the epoch date
    (if (< ?dDate 0) then
        (return nil)
    )
    
    ;Loop through subtracting years until we find the year
    (bind ?iYear 1970) ; we assume beginning year to be 1970
    (bind ?iCounter ?dDate)
    (while (>= ?iCounter ?yearSeconds)
        (bind ?iYear (+ ?iYear 1))
        (bind ?bIsThisALeapYear (isThisALeapYear (- ?iYear 1)))
        (if (eq ?bIsThisALeapYear TRUE) then
            (bind ?iCounter (- ?iCounter ?leapYearSeconds))
        else
            (bind ?iCounter (- ?iCounter ?yearSeconds))
        )
        (if (< ?iCounter 0) then
            (bind ?iYear (- ?iYear 1))
        )
    )

	;Cover off the situation at the end of the year
	(if (= ?iCounter -86400) then
		;If 31 Dec of the year is exact, we may end up with a negative value.
		(if ?bIsThisALeapYear then
			(bind ?iCounter (- ?leapYearSeconds 1))
		else
			(bind ?iCounter (- ?yearSeconds 1))
		)
	)
	
    ;Reset Is this a Leap Year to this year, as we are now processing the months.
    (bind ?bIsThisALeapYear (isThisALeapYear ?iYear))
    (bind ?iCounter (+ ?iCounter 1)) ; push it into the next day by one second, so the real date is obvious
    ;Subtract the values for months until we have the month	
    (bind ?iMonth 01)
    (if (<= ?iCounter ?month31days) then
        (bind ?iMonth 01) ; January
    else
        (bind ?iCounter (- ?iCounter ?month31days))        
        (if (eq ?bIsThisALeapYear TRUE) then
            (if (<= ?iCounter ?month29days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month29days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        else
            (if (<= ?iCounter ?month28days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month28days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        )
    )

    ?iMonth
)

(deffunction dayFromDateINT
    (?dDate)
    (if (not (integerp ?dDate)) then
        (return nil)
    )

    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    
    ;To save some calculation time, we pre-calculate these base variables
    (bind ?yearSeconds 31536000) ; 365 * 24 * 60 * 60 . Number of seconds in a standard calendar year.
    (bind ?leapYearSeconds 31622400) ; 366 * 24 * 60 * 60 . Number of seconds in a leap year.
    (bind ?baseDate 0) ; 01 January 1970, 00.00 UTC.
    ;Pre-calculated: months of 31 days have 2678400 seconds; months of 30 days have 2592000 seconds.
    ;                months of 29 days have 2505600 seconds; months of 28 days have 2419200 seconds.
    (bind ?month31days 2678400)
    (bind ?month30days 2592000)
    (bind ?month29days 2505600)
    (bind ?month28days 2419200)
    
    ;Check that the arguments are numeric
    (if (not (integerp ?dDate)) then
        (return nil)
    )
    ;Check that date is later than the epoch date
    (if (< ?dDate 0) then
        (return nil)
    )
    
    ;Loop through subtracting years until we find the year
    (bind ?iYear 1970) ; we assume beginning year to be 1970
    (bind ?iCounter ?dDate)
    (while (>= ?iCounter ?yearSeconds)
        (bind ?iYear (+ ?iYear 1))
        (bind ?bIsThisALeapYear (isThisALeapYear (- ?iYear 1)))
        (if (eq ?bIsThisALeapYear TRUE) then
            (bind ?iCounter (- ?iCounter ?leapYearSeconds))
        else
            (bind ?iCounter (- ?iCounter ?yearSeconds))
        )
        (if (< ?iCounter 0) then
            (bind ?iYear (- ?iYear 1))
        )
    )
    
	;Cover off the situation at the end of the year
	(if (= ?iCounter -86400) then
		;If 31 Dec of the year is exact, we may end up with a negative value.
		(if ?bIsThisALeapYear then
			(bind ?iCounter (- ?leapYearSeconds 1))
		else
			(bind ?iCounter (- ?yearSeconds 1))
		)
	)
	
    ;Reset Is this a Leap Year to this year, as we are now processing the months.
    (bind ?bIsThisALeapYear (isThisALeapYear ?iYear))
    (bind ?iCounter (+ ?iCounter 1)) ; push it into the next day by one second, so the real date is obvious
    ;Subtract the values for months until we have the month
    (bind ?iMonth 01)
    (if (<= ?iCounter ?month31days) then
        (bind ?iMonth 01) ; January
    else
        (bind ?iCounter (- ?iCounter ?month31days))        
        (if (eq ?bIsThisALeapYear TRUE) then
            (if (<= ?iCounter ?month29days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month29days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        else
            (if (<= ?iCounter ?month28days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month28days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        )
    )
    
    ;Now count the days within the month.
    ;   We add two to the result: one for the day from midnight; one because we count starting from one not zero.
    (bind ?iDay (+ (div ?iCounter (* 24 60 60)) 0)) ; ignore the time of day.
    (if (> (mod ?iCounter (* 24 60 60)) 0) then
        (bind ?iDay (+ ?iDay 1))
    )
    
    ?iDay    
)

(deffunction unmakeDate
    (?dDate)
    (if (not (integerp ?dDate)) then
        (return nil)
    )

    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    
    ;To save some calculation time, we pre-calculate these base variables
    (bind ?yearSeconds 31536000) ; 365 * 24 * 60 * 60 . Number of seconds in a standard calendar year.
    (bind ?leapYearSeconds 31622400) ; 366 * 24 * 60 * 60 . Number of seconds in a leap year.
    (bind ?baseDate 0) ; 01 January 1970, 00.00 UTC.
    ;Pre-calculated: months of 31 days have 2678400 seconds; months of 30 days have 2592000 seconds.
    ;                months of 29 days have 2505600 seconds; months of 28 days have 2419200 seconds.
    (bind ?month31days 2678400)
    (bind ?month30days 2592000)
    (bind ?month29days 2505600)
    (bind ?month28days 2419200)
    
    ;Check that the arguments are numeric
    (if (not (integerp ?dDate)) then
        (return nil)
    )
    ;Check that date is later than the epoch date
    (if (< ?dDate 0) then
        (return nil)
    )
    
    ;Loop through subtracting years until we find the year
    (bind ?iYear 1970) ; we assume beginning year to be 1970
    (bind ?iCounter ?dDate)
    (while (>= ?iCounter ?yearSeconds)
        (bind ?iYear (+ ?iYear 1))
        (bind ?bIsThisALeapYear (isThisALeapYear (- ?iYear 1)))
        (if ?bIsThisALeapYear then
            (bind ?iCounter (- ?iCounter ?leapYearSeconds))
        else
            (bind ?iCounter (- ?iCounter ?yearSeconds))
        )
        (if (< ?iCounter 0) then
            (bind ?iYear (- ?iYear 1))
        )
    )
    (bind ?sTempDate ?iYear) ; Begin setting up the string form of the date.
    ;Cover off the situation at the end of the year
	(if (= ?iCounter -86400) then
		;If 31 Dec of the year is exact, we may end up with a negative value.
		(if ?bIsThisALeapYear then
			(bind ?iCounter (- ?leapYearSeconds 1))
		else
			(bind ?iCounter (- ?yearSeconds 1))
		)
	)
	
    ;Reset Is this a Leap Year to this year, as we are now processing the months.
    (bind ?bIsThisALeapYear (isThisALeapYear ?iYear))
	(bind ?iCounter (+ ?iCounter 1)) ; push it into the next day by one second, so the real date is obvious
    ;Subtract the values for months until we have the month
    (bind ?iMonth 01)
    (if (<= ?iCounter ?month31days) then
        (bind ?iMonth 01) ; January
    else
        (bind ?iCounter (- ?iCounter ?month31days))        
        (if (eq ?bIsThisALeapYear TRUE) then
            (if (<= ?iCounter ?month29days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month29days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        else
            (if (<= ?iCounter ?month28days) then
                (bind ?iMonth 02) ; February
            else
                (bind ?iCounter (- ?iCounter ?month28days))
                (if (<= ?iCounter ?month31days) then
                    (bind ?iMonth 03) ; March
                else
                    (bind ?iCounter (- ?iCounter ?month31days))
                    (if (<= ?iCounter ?month30days) then
                        (bind ?iMonth 04) ; April
                    else
                        (bind ?iCounter (- ?iCounter ?month30days))
                        (if (<= ?iCounter ?month31days) then
                            (bind ?iMonth 05) ; May
                        else
                            (bind ?iCounter (- ?iCounter ?month31days))
                            (if (<= ?iCounter ?month30days) then
                                (bind ?iMonth 06) ; June
                            else
                                (bind ?iCounter (- ?iCounter ?month30days))
                                 (if (<= ?iCounter ?month31days) then
                                    (bind ?iMonth 07) ; July
                                else
                                    (bind ?iCounter (- ?iCounter ?month31days))
                                    (if (<= ?iCounter ?month31days) then
                                        (bind ?iMonth 08) ; August
                                    else
                                        (bind ?iCounter (- ?iCounter ?month31days))
                                         (if (<= ?iCounter ?month30days) then
                                            (bind ?iMonth 09) ; September
                                        else
                                            (bind ?iCounter (- ?iCounter ?month30days))
                                             (if (<= ?iCounter ?month31days) then
                                                (bind ?iMonth 10) ; October
                                            else
                                                (bind ?iCounter (- ?iCounter ?month31days))
                                                 (if (<= ?iCounter ?month30days) then
                                                    (bind ?iMonth 11) ; November
                                                else
                                                    (bind ?iCounter (- ?iCounter ?month30days))
                                                     (if (<= ?iCounter ?month31days) then
                                                        (bind ?iMonth 12) ; December
                                                    else
                                                        ;Should never get here!
                                                        (return nil)
                                                    )
                                               )
                                           )
                                       )
                                   )
                                )
                           )
                        )
                    )
                )
            )
        )
    )
	
	;Now count the days within the month.
    ;   We add two to the result: one for the day from midnight; one because we count starting from one not zero.
    (bind ?iDay (+ (div ?iCounter (* 24 60 60)) 0)) ; ignore the time of day.
    (if (> (mod ?iCounter (* 24 60 60)) 0) then
        (bind ?iDay (+ ?iDay 1))
    )
	
	;Correction for landing on the boundary of leap years
	(if (and (= ?iMonth 1) (= ?iDay 0)) then
		(bind ?iMonth 12)
		(bind ?iDay 31)
	)
	
    (bind ?sMonth (str-cat "000" ?iMonth))
    (if (= (str-length ?sMonth) 5) then
        (bind ?sMonth (sub-string 4 5 ?sMonth))
    else
        (bind ?sMonth (sub-string 3 4 ?sMonth))
    )
    (bind ?sTempDate (str-cat ?sTempDate "-" ?sMonth "-"))
    
    
    (bind ?sDay (str-cat "000" ?iDay))
    (if (= (str-length ?sDay) 5) then
        (bind ?sDay (sub-string 4 5 ?sDay))
    else
        (bind ?sDay (sub-string 3 4 ?sDay))
    )
    (bind ?sTempDate (str-cat ?sTempDate ?sDay))
    
    ?sTempDate    
)

(deffunction DoW
    (?dDate)
    
    (if (not (integerp ?dDate)) then
        (return nil)
    )
    
    ;Convert UNIX date to text date for formulae
    (bind ?iYear (yearFromDateINT ?dDate))
    (bind ?iMonth (monthFromDateINT ?dDate))
    (bind ?iDay (dayFromDateINT ?dDate))

    (if (< ?iMonth 3) then
        (bind ?iMonth (+ ?iMonth 12))
        (bind ?iYear (- ?iYear 1))
    )
    (bind ?iCentury (div ?iYear 100))
    (bind ?iYearInCentury (mod ?iYear 100))
    (bind ?iA (- (div ?iCentury 4) (* 2 ?iCentury) 1))
    (bind ?iB (div (* 5 ?iYearInCentury) 4))
    (bind ?iAB (+ ?iA ?iB))
    (bind ?iC (div (* 26 (+ ?iMonth 1)) 10))
    (bind ?iABC (+ ?iAB ?iC))
    (bind ?iD (+ ?iABC ?iDay))
    (bind ?iE (mod ?iD 7))
    (if (< ?iE 0) then
        (bind ?iCalcDay (+ ?iE 7))
    else
        (bind ?iCalcDay ?iE)
    )
    
    
    ;Make Sunday 7, not 0, to align with ISO 8601, CLIPS, and Tcl interpretation.
    (if (= ?iCalcDay 0) then
        (bind ?iCalcDay 7)
    else
        ?iCalcDay
    )
    
    
)

(deffunction clFindSun
    (?dStartDate ?dEndDate)

    (if (or (not (integerp ?dStartDate)) (not (integerp ?dEndDate))) then
        (return nil)
    )
    (if (> ?dStartDate ?dEndDate) then
        (return nil)
    )
    
    ;Find the day of the week for the start day.
    (bind ?TempDoW (DoW ?dStartDate))
    (if (= ?TempDoW 7) then
        (return ?dStartDate)
    )
    
    ;Find difference and calculate day difference.
    (bind ?dTempDate (+ (* (- 7 ?TempDoW) 24 60 60) ?dStartDate))
    
    ;Final check that we are still within the range.
    (if (<= ?dTempDate ?dEndDate) then
        (return ?dTempDate)
    else
        (return nil)
    )
    
    ?dTempDate
)

(deffunction clFindSat
    (?dStartDate ?dEndDate)

    (if (or (not (integerp ?dStartDate)) (not (integerp ?dEndDate))) then
        (return nil)
    )
    (if (> ?dStartDate ?dEndDate) then
        (return nil)
    )
    
    ;Find the day of the week for the start day.
    (bind ?TempDoW (DoW ?dStartDate))
    (if (= ?TempDoW 6) then
        (return ?dStartDate)
    )
    ;Check if it is a Sunday, and then all the other days of the week.
    (if (= ?TempDoW 7) then
        (bind ?dTempDate (+ (* 7 24 60 60) ?dStartDate))
    else
        ;Find difference and calculate day difference.
        (bind ?dTempDate (+ (* (- 6 ?TempDoW) 24 60 60) ?dStartDate))
    )
    
    ;Final check that we are still within the range.
    (if (<= ?dTempDate ?dEndDate) then
        (return ?dTempDate)
    else
        (return nil)
    )
    
    ?dTempDate
)

(deffunction makeTwoDigits
    (?num)

    ;in case we get passed a (non-numeric) character, send it back straight away.
    (if (not (integerp ?num)) then
        (return ?num)
    )
    
    ;if the number comes through as numeric and not a string
    (if (< ?num 10) then
        (return (str-cat "0" ?num))
    )
    (if (>= ?num 10) then
        (return ?num)
    )
    
    ;lastly, we check for a string
    (if (= (str-length ?num) 2) then
        (return ?num)
    else
        (return (str-cat "0" ?num))
    )
    
    ?num
)
(deffunction daysAdd
    (?baseDate ?daysToAddToBase)
    
    ;We assume the base date to be an integer number of seconds.
    ;This is the usual case on a UNIX system, or as sent in from Tcl.
    ;In Python, we 'import time' and then use 'time.time()' to report a similar number of seconds.
    ;It usually expresses time as an integer number of seconds after the
    ;   Epoch Date of 01 January 1970, 00.00 UTC.
    
    ;Check that both arguments are numeric
    (if (not (integerp ?daysToAddToBase)) then
        (return 0)
    )
    (if (not (integerp ?baseDate)) then
        (return 0)
    )
    
    ;return the result. The second argument must be converted to seconds (= * 24 * 60 * 60).
    (return (+ ?baseDate (* ?daysToAddToBase 24 60 60)))
)

(deffunction mkDate
    (?baseYear ?baseMonth ?baseDay)
    
    ;Due to assuming that dates are expressed as an integer number of seconds
    ;   after 01 January 1970, 00.00 UTC, we accept no date earlier than that.
    
    ;To save some calculation time, we pre-calculate these base variables
    (bind ?yearSeconds 31536000) ; 365 * 24 * 60 * 60 . Number of seconds in a standard calendar year.
    (bind ?leapYearSeconds 31622400) ; 366 * 24 * 60 * 60 . Number of seconds in a leap year.

    
    ;Check that the arguments are numeric
    (if (not (integerp ?baseYear)) then
        (return 0)
    )
    (if (not (integerp ?baseMonth)) then
        (return 0)
    )
    (if (not (integerp ?baseDay)) then
        (return 0)
    )
    
    ;Check for legal values
    (if (< ?baseYear 1970) then
        (return 0)
    )
    (if (or (< ?baseMonth 1) (> ?baseMonth 12)) then
        (return 0)
    )
    (if (or (< ?baseDay 1) (> ?baseDay 31)) then
        (return 0)
    )
    (if (and (or (= ?baseMonth 9) (= ?baseMonth 4) (= ?baseMonth 6) (= ?baseMonth 11)) (> ?baseDay 30)) then
        (return 0)
    )
    (if (= ?baseMonth 2) then
        (if (isThisALeapYear ?baseYear) then
            (if (> ?baseDay 29) then
                (return 0)
            )
        else
            (if (> ?baseDay 28) then
                (return 0)
            )
        )
    )
    
    ;Loop through the years since the Epoch Date,
    ;   adding the number of seconds required for the years before the year requested.
    (bind ?tmpYear 1970)
    (bind ?Counter 0)
    (while (< ?tmpYear ?baseYear)
        (if (isThisALeapYear ?tmpYear) then
            (bind ?Counter (+ ?Counter ?leapYearSeconds))
        else
            (bind ?Counter (+ ?Counter ?yearSeconds))
        )
        (bind ?tmpYear (+ ?tmpYear 1))
    )
    
    ;Now add seconds for the months before the month requested.
    (bind ?prevMonth (- ?baseMonth 1))
    ;Pre-calculated: months of 31 days have 2678400 seconds; months of 30 days have 2592000 seconds.
    ;                months of 29 days have 2505600 seconds; months of 28 days have 2419200 seconds.
    (if (isThisALeapYear ?baseYear) then
        (switch ?prevMonth
            (case 1 then (bind ?Counter (+ ?Counter 2678400)))
            (case 2 then (bind ?Counter (+ ?Counter 5184000)))
            (case 3 then (bind ?Counter (+ ?Counter 7862400)))
            (case 4 then (bind ?Counter (+ ?Counter 10454400)))
            (case 5 then (bind ?Counter (+ ?Counter 13132800)))
            (case 6 then (bind ?Counter (+ ?Counter 15724800)))
            (case 7 then (bind ?Counter (+ ?Counter 18403200)))
            (case 8 then (bind ?Counter (+ ?Counter 21081600)))
            (case 9 then (bind ?Counter (+ ?Counter 23673600)))
            (case 10 then (bind ?Counter (+ ?Counter 26352000)))
            (case 11 then (bind ?Counter (+ ?Counter 28944000)))
            (default none)
        )
    else
        (switch ?prevMonth
            (case 1 then (bind ?Counter (+ ?Counter 2678400)))
            (case 2 then (bind ?Counter (+ ?Counter 5097600)))
            (case 3 then (bind ?Counter (+ ?Counter 7776000)))
            (case 4 then (bind ?Counter (+ ?Counter 10368000)))
            (case 5 then (bind ?Counter (+ ?Counter 13046400)))
            (case 6 then (bind ?Counter (+ ?Counter 15638400)))
            (case 7 then (bind ?Counter (+ ?Counter 18316800)))
            (case 8 then (bind ?Counter (+ ?Counter 20995200)))
            (case 9 then (bind ?Counter (+ ?Counter 23587200)))
            (case 10 then (bind ?Counter (+ ?Counter 26265600)))
            (case 11 then (bind ?Counter (+ ?Counter 28857600)))
            (default none)
        )
    )
    
    ;Lastly add the days of the month sought.
    (bind ?Counter (+ ?Counter (* (- ?baseDay 1) 24 60 60)))
    
    (return ?Counter)
)

(deffunction string-to-integer
    (?sNumber)
    

    ;We assume a string of integers only.
    ; As soon as we strike a character that is not an integer, bail and return nil.
    (bind ?iLen (str-length ?sNumber))
    (bind ?iNum 0)
    (bind ?iCount ?iLen)
    (while (> ?iCount 0)
		(switch (sub-string ?iCount ?iCount ?sNumber)
			(case "0" then (bind ?iDigit 0))
			(case "1" then (bind ?iDigit 1))
			(case "2" then (bind ?iDigit 2))
			(case "3" then (bind ?iDigit 3))
			(case "4" then (bind ?iDigit 4))
			(case "5" then (bind ?iDigit 5))
			(case "6" then (bind ?iDigit 6))
			(case "7" then (bind ?iDigit 7))
			(case "8" then (bind ?iDigit 8))
			(case "9" then (bind ?iDigit 9))
			(default (return nil))
		)
		;Get the sum of each newly found digit multiplied by the appropriate power of ten.
		(bind ?iNum (+ (integer (* ?iDigit (** 10 (- ?iLen ?iCount)))) ?iNum))
		(bind ?iCount (- ?iCount 1))
    )
    
    ?iNum
)

(deffunction floor
    (?iBaseNum)
    ;This function is not available in the standard mathematics library in CLIPS.
    
    ;Check that the argument is numeric
    (if (and (not (integerp ?iBaseNum)) (not (floatp ?iBaseNum))) then
        (return nil)
    )
    
    ;If zero, then return zero
    (if(= ?iBaseNum 0) then
        (return ?iBaseNum)
    )
    
    ;If the number is positive, just return the result of integer division
    (if (> ?iBaseNum 0) then
        (return (div ?iBaseNum 1))
    )
    
    ;If the number is negative, if the modulus of the number by one is zero, return the number, else subtract 1.
    (if (< ?iBaseNum 0) then
        (if (= (mod ?iBaseNum 1) 0) then
            (return (div ?iBaseNum 1))
        else
            (return (- (div ?iBaseNum 1) 1))
        )
    )
)

(deffunction CalcDayDiffJulianCal
    (?dDate)
    
    ;Find the days difference between the passed-in Gregorian date and the Julian date
    ;  Find the hundreds part of the year
    (bind ?sYearHundreds (sub-string 1 2 (unmakeDate ?dDate)))
    ;We need 1.25 to round to 1, and -1.25 to round to -2 -- i.e. floor or integer division function.
    (bind ?iYearHundreds (string-to-integer ?sYearHundreds))
    (bind ?iFlooredValue (floor (/ ?iYearHundreds 4)))
    (if (< ?iYearHundreds 0) then
        ;Create a real floored value, not just the result of integer division
        (bind ?iFlooredValue (- ?iFlooredValue 1))
    )
    (bind ?iDaysDiff (- ?iYearHundreds ?iFlooredValue 2))
    (return ?iDaysDiff)

)

(deffunction pGregorianToCJDN
    (?baseYear ?baseMonth ?baseDay)
    ;The Chronological Julian Day Number is a whole number representing a day.
    ;  It's day begins at 00:00 Local Time.
    ;The zero point for a Julian Date (JD 0.0) corresponds to 12.00 UTC, 1 January -4712.
    ; The zero point for the CJDN is 1 January -4712 (the whole day in local time).
    ;From: http://aa.quae.nl/en/reken/juliaansedag.html .
    
    (bind ?iC0 (floor (/ (- ?baseMonth 3) 12)))
    (bind ?iX4 (+ ?baseYear ?iC0))
    (bind ?iX3 (floor (/ ?iX4 100)))
    (bind ?iX2 (mod ?iX4 100))
    (bind ?iX1 (- ?baseMonth (* 12 ?iC0) 3))
    (bind ?iJ (+ (floor (/ (* 146097 ?iX3) 4)) (floor (/ (* 36525 ?iX2) 100)) (floor (/ (+ (* 153 ?iX1) 2) 5)) ?baseDay 1721119))
    
    (return (round ?iJ))
)

(deffunction pCJDNToGregorian
    (?iCJDN)

    (bind ?iK3 (+ (* 4 (- ?iCJDN 1721120)) 3))
    (bind ?iX3 (floor (/ ?iK3 146097)))
    (bind ?iK2 (+ (* 100 (floor (/ (mod ?iK3 146097) 4))) 99))
    (bind ?iX2 (floor (/ ?iK2 36525)))
    (bind ?iK1 (+ (* (floor (/ (mod ?iK2 36525) 100)) 5) 2))
    (bind ?iX1 (floor (/ ?iK1 153)))
    (bind ?iC0 (floor (/ (+ ?iX1 2) 12)))
    (bind ?iYear (+ (* 100 ?iX3) ?iX2 ?iC0))
    (bind ?iMonth (+ (- ?iX1 (* 12 ?iC0)) 3))
    (bind ?iDay (+ (floor (/ (mod ?iK1 153) 5)) 1))
    
    (return (mkDate ?iYear ?iMonth ?iDay))
)

(deffunction pMilankovicToCJDN
    (?baseYear ?baseMonth ?baseDay)
    ;The Chronological Julian Day Number is a whole number representing a day.
    ;  Its day begins at 00:00 Local Time.
    ;The zero point for a Julian Date (JD 0.0) corresponds to 12.00 UTC, 1 January -4712.
    ; The zero point for the CJDN is 1 January -4712 (the whole day in local time).
    ;From: http://aa.quae.nl/en/reken/juliaansedag.html .
    
    (bind ?iC0 (floor (/ (- ?baseMonth 3) 12)))
    (bind ?iX4 (+ ?baseYear ?iC0))
    (bind ?iX3 (floor (/ ?iX4 100)))
    (bind ?iX2 (mod ?iX4 100))
    (bind ?iX1 (- ?baseMonth (* 12 ?iC0) 3))
    (bind ?iJ (+ (floor (/ (+ (* 328718 ?iX3) 6) 9)) (floor (/ (* 36525 ?iX2) 100)) (floor (/ (+ (* 153 ?iX1) 2) 5)) ?baseDay 1721119))
    
    (return (round ?iJ))
)

(deffunction pCJDNToMilankovic
    (?iCJDN)

    (bind ?iK3 (+ (* 9 (- ?iCJDN 1721120)) 2))
    (bind ?iX3 (floor (/ ?iK3 328718)))
    (bind ?iK2 (+ (* 100 (floor (/ (mod ?iK3 328718) 9))) 99))
    (bind ?iX2 (floor (/ ?iK2 36525)))
    (bind ?iK1 (+ (* (floor (/ (mod ?iK2 36525) 100)) 5) 2))
    (bind ?iX1 (floor (/ (+ (* (floor (/ (mod ?iK2 36525) 100)) 5) 2) 153)))
    (bind ?iC0 (floor (/ (+ ?iX1 2) 12)))
    (bind ?iYear (+ (* 100 ?iX3) ?iX2 ?iC0))
    (bind ?iMonth (+ (- ?iX1 (* 12 ?iC0)) 3))
    (bind ?iDay (+ (floor (/ (mod ?iK1 153) 5)) 1))
    
    (return (mkDate ?iYear ?iMonth ?iDay))
)

(deffunction pJulianToCJDN
    (?baseYear ?baseMonth ?baseDay)
    
    (bind ?iJ0 1721117)
    (bind ?iC0 (floor (/ (- ?baseMonth 3) 12)))
    (bind ?iJ1 (floor (/ (* 1461 (+ ?baseYear ?iC0)) 4)))
    (bind ?iJ2 (floor (/ (- (* 153 ?baseMonth) (* 1836 ?iC0) 457) 5)))
    (bind ?iJ (+ ?iJ1 ?iJ2 ?baseDay ?iJ0))
    (return (round ?iJ))
)

(deffunction pCJDNToJulian
    (?iCJDN)

    (bind ?iY2 (- ?iCJDN 1721118))
    (bind ?iK2 (+ (* 4 ?iY2) 3))
    (bind ?iK1 (+ (* 5 (floor (/ (mod ?iK2 1461) 4))) 2))
    (bind ?iX1 (floor (/ ?iK1 153)))
    (bind ?iC0 (floor (/ (+ ?iX1 2) 12)))
    (bind ?iYear (+ (floor (/ ?iK2 1461)) ?iC0))
    (bind ?iMonth (+ (- ?iX1 (* 12 ?iC0)) 3))
    (bind ?iDay (round (+ (floor (/ (mod ?iK1 153) 5)) 1)))
    
    (return (mkDate ?iYear ?iMonth ?iDay))
)

(deffunction mkODate
    (?baseYear ?baseMonth ?baseDay)
    
    ;First makes the date, then converts it to an Orthodox or Revised Julian date.
    ;The Revised Julian calendar was implemented 13 October 1923 (Gregorian).
    ;  cf. http://articles.adsabs.harvard.edu/full/seri/AN.../0220/0000203.000.html .
    
    ;To save time, only perform the computation, after the first occurrence of a date,
    ; which differs from the Gregorian Calendar. In the Gregorian Calendar, 2800 is a leap year;
    ; in the Revised Julian or Milankovic Calendar it is not.
    (if (>= ?baseYear 2800) then
	(bind ?iTempCJDN (pGregorianToCJDN ?baseYear ?baseMonth ?baseDay))
	(return (pCJDNToMilankovic ?iTempCJDN))
    else
        (return (mkDate ?baseYear ?baseMonth ?baseDay))
    )
)

(deffunction mkJDate
    (?baseYear ?baseMonth ?baseDay)
    
   ;First makes the date, then converts it to a Julian date.
    (bind ?iTempCJDN (pGregorianToCJDN ?baseYear ?baseMonth ?baseDay))
    (return (pCJDNToJulian ?iTempCJDN))

)

(deffunction mkDateForCurrentCal
    (?baseYear ?baseMonth ?baseDay)
    ;Converts the parameters to a date in the chosen EDM calendar
    (if (= ?*EDM* ?*iEDM_WESTERN*) then
        (return (mkDate ?baseYear ?baseMonth ?baseDay))
    else
        (if (= ?*EDM* ?*iEDM_ORTHODOX*) then
            (return (mkODate ?baseYear ?baseMonth ?baseDay))
        else
            (if (= ?*EDM* ?*iEDM_JULIAN*) then
                (return (mkJDate ?baseYear ?baseMonth ?baseDay))
            )
        )
    )
)
(deffunction NumDaysOfWeekBetween
    (?dStartDate ?dEndDate ?iDoW)
    ;Calculates the number of a given Day of the Week (e.g. a Thursday) between two dates.
    
    ;Check parameters
    (if (or (not (integerp ?dStartDate)) (not (integerp ?dEndDate)) (not (integerp ?iDoW))) then
        (return nil)
    )
    (if (> ?dStartDate ?dEndDate) then
        (return nil)
    )
    (if (or (< ?iDoW 1) (> ?iDoW 7)) then
        (return nil)
    )
    
    ;We want to count days between the two dates, excluding the start and end dates
    (bind ?dStartDate (daysAdd ?dStartDate 1))
    (bind ?dEndDate (daysAdd ?dEndDate -1))
    (bind ?iDayCount 0)
    (bind ?iDays (div (- ?dEndDate ?dStartDate) 24 60 60))
    (if (< ?iDays 1) then
        (return nil)
    )
    (bind ?iWeeks (div ?iDays 7))
    (bind ?iStartDay (DoW ?dStartDate))
    (bind ?iEndDay (DoW ?dEndDate))
    (bind ?iDayCount ?iWeeks)
    (if (> (mod ?iDays 7) 0) then
	;Cycle through remaining days
	(bind ?dTempDate (+ ?dStartDate (* ?iWeeks 7 24 60 60)))
	(bind ?dTempDate (daysAdd ?dTempDate 1)) ;Add one day, so we do not include first date.
	(while (<= ?dTempDate ?dEndDate)
	    (if (= (DoW ?dTempDate) ?iDoW) then
		(bind ?iDayCount (+ ?iDayCount 1))
	    )
	    (bind ?dTempDate (daysAdd ?dTempDate 1))
	)
    )
    
    ?iDayCount
)
