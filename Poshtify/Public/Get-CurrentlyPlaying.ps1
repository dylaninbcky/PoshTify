Function Get-CurrentlyPlaying {
    [Cmdletbinding(DefaultParameterSetName = 'AccessCode')]
    param (
        [parameter(HelpMessage = "Session code from Connecting, ", ParameterSetname = 'AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage = "Import path voor JSON", ParameterSetName = 'JSON')]
        $Jsonfilepath
    )
    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'AccessCode') {
            try {
                $AccessCode.access_token = (New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_id -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token)
            }
            catch {
                Write-Verbose $_.Exception | FL *
                Throw "Cannot refresh token"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
                }
            }
        }
        else {
            $session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
            try {
                $Session.access_token = (New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token)
            }
            catch {
                Write-Verbose $_.Exception | FL *
                Throw "Cannot refresh token"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($Session.token_type) $($Session.access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        try {
            $track = Invoke-RestMethod @Splatting
        }
        Catch {
            Write-Verbose $_.Exception | FL *
            Throw "Cannot connect to API hit -verbose"
        }
        if ($null -ne $track) {
            $output = [PSCustomObject]@{
                Name       = $track.item.name
                Artist     = $track.item.artists.Name -join " "
                Duration   = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($track.item.duration_ms)
                Popularity = $track.item.popularity
                Album      = $track.item.album.name
                AlbumType  = $track.item.album.album_type
            }
        }
        return $output
    }
}

