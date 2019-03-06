@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

SET hasBegin=0
SET iniN = 0;
SET count=0

rem First get initial num of CMD opened
goto :NumCMD
:ret
echo NumCMD
echo !iniN!

rem Spinlock
:spinlock
	goto :test_and_set
:end_spinlock


rem .............................................................................
:test_and_set
rem echo Get current num of CMD opened
SET /a count=0

rem Get rows
FOR /F "tokens=* USEBACKQ" %%F IN (`tasklist /fi "IMAGENAME eq cmd.exe" `) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

SET /a count=!count!-4

rem if there is none there are 2
rem echo ROW
rem echo %var3%
REM echo Current CMD
REM echo !count!

rem (ini < current) && hasBegin == 0 -> Acaba de abrir 42
IF !iniN! LSS !count! (	
	if %hasBegin% == 0 (
		echo "Starts.."
		SET hasBegin=1
		goto :spinlock
	)
)

rem Here means that hasn't entered to if

if %hasBegin% == 0 ( 
	echo "Idle..."
	goto :spinlock
)

rem echo check if finished: current cmd eq ini
SET /a count=0

rem Get rows
FOR /F "tokens=* USEBACKQ" %%F IN (`tasklist /fi "IMAGENAME eq cmd.exe" `) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)
SET /a count=!count!-4


rem echo last check CMD
rem echo !count!

rem if current == ini && hasBegin -> Finished
IF !iniN! EQU !count! (	
		echo unlock
		goto :unlock
)


echo Running...
goto :spinlock

rem .............................................................................

:NumCMD
FOR /F "tokens=* USEBACKQ" %%F IN (`tasklist /fi "IMAGENAME eq cmd.exe" `) DO (
  SET var!iniN!=%%F
  SET /a iniN=!iniN!+1
)

rem Delete noise: 3 top rows and 1 bottom row
SET /a iniN=!iniN!-4
goto :ret

rem .............................................................................
:unlock

ENDLOCAL
	
	