Function Watch-Spotifyplayback {
    [Cmdletbinding(
        DefaultParameterSetName='AccessCode'
    )]
    param (
        [parameter(HelpMessage = "Session code from Connecting, either in global variable or json format",ParameterSetname='AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage="Import path voor JSON",ParameterSetName='JSON')]
        $Jsonfilepath
    )
    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'JSON') {
            $Jsonfilepath = 'C:\Temp\session.json'
            $session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
            try {
                Write-Output 'Refreshing auth token'
                $access_token = New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token
            }
            catch {
                Throw "Cannot refresh token!"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($Session.token_type) $($access_token)"; "contenttype" = "application/json"
                }
            }
        }
        else {
            try {
                Write-Output 'Refreshing auth token'
                $access_token = New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_id -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token
            }
            catch {
                Throw "Cannot refresh token! "
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        $track = Invoke-RestMethod @Splatting
        if ($null -eq $track) {
            Write-Output "refreshing auth token"
            $accestoken = New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token
            $session.access_token = $accestoken
            $session | ConvertTo-Json | Out-File $Jsonfilepath
            $track = Invoke-RestMethod @Splatting
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