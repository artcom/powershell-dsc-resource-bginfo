Configuration rsBGInfo
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,
        
        [System.String]
        $BGInfoSource = "https://download.sysinternals.com/files/BGInfo.zip",
        
        [System.String]
        $DownloadPath = "C:\rs-pkgs\BGInfo",
        
        [System.String]
        $InstallPath = "C:\Program Files\BgInfo",

        [System.String]
        $BGConfigPath = "C:\Program Files\WindowsPowerShell\Modules\rsBGInfo\Config\bginfo_config_for_DOAS.bgi"

    )

    Import-DscResource -ModuleName rsFileDownload
    
    rsFileDownload Get_BGInfo
    {
        DestinationFolder   = $DownloadPath
        SourceURL           = $BGInfoSource
        DestinationFileName = "BGInfo.zip"
        Ensure              = $Ensure
    }

    Archive UnZip_BGInfo
    {
        Path                = "$DownloadPath\BGInfo.zip"
        Destination         = "$InstallPath"
        Force               = $True
        Ensure              = $Ensure
        DependsOn           = "[rsFileDownload]Get_BGInfo"
    }

    Registry Reg_BGInfo
    {
        Key                 = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        ValueType           = "String"
        ValueName           = "bginfo"
        ValueData           = "$InstallPath\bginfo.exe $BGConfigPath /silent /accepteula /timer:0"
        Force               = $true
        Ensure              = $Ensure
        DependsOn           = "[Archive]UnZip_BGInfo"
    }


}
