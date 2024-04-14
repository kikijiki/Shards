@echo off
setlocal enabledelayedexpansion

:: Rip this from the browser's developer tools.
set COOKIES=""
set SUBMISSION_FILENAME="${id}.${extension}"

git diff-index --quiet HEAD --
if %errorlevel% neq 0 (
    echo There are uncommitted changes on git.
    exit /b 1
)

pip install leetcode_export
::python -m leetcode_export --only-accepted --problem-statement-filename readme.html --cookies %COOKIES%
python -m leetcode_export --only-accepted --no-problem-statement --submission-filename %SUBMISSION_FILENAME% --cookies %COOKIES%

::for /r %%i in (readme.html) do (
::    if exist "%%i" (
::        pandoc -f html -t markdown "%%i" -o "%%~dpi\readme.md"
::        ::if exist "%%~dpi\readme.md" (
::        ::    del "%%i"
::        ::)
::    )
::)

git add --all
git commit -m "Leetcode Export"

echo Export complete.