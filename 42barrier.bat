@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

SET hasBegin=0
SET PID=0
SET count=0

rem finish when (hasBegin == 1 && pid = NULL) => keep locked if (hasBegin == 0 || pid != NULL)

:spinlock
goto :getPid
:check
if %hasBegin% == 1 (
	if %PID% == 0 (		
		echo %PID%
		echo "hasBegin == 1 && PID == 0 => 42 begin but and finished"
		goto :end
	)
	echo %PID%
	echo "hasBegin == 1 && PID != 0 => 42 begin but not finished yet"
	goto :spinlock
)
echo %PID%
echo "hasBegin == 0 && PID == X => 42 has not begun yet"
SET hasBegin=1
goto :spinlock


:getPID
echo getPID
SET /a count=0

rem Get rows
FOR /F "tokens=* USEBACKQ" %%F IN (`tasklist /fi "PID eq 508" `) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
  echo %%F
)

echo COUNT
echo !count!

IF !count! == 2 (
	echo If count == 2 means that no process has been found so:
	SET PID=0
	goto :check
)

echo %var4%

rem Get PID
SET /a count=0
FOR %%A IN (%var3%) DO (
	IF !count! leq 1 (
		SET /a PID=%%A
	)		
	SET /a count=!count!+1
)

echo %PID%
goto :check

:end

ENDLOCAL
	
	