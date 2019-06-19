Function Set-SpotiyPause {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $AccessCode
    )
    BEGIN {
        $Splatting = @{
            URI     = "https://api.spotify.com/v1/me/player/pause"
            Method  = "PUT"
            Headers = @{
                Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
            }
        }
    }
    PROCESS {
        try {
            Invoke-RestMethod @Splatting
            Write-Output "Playback was paused!"
        }
        catch {
            Throw "Cannot pause playback, is there no device playing?"
        }
    }
}