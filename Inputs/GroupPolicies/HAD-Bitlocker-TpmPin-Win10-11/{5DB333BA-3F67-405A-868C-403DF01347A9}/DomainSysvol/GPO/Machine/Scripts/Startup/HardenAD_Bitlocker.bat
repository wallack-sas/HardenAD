@Echo off

copy %~dp0Security-BitLocker-TPM_and_PIN.ps1 %windir%\HardenAD\BitLocker\Security-BitLocker-TPM_and_PIN.ps1
copy %~dp0setBitLocker.ps1 %windir%\HardenAD\BitLocker\setBitLocker.ps1
copy %~dp0HADBitlocker.exe %windir%\HardenAD\BitLocker\HADBitlocker.exe

for /F "tokens=3 delims=: " %%H in ('sc query "HADBitlocker" ^| findstr "        STATE"') do (
  if /I "%%H" NEQ "RUNNING" (
   Echo "%%H"
   sc.exe start HADBitlocker
  )
)

Exit