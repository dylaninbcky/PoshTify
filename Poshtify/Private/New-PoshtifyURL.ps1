Function New-PoshtifyURL {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $Client_ID,
        [Parameter(Position = 1)]
        $RedirectURI = "http://localhost:8000/callback",
        [parameter(Position = 2)]
        $Authorizeendpoint = "https://accounts.spotify.com/authorize?",
        [parameter()]
        $ValidPermissions = @(
            "user-read-playback-state"
            "user-library-modify",
            "streaming",
            "user-read-private",
            "user-follow-modify",
            "user-library-read",
            "user-read-birthdate",
            "playlist-modify-public"
            "user-read-currently-playing",
            "user-modify-playback-state",
            "user-follow-read",
            "playlist-read-collaborative",
            "playlist-read-private",
            "app-remote-control",
            "user-read-recently-played",
            "playlist-modify-private"
        )
    )
    PROCESS {
        Add-Type -AssemblyName System.Web
        $encodedURI = [System.Web.HttpUtility]::UrlEncode($RedirectURI)
        $clientid = "client_id=$client_id&response_type=code"
        $redirecturiurl = "&redirect_uri=$encodedURI"
        $Permissions = "&scope=" + ($ValidPermissions -join '%20')
        $url = $Authorizeendpoint + $clientid + $redirecturiurl + $permissions
        return $url
    }
}