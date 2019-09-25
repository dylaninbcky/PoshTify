Function Connect-PoshTify {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $ClientID,
        [parameter(Mandatory, Position = 1)]
        $ClientSecret,
        [parameter(HelpMessage = "for JSON output ## TESTING")]
        [switch]$JSON,
        [parameter(HelpMessage = "Output path, ONLY IF JSON SWITCH IS ACTIVATED")]
        $outputpath
    )
    BEGIN {
        $URL = New-PoshtifyURL -Client_ID $ClientID
    }
    PROCESS {
        try {
            Write-Output "Spotify auth code is being generated"
            $AUTHCODE = Get-PoshtifyAuthcode -URL $URL
        }
        catch {
            Throw "Cannot create auth code!"
        }
        if ($AUTHCODE) {
            try {
                $Token = Get-Poshtifyrefreshtoken -AuthCode $AUTHCODE -Client_ID $ClientID -Client_Secret $ClientSecret
                if (!$JSON) {
                    $token | Add-Member -NotePropertyName 'Client_ID' -NotePropertyValue $ClientID
                    $token | Add-Member -NotePropertyName 'Client_Secret' -NotePropertyValue $ClientSecret
                    Set-Variable -Name AccessCode -Value $Token -Scope Global
                    Write-Output 'Global variable created, check by running $global:Accesscode'
                }
                else {
                    if ($JSON) {
                        $token | Add-Member -NotePropertyName 'Client_ID' -NotePropertyValue $ClientID
                        $token | Add-Member -NotePropertyName 'Client_Secret' -NotePropertyValue $ClientSecret
                        ConvertTo-Json -InputObject $token | Out-File "$outputpath\session.json"
                        Write-Output 'JSON created!'
                    }
                    else {
                        Write-Error 'JSON File path not supplied! exiting'
                    }
                }
            
            }
            catch {
                Throw "Cannot open login page" 
            }
        }
        else {
            Throw "Auth code is empty, did you provide clientid & secret?"
        }
    }
}