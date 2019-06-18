Function New-PoshtifyAccesstoken {
    param(
        [parameter()]
        $TokenEndpoint = "https://accounts.spotify.com/api/token",
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_ID,
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_Secret,
        [parameter()][ValidateNotNullOrEmpty()]
        $refresh_token
    )
    BEGIN {
        $grant_type = "refresh_token" 
    }
    PROCESS {

        #build body 
        $bodystring = 'grant_type={0}&refresh_token={1}' -f $grant_type, $refresh_token
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

        return $response.access_token
    }
}