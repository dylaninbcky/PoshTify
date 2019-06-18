Function Connect-PoshTify {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory,Position = 0)]
        $ClientID,
        [parameter(Mandatory,Position = 1)]
        $ClientSecret
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
            Set-Variable -Name AccessCode -Value $Token -Scope Global
            Write-Output 'Global variable created, check by running $global:Accesscode'
            }
            catch{
                Throw "Cannot open login page" 
            }
        }
        else{
            Throw "Auth code is empty, did you provide clientid & secret?"
        }
    }
}