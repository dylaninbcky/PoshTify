Function Watch-Spotifyplayback {
    param (
        [parameter(HelpMessage = "Session code from Connecting, either in global variable or json format")]
        $AccessCode = $global:Accesscode,
        [parameter()]
        [switch]$JSON,
        [parameter(HelpMessage = "Als Json switch aanstaat, input voor file.")]
        $Jsonfilepath
    )
    BEGIN {
        if ($JSON) {
            $session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
            $access_token = New-PoshtifyAccesstoken -Client_ID $session.Client_ID -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/albums/{0}" -f  $id
                Method  = "GET"
                Headers = @{
                    Authorization = "$($Session.token_type) $($access_token)"; "contenttype" = "application/json"
                }
            }
        }
        else{
            $access_token = New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_ID -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/albums/{0}" -f  $id
                Method  = "GET"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        $album = Invoke-RestMethod @Splatting
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