Function Get-CurrentlyPlaying {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $AccessCode
    )
    BEGIN {
        $Splatting = @{
            URI     = "https://api.spotify.com/v1/me/player/currently-playing"
            Method  = "Get"
            Headers = @{
                Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
            }
        }
    }
    PROCESS {
        $track = try {
            Invoke-RestMethod @Splatting
        }
        Catch {
            Throw "Cannot connect to API"
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
