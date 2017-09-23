param (
    [string]$Timeout = (30 * 60),
    [switch]$Repeat,
    [int]$SleepTime = (15 * 60)
 )


Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
namespace PInvoke.Win32 {
    public static class UserInput {
        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }
        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }
        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }
        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@



Do {
    #Check if the user is logged in
    If ( (qwinsta | Select-String -Pattern "^>console").Matches.Length -gt 0) {

        $IdleTime = [PInvoke.Win32.UserInput]::IdleTime.TotalSeconds  
        Write-Host ("The logged in user has been idle for $IdleTime seconds.")

        #Check if the user has been idle too long    
        If ($IdleTime -gt $Timeout) {
            Write-Host ("Session has been idle for more than $Timeout seconds. Terminating session.")
            If (Test-Path HKCU:\NICE) {
                #This is an AppStream instance.
                shutdown.exe /s /t 60
            }
            Else {
                #This is a WorkSpace instance
                tsdiscon console
            }
        }
   
    }
    Else {
        Write-Host ("There is no user logged in")
    }
    
    Start-Sleep -Seconds $SleepTime
    
} While ($Repeat)


