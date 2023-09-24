Start-Process powershell -Verb RunAs "-ExecutionPolicy Bypass -NoProfile -Command `"cd '$pwd'; & '.\FixRadeonSleepIssues.ps1'; pause`""
