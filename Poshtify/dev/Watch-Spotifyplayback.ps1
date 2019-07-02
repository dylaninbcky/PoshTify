Function Watch-Spotifyplayback{
    param (
        [parameter(HelpMessage="Session code from Connecting, either in global variable or json format")]
        $Autcode,
        [parameter()]
        [switch]$JSON,
        [parameter(HelpMessage="Als Json switch aanstaat, input voor file.")]
        $Jsonfilepath
    )
    BEGIN {
        if ($JSON){
            ConvertFrom-Json -InputObject $Jsonfilepath
            ##json file import. Refreshing token if needed,
        }
        
    }
}