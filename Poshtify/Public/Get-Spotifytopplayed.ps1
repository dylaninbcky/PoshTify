Function Get-SpotifyTopplayed {
    [Cmdletbinding(DefaultParameterSetName = 'AccessCode')]
    param (
        [parameter(HelpMessage = "Session code from Connecting, ", ParameterSetname = 'AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage = "Import path voor JSON", ParameterSetName = 'JSON')]
        $Jsonfilepath,
        [parameter(Mandatory,HelpMessage = "Type voor top played, artists of tracks")]
        $type
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
                URI     = "https://api.spotify.com/v1/me/top/{0}" -f $type.ToLower()
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
                URI     = "https://api.spotify.com/v1/me/top/{0}" -f $type.ToLower()
                Method  = "Get"
                Headers = @{
                    Authorization = "$($Session.token_type) $($Session.access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        $output = @()
        try {
            $query = Invoke-RestMethod @Splatting
        }
        Catch {
            Write-Verbose $_.Exception | FL *
            Write-verbose $_
            Throw "Cannot connect to API hit -verbose"
        }
        if ($null -ne $query) {
            if ($type -eq 'tracks') {
                for ($i = 0; $i -lt $query.items.Length; $i++) {
                    $output += [PsCustomObject]@{
                    Name = $query.items.name[$i]
                    Artist = $query.items.artists.name[$i]
                    Popularity = $query.items.popularity[$i]
                    Album = $query.items.Album.name[$i]
                    id = $query.items.id[$i]
                    }
                }
            }
            elseif ($type -eq 'artists') {
                for ($i = 0; $i -lt $query.items.Length; $i++) {
                    $output += [PSCustomobject]@{
                       Name =  $query.items.name[$i]
                       Followers = $query.items.followers.total[$i]
                       Popularity = $query.items.popularity[$i]
                       id = $query.items.id[$i]
                    }
                }
            }
            else {
                Throw "Type not supported, artists or tracks"
            }
        }
        return $output
    }
}



Get-SpotifyTopplayed -AccessCode $global:AccessCode -type "tracks" -Verbose
