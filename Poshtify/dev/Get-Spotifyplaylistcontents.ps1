Function Get-Spotifyplaylistcontents {
    [Cmdletbinding(DefaultParameterSetName = 'AccessCode')]
    param (
        [parameter(HelpMessage = "Session code from Connecting, ", ParameterSetname = 'AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage = "Import path voor JSON", ParameterSetName = 'JSON')]
        $Jsonfilepath,
        [parameter(
            Helpmessage = "Playlist ID",
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [string]$ID
    )
    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'AccessCode') {
            try {
                $AccessCode.access_token = (New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_id -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token)
            }
            catch {
                Write-Verbose $_
                Write-Verbose $_.Exception | FL *
                Throw "Cannot refresh token"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/playlists/$ID/tracks"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
                }
            }
        }
        else {
            $session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
            $Session.access_token = (New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token)
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/playlists/$ID/tracks"
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
            $list = Invoke-RestMethod @Splatting
        }
        Catch {
            Write-Verbose $_.Exception | FL *
            Write-Verbose $_
            Throw "Cannot connect to API -verbose"
        }
        if ($list.items.Count -gt 1) {
            for ($i = 0; $i -lt $list.items.Count; $i++) {
                $output += [PSCustomObject]@{
                    Name = $list.items.track.name[$i]
                    Artists = $list.items.track.artists.name[$i] -join ','
                    Duration = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($list.items.track.duration_ms[$i])
                    id = $list.items.track.id[$i]
                }
            }
        }
        else{
            $output += [PsCustomObject]@{
                Name = $list.items.track.name
                Artists = $list.items.track.artists.name -join ','
                Duration = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($list.items.track.duration_ms[0])
                id = $list.items.track.id
            }
        }
        return $output
    }

}Function Get-Spotifyplaylistcontents {
    [Cmdletbinding(DefaultParameterSetName = 'AccessCode')]
    param (
        [parameter(HelpMessage = "Session code from Connecting, ", ParameterSetname = 'AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage = "Import path voor JSON", ParameterSetName = 'JSON')]
        $Jsonfilepath,
        [parameter(
            Helpmessage = "Playlist ID",
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [string]$ID
    )
    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'AccessCode') {
            try {
                $AccessCode.access_token = (New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_id -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token)
            }
            catch {
                Write-Verbose $_
                Write-Verbose $_.Exception | Format-List *
                Throw "Cannot refresh token"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/playlists/$ID/tracks"
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
                Write-Verbose $_
                Write-Verbose $_.Exception | Format-List *
                Throw "Cannot refresh token"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/playlists/$ID/tracks"
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
            $list = Invoke-RestMethod @Splatting
        }
        Catch {
            Write-Verbose $_.Exception | FL *
            Write-Verbose $_
            Throw "Cannot connect to API -verbose"
        }
        if ($list.items.Count -gt 1) {
            for ($i = 0; $i -lt $list.items.Count; $i++) {
                $output += [PSCustomObject]@{
                    Name = $list.items.track.name[$i]
                    Artists = $list.items.track.artists.name[$i] -join ','
                    Duration = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($list.items.track.duration_ms[$i])
                    id = $list.items.track.id[$i]
                }
            }
        }
        else{
            $output += [PsCustomObject]@{
                Name = $list.items.track.name
                Artists = $list.items.track.artists.name -join ','
                Duration = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($list.items.track.duration_ms[0])
                id = $list.items.track.id
            }
        }
        return $output
    }

}