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

Function Get-Spotifyplaylists {
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
                URI     = "https://api.spotify.com/v1/me/playlists"
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
                URI     = "https://api.spotify.com/v1/me/playlists"
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
            Throw "Cannot connect to API hit -verbose"
        }
        if ($list.items.Count -gt 1) {
            for ($i = 0; $i -lt $list.items.Count; $i++) {
                $output += [PsCustomObject]@{
                    Name = $list.items.name[$i]
                    Owner = $list.items.owner.display_name[$i]
                    Totaltracks = $list.items.tracks.total[$i]
                    Public = $list.items.public[$i]
                    id = $list.items.id[$i]
                }
            }
        }
        else{
            $output = [PsCustomObject]@{
                Name = $list.items.name
                Owner = $list.items.owner.display_name
                Totaltracks = $list.items.tracks.total
                Public = $list.items.public
                id = $list.id
            }
        }
        return $output 
    }
}

Function Watch-Spotifyplayback {
    [Cmdletbinding(DefaultParameterSetName='AccessCode')]
    param (
        [parameter(HelpMessage = "Session code from Connecting, either in global variable or json format",ParameterSetname='AccessCode')]
        $AccessCode = $global:AccessCode,
        [parameter(HelpMessage="Import path voor JSON",ParameterSetName='JSON')]
        $Jsonfilepath
    )
    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'JSON') {
            ##Importing JSON
            $Session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
            #refreshing auth token for access
            Write-Output 'Refreshing auth token'
            $Session.access_token = (New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token)
            #changing JSON file for later use in other functions
            $Session | ConvertTo-Json | Out-File $Jsonfilepath -Force
            #building the API query
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($Session.token_type) $($Session.access_token)"; "contenttype" = "application/json"
                }
            }
        }
        else {
            try {
                Write-Output 'Refreshing auth token'
                $AccessCode.access_token = (New-PoshtifyAccesstoken -Client_ID $AccessCode.Client_id -Client_Secret $AccessCode.Client_Secret -refresh_token $AccessCode.refresh_token)
                $AccessCode | ConvertTo-Json | Out-File $Jsonfilepath -Force
            }
            catch { 
                Throw "Cannot refresh token!"
            }
            $Splatting = @{
                URI     = "https://api.spotify.com/v1/me/player/currently-playing"
                Method  = "Get"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        try {
            $track = Invoke-RestMethod @Splatting
        }
        catch {
            Write-Verbose $_.Exception | FL *
            Throw "Cannot connect to API!! hit -verbose for more info"
        }
        ##get artist id and build API query
        $ArtistSplatting = @{
            URI     = "https://api.spotify.com/v1/artists/{0}" -f $track.item.artists.id
            Method  = "Get"
            Headers = @{
                Authorization = "$($Session.token_type) $($session.access_token)"; "contenttype" = "application/json"
            }
        }
        try {
            $artist = Invoke-RestMethod @ArtistSplatting
        }
        catch {
            Write-Verbose $_.Exception | FL *
            Throw "Cannot get artist info! Is there a song playing? Check spotify playback and hit -verbose"
        }
        if ($null -ne $track) {
            $output = [PSCustomObject]@{
                Name         = $track.item.name
                Artist       = $track.item.artists.Name -join ","
                Duration     = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($track.item.duration_ms)
                Popularity   = $track.item.popularity
                Album        = $track.item.album.name
                AlbumType    = $track.item.album.album_type
                Release      = $track.item.album.release_date
                AlbumArtists = $track.item.album.artists.Name -join ","
                Genres       = $artist.genres -join ","
                Followers    = $artist.followers.total -join ","
                Markets      = $track.item.available_markets -join ","
            }
        }
        return $output
    }
}

Function Get-Spotifyplaylists {
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
            ValueFromPipeline
        )]
        $ID
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
                URI     = "https://api.spotify.com/v1/playlists/{0}/tracks" -f $ID
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
                URI     = "https://api.spotify.com/v1/playlists/{0}/tracks" -f $ID
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
            Throw "Cannot connect to API hit -verbose"
        }
        if ($list.items.Count -gt 1) {
            for ($i = 0; $i -lt $list.items.Count; $i++) {
                $output += [PSCustomObject]@{
                    Name = $list.items.name[$i]
                    Owner = $list.items.owner.display_name[$i]
                    Totaltracks = $list.items.tracks.total[$i]
                    Public = $list.items.public[$i]
                    id = $list.items.id[$i]
                }
            }
        }
        else{
            $output += [PsCustomObject]@{
                Name = $list.items.name
                Owner = $list.items.owner.display_name
                Totaltracks = $list.items.tracks.total
                Public = $list.items.public
                id = $list.items.id
            }
        }
        return $output
    }
}

Get-Spotifyplaylists -Jsonfilepath 'C:\Temp\session.json'


Watch-Spotifyplayback -Jsonfilepath 'C:\Temp\session.json'

$Jsonfilepath = 'C:\Temp\session.json'
$session = Get-Content -Raw -Path $Jsonfilepath | ConvertFrom-Json
$id = '7viNUmZZ8ztn2UB4XB3jIL'
$Splatting = @{
    URI     = "https://api.spotify.com/v1/playlists//tracks" -f $ID
    Method  = "Get"
    Headers = @{
        Authorization = "$($Session.token_type) $($Session.access_token)"; "contenttype" = "application/json"
    }
}
$list = Invoke-RestMethod @Splatting

$Splatting = @{
    URI     = "https://api.spotify.com/v1/me/player/currently-playing"
    Method  = "Get"
    Headers = @{
        Authorization = "$($Session.token_type) $($session.access_token)"; "contenttype" = "application/json"
    }
}
$track = Invoke-RestMethod @Splatting

$id = "7ge3QfYPMTjDbMoVLuuIuJ"
$Splatting = @{
    URI     = "https://api.spotify.com/v1/artists/{0}" -f $id
    Method  = "Get"
    Headers = @{
        Authorization = "$($Session.token_type) $($session.access_token)"; "contenttype" = "application/json"
    }
}
$artist = Invoke-RestMethod @Splatting

$Splatting = @{
    URI     = "https://api.spotify.com/v1/me/playlists"
    Method  = "Get"
    Headers = @{
        Authorization = "$($Session.token_type) $($session.access_token)"; "contenttype" = "application/json"
    }
}
$list = Invoke-RestMethod @Splatting