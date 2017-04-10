@echo off
:: Quick Utility (Q)
:: This script was born out of my need to constantly change my IP address when working in the TechRoom at OceanTech Recycling
:: From there, it gained more features that I found myself having to do more and more frequently. 
:: This script is fully interactive with a basic dynamic menu system and has no command-line arguments

:: Copyright (C) 2015-2017 David Todd (c0de) c0de@c0defox.es
:: LICENSE: MIT
:: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
:: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

:: This script was designed to run on Windows 7-10, but has shown success in Windows XP (tested only on an Administrator level user on XP)

:winresize
    :: resizes the cmd window - The help screen is too big for this size, so it does its own resize and uses this function when done
    mode con:cols=100 lines=30

:setup
    echo Quick Utility "Q" - A script that satisfies various IT needs
    :: Name of LAN interface - Used for setting a static IP/DHCP
    set "lanint=Local Area Connection"
    :: Name of WiFi interface - Used for enabling/disabling it
    set "wifiint=Wireless Network Connection"

    :: Define toggle variables Here
    :: Toggle variables are used to dynamically change the menu options when you can do one or the other of two actions
    set "staticip=False"
    set "fwoff=False"
    set "wifioff=False"

:: BatchGotAdmin
:: Taken from: https://sites.google.com/site/eneerge/scripts/batchgotadmin and modified to suit my needs
:: Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo This script requires Administrative privileges to run
    echo Press any key to open the UAC dialog
    pause > NUL

    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    :: Uses Visual Basic Script to runas user 1 (Administrator) the calling script (this one) 
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    :: The following two comments are for passing arguments. Q does not use command line arguments at the moment and runs interactive
    :: If in the future we want arguments and non-interactive mode, uncomment the following two and remove the last echo in this function
    ::set params=%*:"=""
    ::echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c %~s0", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
    goto choice
:: End BatchGotAdmin

:setCOM <WMIC_output_line>
    :: Reads the output from WMIC (:G) and parses it into one or more _COM variables
    :: Set commands taken from: http://stackoverflow.com/a/27773154
    setlocal
        set "str=%~1"
        set "num=%str:*(COM=%"
        set "num=%num:)=%"
        set str=%str:(COM=&rem.%
    endlocal & set "_COM%num%=%str%"
    goto end

:help
    :: Make the window a little wider to fit the help text
    mode con:cols=130 lines=30
    title Quick Utility - Help
    echo This script facilitates setting various networking features without having to go into the control panel
    echo When pressing CTRL+C, you will be prompted if you wish to terminate the batch job. Answering Y will close this script.
    echo Here is what the following options do and how to use them
    echo.
    echo ===============================================================================================================================
    echo.
    echo Main Menu Help
    echo Quit - Exits the script, you can do this at anytime by pressing CTRL+C or by clicking the x in the upper right corner
    echo Help - Shows this message
    echo Set Static IP - Changes your "%lanint%" IP settings to user defined static
    echo Set DHCP - The reverse of Set Static IP, turns on DHCP on "%lanint%"
    echo Disable Firewall - Disables firewall for public, private and domain networks - Unsafe! Turn it back on when done
    echo Enable Firewall - Enables firewall for public, private and domain networks
    echo Disable Network Adapter - Sets the %wifiint% network adapter to Disabled (disconnecting it from any network)
    echo Enable Network Adapter - Sets the %wifiint% network adapter to Enabled (reconnecting back to its previous network)
    echo Show COM Ports - Lists the COM (serial) ports connected to this device
    echo Ping Host - Prompts user for IP address of host and opens a new cmd window to ping until canceled by the user with CTRL+C
    echo.
    echo ===============================================================================================================================
    echo.
    echo Advanced Options - These are settings that change how this script acts without having to edit it
    echo Change name of %lanint% - This changes the network interface that this script will set network settings for 
    echo Change name of %wifiint% - This changes the wireless network interface that this script will enable/disable
    pause
    :: Put the window size back
    call :winresize
    cls

:choice
    :: Main menu
    title Quick Utility
    :: Present the menu options to the user
    echo Choose an option:
    echo [Q] Quit
    echo [H] Help
    echo [A] Advanced Options

    :: Toggle actions - You can do one or the other of each of these
    if /I "%staticip%"=="False" (
        echo [1] Set Static IP on Network Adapter: %lanint%
    )else (
        echo [1] Set DHCP on Network Adapter: %lanint%
    )

    if /I "%fwoff%"=="False" (
        echo [2] Turn Off Windows Firewall
    )else (
        echo [2] Turn On Windows Firewall
    )

    if /I "%wifioff%"=="False" (
        echo [3] Disable Network Adapter: %wifiint%
    )else (
        echo [3] Enable Network Adapter: %wifiint%
    )

    :: Single use actions
    echo [7] Show COM Ports
    echo [8] Ping Host
    echo.

    :: Process the user input from the menu
    SET /P C=Choose one of the above: 
    :: Toggle actions - You can do one or the other of each of these

    :: If the user chose to change their IP address
    for %%? in (1) do if /I "%C%"=="%%?" (
        if /I "%staticip%"=="False" (
            goto A
        )else (
            goto B
        )
    )
    :: If the user chose to toggle their firewall
    for %%? in (2) do if /I "%C%"=="%%?" (
        if /I "%fwoff%"=="False" (
            goto C
        )else (
            goto D
        )
    )
    :: If the user chose to toggle their network interface
    for %%? in (3) do if /I "%C%"=="%%?" (
        if /I "%wifioff%"=="False" (
            goto E
        )else (
            goto F
        )
    )
    :: Single use actions
    for %%? in (7) do if /I "%C%"=="%%?" goto G
    for %%? in (8) do if /I "%C%"=="%%?" goto H
    for %%? in (A) do if /I "%C%"=="%%?" goto advmenu
    for %%? in (Q) do if /I "%C%"=="%%?" goto end
    for %%? in (H) do if /I "%C%"=="%%?" goto help
    :: Default to going back to the menu
    echo Wrong option entered!
    goto choice

:advmenu
    :: This is the advanced menu, you can use it to change internal stuff about how the script works
    title Quick Utility - Advanced Menu
    echo Advanced Menu - Choose:
    echo [B] Back
    echo [1] Change name of %lanint%
    echo [2] Change name of %wifiint%

    set /P c=Chose one of the above: 
    for %%? in (b) do if /I "%C%"=="%%?" (
        cls
        goto choice
    )
    for %%? in (1) do if /I "%C%"=="%%?" goto setlanint
    for %%? in (2) do if /I "%C%"=="%%?" goto setwifiint
    :: Default to going back to the menu
    echo Wrong option entered!
    goto advmenu

:setlanint
    :: Renames the LAN interface this script will manipulate (static IP/DHCP/etc) - Also works with the WiFi interface if needed
    title Quick Utility - Change Network interface

    echo Your current network interface is: %lanint%
    set /P "change=Change to a different network interface? [y/N] "

    :: If the user answered yes
    for %%? in (y) do if /I "%change%"=="%%?" (
        set /P "newlan=Enter the name of your LAN interface: "
        if %newlan% == "" (goto setlanint)

        echo Changing LAN interface
        set "%lanint%=%newlan%"

        netsh int ip show config name="%lanint%"

        pause
        cls
        goto choice
    )

    echo Not changing anything!
    pause
    cls
    goto advmenu

:setwifiint
    :: Renames the wireless interface this script will enable/disable
    title Quick Utility - Change wireless interface

    echo Your current network interface is: %wifiint%
    set /P "change=Change to a different network interface? [y/N] "

    :: If the user answered yes
    for %%? in (y) do if /I "%change%"=="%%?" (
        set /P "newlan=Enter the name of your wireless interface: "
        if %newlan% == "" (goto setwifiint)

        echo Changing wireless interface
        set "%wifiint%=%newlan%"

        netsh int ip show config name="%wifiint%"

        pause
        cls
        goto choice
    )

    echo Not changing anything!
    pause
    cls
    goto advmenu

:: Set Static IP
:A
    :: Sets the LAN interface (Local Area Connection by default) to a static IP, gateway, subnet
    title Quick Utility - Set Static
    echo Getting IP info from user
    echo items in [] are default

    set /p "IP=What is this computer's IP address? [10.5.5.2] "
    set /p "gateway=What is your gateway? [This PC IP Address] "
    set /p "subnet=What is your network's subnet mask? [255.255.255.0] "

    if "%ip%" == "" (set "ip=10.5.5.2")
    if "%gateway%" == "" (set "gateway=%ip%")
    if "%subnet%" == "" (set "subnet=255.255.255.0")

    echo Verify the following information.
    echo If incorrect, choose the "Static IP" option from the menu again.
    echo %ip%
    echo %subnet%
    echo %gateway%

    pause

    echo Setting Static IP Information
    netsh interface ip set address "%lanint%" static %ip% %subnet% %gateway% 1
    netsh int ip show config name="%lanint%"
    set "staticip=True"
    pause
    cls
    goto choice

:: Set DHCP
:B
    :: Sets the LAN interface (Local Area Connection by default) to DHCP mode
    title Quick Utility - DHCP
    echo Resetting IP Address and Subnet Mask For DHCP
    netsh int ip set address name = "%lanint%" source = dhcp

    echo Requesting new IP address
    ipconfig /renew "%lanint%" > NUL

    echo Here are the new settings for %computername%:
    netsh int ip show config name="%lanint%"

    set "staticip=False"
    pause
    cls
    goto choice

:: Turn off Windows Firewall
:C
    :: Turns off the Windows Firewall on all network types
    title Quick Utility - Firewall Off
    echo Turning the Windows Firewall Off (Unsecure, Re-Enable when done!)

    netsh advfirewall set allprofiles state off
    netsh advfirewall show all

    set "fwoff=True"
    pause
    cls
    goto choice

:: Turn on Windows Firewall
:D
    :: Turns on the Windows Firewall on all network types
    title Quick Utility - Firewall On
    echo Turning the Windows Firewall On

    netsh advfirewall set allprofiles state on
    netsh advfirewall show all

    set "fwoff=False"
    pause
    cls
    goto choice

:: Disable Network Adapter 
:E
    :: Disables network interface (Wireless Area Connection by default)
    title Quick Utility - Disable Network Adapter: %wifiint%
    echo Disabling %wifiint%

    netsh interface set interface "%wifiint%" Disable

    set "wifioff=True"
    pause
    cls
    goto choice

:: Enable Network Adapter
:F
    :: Enables network interface (Wireless Area Connection by default)
    title Quick Utility - Enable Network Adapter: %wifiint%
    echo Enabling %wifiint%

    netsh interface set interface "%wifiint%" Enable

    set "wifioff=False"
    pause
    cls
    goto choice

:: Show COM Ports
:G
    :: Lists all the COM (serial) ports on the device
    title Quick Utility - Show COM Ports
    echo Checking for COM Ports

    :: For all the COM devices gathered from wmic, set the _COM variables
    for /f "tokens=1* delims==" %%I in ('wmic path win32_pnpentity get caption /format:list ^| find "COM"') do (
        call :setCOM "%%~J"
    )

    set _COM
    pause
    cls
    goto choice

:: Ping Host
:H
    :: Prompts user for address and opens a new cmd window with the ping
    title Quick Utility - Ping Host
    echo After setting your address, I will open a new window with the ping results
    set /p "IP=What is the IP address or hostname of the device you wish to ping? "

    if "%ip%" == "" (
        echo No IP address provided!
        goto H
    )

    :: Open a new window with the ping results
    start cmd /c "ping -t %ip%"
    pause
    cls
    goto choice

:end
