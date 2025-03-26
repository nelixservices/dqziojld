@Echo off
chcp 65001
cls
mode 81,35
color 0B
echo.
echo.                 ╔╩════════════════════════════════════════════╩╗
echo.                 ║ ARP Woofer Developed by Nelix Services       ║
echo.                 ╚══════════════════════════════════════════════╝
echo                                 ★┬┬┬┬┬┏━━━┓┬┬┬┬┬★  
echo.                                ├┼┼┼┼┏┫●↓━┣┓┼┼┼┼┤ 
echo.                                ├┼┼┏┓┗┫┗━┛┣┛┏┓┼┼┤ 
echo.                                ├┼┼┃┃┏┻━━━┻┓┃┃┼┼┤ 
echo.                                ├┼┏┫┣╋┓   ┏╋┫┣┓┼┤ 
echo.                                ├┏┫┃┃┃┃   ┃┃┃┃┣┓┤ 
echo.                                ├┗┻┻┻╋┛   ┗╋┻┻┻┛┤ 
echo.                                ★┴┴┴┴┗━━━━━┛┴┴┴┴★            
echo.                           ╔╩═══════════════════════╩╗    
echo.                           ║   Super Ud ARP Woofer   ║                         
echo.                           ╚═════════════════════════╝   
@echo off
title so ud 
:: Check for administrator privileges
NET SESSION >nul 2>nul
if %errorlevel% neq 0 (
    echo Administrator privileges required. Please run this script as an administrator.
    pause
    exit /b
)

setlocal EnableDelayedExpansion
net stop winmgmt /y
REM Proceeds to reset all settings and fix the IPv6 flag for fn

netsh interface ipv6 uninstall

REM Disable File and Printer Sharing for Microsoft Networks
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=no

REM Enable QoS Packet Scheduler
netsh int tcp set global autotuninglevel=normal

REM Disable Microsoft Networks Adapter Multiplexor Protocol
netsh interface set interface "Microsoft Network Adapter Multiplexor Protocol" admin=disabled

REM Disable Microsoft LLDP Protocol Driver
sc config lltdsvc start=disabled

REM Disable Internet Protocol Version 6 (TCP/IPv6)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 0xFFFFFFFF /f

REM Disable Link-Layer Topology Discovery Responder
netsh advfirewall firewall set rule group="Network Discovery" new enable=no

REM Disable Link-Layer Topology Discovery Mapper I/O Driver
sc config lltdsvc start=disabled

REM Advanced Network Properties Configuration
REM Disable Advanced EEE
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EEE /t REG_DWORD /d 0 /f

REM Set Network Address to Not Present
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v NetworkAddress /t REG_SZ /d "" /f

REM Disable ARP Offload
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v ArpOffload /t REG_DWORD /d 0 /f

REM Disable Flow Control
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f

REM Disable IPv4 Checksum Offload
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpChecksumOffloadIPv4 /t REG_DWORD /d 0 /f

REM Disable Large Send Offload v2 (IPv6)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v LargeSendOffloadv2IPv6 /t REG_DWORD /d 0 /f

REM Disable TCP Checksum Offload (IPv6)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpChecksumOffloadIPv6 /t REG_DWORD /d 0 /f

REM Disable UDP Checksum Offload (IPv6)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v UdpChecksumOffloadIPv6 /t REG_DWORD /d 0 /f

echo Network properties have been configured.

REM Generate random binary data and set registry entries
setlocal enabledelayedexpansion
set keyName=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters
set valueNameDNS=Dhcpv6DNSServers
set valueNameSearchList=Dhcpv6DomainSearchList
set valueNameDUID=Dhcpv6DUID
set valueNameDisabled=DisabledComponents

REM Generate random binary values
for /L %%i in (1,1,14) do (
    set /A randomDNS=!random! & set randomDNSHex=!randomDNS:~0,2!
    set /A randomSearchList=!random! & set randomSearchListHex=!randomSearchList:~0,2!
    set /A randomDUID=!random! & set randomDUIDHex=!randomDUID:~0,2!
    set randomDNS=!randomDNS!!randomDNSHex!
    set randomSearchList=!randomSearchList!!randomSearchListHex!
    set randomDUID=!randomDUID!!randomDUIDHex!
)

REM Set random binary values in the registry
reg add "%keyName%" /v "%valueNameDNS%" /t REG_BINARY /d %randomDNS% /f
reg add "%keyName%" /v "%valueNameSearchList%" /t REG_BINARY /d %randomSearchList% /f
reg add "%keyName%" /v "%valueNameDUID%" /t REG_BINARY /d %randomDUID% /f

REM Add DisabledComponents registry entry
reg add "%keyName%" /v "%valueNameDisabled%" /t REG_DWORD /d 1 /f

echo Random binary values and DisabledComponents set for registry entries.

REM Execute commands without administrative privileges
netsh advfirewall reset
netsh winsock reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winhttp reset autoproxy
netsh winhttp reset proxy
netsh winhttp reset tracing
netsh interface ipv4 reset
netsh interface portproxy reset
netsh interface httpstunnel reset
netsh interface tcp reset
netsh interface teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
netsh interface ipv6 isatap set state state=disabled
arp -d

exit /b