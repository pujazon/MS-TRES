@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

SET hasBegin=0
SET PID=0
SET count=0

rem finish when (hasBegin == 1 && pid = NULL) => keep locked if (hasBegin == 0 || pid != NULL)

:spinlock
goto :getPid
:check
rem echo After get PID
rem echo %PID%
if %hasBegin% == 1 (
	if %PID% == 0 (	
		echo "hasBegin == 1 && PID == 0 => 42 begin but and finished"
		goto :end
	)
	echo "hasBegin == 1 && PID != 0 => 42 begin but not finished yet"
	goto :spinlock
)
echo "hasBegin == 0 && PID == X => 42 has not begun yet"
goto :spinlock


:getPID
rem echo getPID
SET /a count=1

rem Get rows
FOR /F "tokens=* USEBACKQ" %%F IN (`tasklist /fi "PID eq 8792" `) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

rem echo ROW
rem echo %var3%
rem echo COUNT
rem echo !count!

rem echo If count == 2 means that no process has been found so:
rem Or has died or hasn't begin. Anyway return to check.
IF !count! == 3 (
	SET PID=0
	goto :check
)

rem if goes here means that process is alive so set for first time hasBegin 
rem or it was already alive, we re-set hasBegin (no t&t&s)
SET hasBegin=1

rem Get PID
SET /a count=0
FOR %%A IN (%var3%) DO (
	IF !count! leq 1 (
		SET /a PID=%%A
	)		
	SET /a count=!count!+1
)
goto :check

:end

ENDLOCAL
	
	