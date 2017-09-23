# IdleTimeout

This project is a PowerShell script that will log an idl user out of Amazon Workspaces after a configurable period of time. But default Workspaces will run as long as the client is open, even if it is not being used. This means that autostop instances will not stop as desired and continue to generate charges. I intended to support AppStream in the future, but it is not working in this version. 

IdleTimeout.ps1 should be placed in %ProgramFiles%\IdleTiemout\

IdleTimeout.bat should be placed in %ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup
