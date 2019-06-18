Function Get-Poshtifyrefreshtoken {
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $AuthCode,
        [parameter()]
        $RedirectURI = "http://localhost:8000/callback",
        [parameter()]
        $TokenEndpoint = "https://accounts.spotify.com/api/token",
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_ID,
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_Secret
    )
    BEGIN {
        Add-Type -AssemblyName System.Web
        $grant_type = "authorization_code"
        $encodeduri = [System.Web.HttpUtility]::UrlEncode($RedirectURI)
    }
    PROCESS {

        #build body 
        $bodystring = 'grant_type={0}&redirect_uri={1}&code={2}' -f $grant_type, $encodeduri, $AuthCode
        #creds
        $bodystring += '&client_id={0}&client_secret={1}' -f $Client_ID, $Client_Secret
        #calling other function
        $args = @{
            Uri         = $TokenEndpoint
            Method      = "Post"
            ContentType = "application/x-www-form-urlencoded"
            Body        = $bodystring
            Erroraction = "Stop"
        }
        $Response = Invoke-RestMethod @args

        return $Response
    }
}