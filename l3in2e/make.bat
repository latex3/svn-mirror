@echo off
rem This Windows batch file provides some basic make-like functionality
rem for the expl3 bundle

set EXPL3AUXFILES=aux cmds glo gls hd idx ilg ind ist log out toc
set EXPL3NEXT=end

if "%1" == "alldoc"    goto :alldoc
if "%1" == "checkdoc"  goto :checkdoc
if "%1" == "clean"     goto :clean
if "%1" == "doc"       goto :doc
if "%1" == "sourcedoc" goto :sourcedoc

goto :help

:alldoc
  
  set EXPL3NEXT=alldoc-a
 
  goto :typeset-aux

:alldoc-a 

  echo Typesetting all dtx files: please be patient!
  
  for %%I in (*.dtx) do call temp %%~nI
  
  goto :sourcedoc-a
    
:checkdoc
  
  set EXPL3NEXT=checkdoc-a
 
  goto :check-aux
  
:checkdoc-a
  
  for %%I in (*.dtx) do call temp %%~nI
  
  goto :clean
  
:check-aux

  tex -quiet l3doc.dtx

  echo @echo off > temp.bat
  echo echo. >> temp.bat
  echo echo Checking %%1.dtx  >> temp.bat
  echo pdflatex -interaction=nonstopmode -draftmode -quiet %%1.dtx >> temp.bat
  echo if not ERRORLEVEL 0 goto :error >> temp.bat
  echo for /F "skip=2000 tokens=*" %%%%I in (%%1.log) do if "%%%%I"=="Functions documented but not defined:" echo ! Warning: some functions documented but not defined >> temp.bat
  echo for /F "skip=2000 tokens=*" %%%%I in (%%1.log) do if "%%%%I"=="Functions defined but not documented:" echo ! Warning: some functions defined but not documented >> temp.bat
  echo goto :end >> temp.bat
  echo :error >> temp.bat
  echo echo ! %%1.dtx compilation failed >> temp.bat
  echo :end >> temp.bat
        
  goto :%EXPL3NEXT%
  
:clean

  for %%I in (%EXPL3AUXFILES%) do if exist *.%%I del /q *.%%I
  
  if exist l3doc.cls del /q l3doc.cls 
  if exist l3doc.ist del /q l3doc.ist
  
  if exist temp.bat del /q temp.bat
    
  echo.
  echo All done
  
  goto :end
  
:doc
  
  if "%2" == "" goto :help
  if not exist %2.dtx goto :no-file
  
  set EXPL3NEXT=doc-a
  goto :typeset-aux
  
:doc-a
  
  call temp %2
  
  goto :clean
  
:help

  echo.
  echo make clean             - removes temporary files
  echo.
  echo  make checkdoc         - check all modules compile correctly
  echo.
  echo  make doc "name"       - typeset "name".dtx
  echo  make sourcedoc        - typeset source3.tex
  echo  make alldoc           - typeset all documentation
  echo.
  echo  make /OR/ make help   - show this help text
  echo.
  
  goto :end
  
:no-file
  
  echo.
  echo No such file %2.dtx
  echo.
  echo Type "make help" for more help

  goto :end
  
:sourcedoc
  
  set EXPL3NEXT=sourcedoc-a
 
  goto :typeset-aux

:sourcedoc-a
  
  call temp source3
  
  goto :clean
  
:typeset-aux

  tex -quiet l3doc.dtx

  echo @echo off > temp.bat
  echo echo. >> temp.bat
  echo echo Typesetting %%1.dtx  >> temp.bat
  echo pdflatex -interaction=nonstopmode -draftmode -quiet %%1.dtx >> temp.bat
  echo if not ERRORLEVEL 0 goto :error >> temp.bat
  echo makeindex -q -s l3doc.ist -o %%1.ind %%1.idx >> temp.bat
  echo pdflatex -interaction=nonstopmode -quiet %%1.dtx >> temp.bat
  echo pdflatex -interaction=nonstopmode -quiet %%1.dtx >> temp.bat
  echo for /F "skip=2000 tokens=*" %%%%I in (%%1.log) do if "%%%%I"=="Functions documented but not defined:" echo ! Warning: some functions documented but not defined >> temp.bat
  echo for /F "skip=2000 tokens=*" %%%%I in (%%1.log) do if "%%%%I"=="Functions defined but not documented:" echo ! Warning: some functions defined but not documented >> temp.bat
  echo goto :end >> temp.bat
  echo :error >> temp.bat
  echo echo ! %%1.dtx compilation failed >> temp.bat
  echo :end >> temp.bat
        
  goto :%EXPL3NEXT%
  
:end