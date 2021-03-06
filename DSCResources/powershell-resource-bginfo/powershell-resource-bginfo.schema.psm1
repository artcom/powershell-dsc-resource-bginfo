Configuration powershell-resource-bginfo {
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,
        
        [System.String]
        $BGInfoSrc = "https://download.sysinternals.com/files/BGInfo.zip",
        
        [System.String]
        $DownloadPath = "C:\rs-pkgs\BGInfo",
        
        [System.String]
        $InstallPath = "C:\Program Files\BgInfo",

        [System.String]
        $ZipFileName = "BGInfo.zip",

        [System.String]
        $ConfSrc = "https://github.com/artcom/powershell-dsc-resource-bginfo/blob/master/Config/bginfo_config_AC.bgi?raw=true",

        [System.String]
        $ConfFileName = "BGInfo.bgi",

        [System.String]
        $ConfPath = "C:\Program Files\BgInfo"

    )

    File DownloadFolder 
    {
        Ensure          = "Present"
        Type            = "Directory"
        DestinationPath = $DownloadPath
    }

    File ConfFolder 
    {
        Ensure          = "Present"
        Type            = "Directory"
        DestinationPath = $ConfPath
        DependsOn       = "[Archive]UnZip_BGInfo"
    }

    Script Get_BGInfo 
    {
        GetScript = {
            @{
                Result = (Join-Path -Path $using:DownloadPath -ChildPath $using:ZipFileName)
            } 
        }
        SetScript = {
            $OutFile = (Join-Path -Path $using:DownloadPath -ChildPath $using:ZipFileName)
            Invoke-WebRequest -Uri $using:BGInfoSrc -OutFile $OutFile
            Unblock-File -Path $OutFile
        }
        TestScript = { 
            $BGPath = (Join-Path -Path $using:DownloadPath -ChildPath $using:ZipFileName)
            Test-Path -Path $BGPath
        }
        DependsOn = "[File]DownloadFolder"
    }

    Script Get_BGConfig 
    {
        GetScript = {
            @{
                Result = (Join-Path -Path $using:ConfPath -ChildPath $using:ConfFileName)
            } 
        }
        SetScript = {
            $OutFile = (Join-Path -Path $using:ConfPath -ChildPath $using:ConfFileName)
            Invoke-WebRequest -Uri $using:ConfSrc -OutFile $OutFile
            Unblock-File -Path $OutFile
        }
        TestScript = { 
            $BGConfPath = (Join-Path -Path $using:ConfPath -ChildPath $using:ConfFileName)
            Test-Path -Path $BGConfPath
        }
        DependsOn = "[File]ConfFolder"
    }

    Archive UnZip_BGInfo
    {
        Path        = (Join-Path -Path $DownloadPath -ChildPath $ZipFileName)
        Destination = "$InstallPath"
        Force       = $True
        Ensure      = $Ensure
        DependsOn   = "[Script]Get_BGInfo"
    }

    Registry Reg_BGInfo
    {
        Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        ValueType   = "String"
        ValueName   = "bginfo"
        ValueData   = "`"$InstallPath\bginfo.exe`" `""+(Join-Path -Path $ConfPath -ChildPath $ConfFileName)+"`" /silent /accepteula /timer:0"
        Force       = $true
        Ensure      = $Ensure
        DependsOn   = @("[Archive]UnZip_BGInfo", "[Script]Get_BGConfig")
    }

}
