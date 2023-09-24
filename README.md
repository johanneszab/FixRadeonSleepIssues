# FixRadeonSleepIssues.ps1

A simple powershell script to fix black screens after turning off the display, putting the system in hibernate or sleep with AMD Radeon Graphics cards. This script modifies the Windows Registry to change the cards low power behavior.

The black screens can manifest in:

* The display doesn't turn on again and the system has the be resetted
* The display driver crashes after the display was turned off is operating in safe mode:
  >AMD crash Defender has detected an issue with your display driver. To prevent a system crash or hang, the display driver is now operating in safe mode with reduced functionality. It is recommended that you save all work and close any open applications. A system restart is required to restore your graphics hardware acceleration.
* There is a black screen after awaking the system from sleep or hibernate.

## Usage:

1. Run `RunFix.cmd` or `RunFix.ps1`. Both files are a wrapper to run `FixRadeonSleepIssues.ps1` as Administrator (necessary for adding keys to the Windows Registry).

2. If run successfully, you'll need to reboot your system for the changes to take effect.

## Insights:

This scripts looks in the Registry under the path `HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}` for any AMD graphics cards (based on vendor (`Advanced Micro Devices, Inc.`) and driver description (`AMD Radeon`)) and adds the following registry key:

* "EnableUlps" as DWORD with the value 0

You can test the fix by locking your desktop (press `Win + L`) and see if it crashes after the displays turns off.

Disabling Ultra Low Power State (ULPS) seems to not broadly effect the idle power consumption of the RX graphics cards. My RX 6600 XT idles at 3-4W with a single 4K Display connected via display port after disabling ULPS according to AMD Software: Adrenalin Edition.

## Tested on:

Tested on Windows 10 22H1 with an AMD Radeon RX 6600 XT (Sapphire AMD Radeon™ RX 6600 XT NITRO+).

These Windows Registry keys should also work on the following AMD Graphics Cards:

* AMD Radeon RX 5000 Series
* AMD Radeon RX 6000 Series
* AMD Radeon(TM) Graphics (integrated graphics cards)
