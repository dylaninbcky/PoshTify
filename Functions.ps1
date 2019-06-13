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


Function Get-PoshtifyAuthcode {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $URL
    )
    PROCESS {
        [void]@(
            Add-Type -AssemblyName System.Windows.Forms
            $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 800; Height = 800 }
            $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 800; Height = 800; Url = $Url }
            $completed = {
                if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") {
                    $form.Close()
                }
            }
            $web.ScriptErrorsSuppressed = $true
            $web.Add_DocumentCompleted($completed)
            $form.Controls.Add($web)
            $form.Add_Shown( { $form.Activate() })
            $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
            $form.ShowDialog()
            $queryOutput = $web.Url.Query.Replace("?code=", "")
        )
        return $queryOutput
    }
}

Function Convertto-Base64($string) {
    PROCESS {
        $BYTES = [System.Text.Encoding]::Unicode.GetBytes($string)
        $encoded = [Convert]::ToBase64String($BYTES)
        return $encoded
    }
} 

Function Get-Poshtifyrefreshtoken {
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $AuthCode,
        [parameter()]
        $RedirectURI = "http://localhost:8000/callback",
        [parameter()]
        $TokenEndpoint = "https://accounts.spotify.com/api/token",
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_ID,
        [parameter()][ValidateNotNullOrEmpty()]
        $Client_Secret
    )
    BEGIN {
        Add-Type -AssemblyName System.Web
        $grant_type = "authorization_code"
        $encodeduri = [System.Web.HttpUtility]::UrlEncode($RedirectURI)
    }
    PROCESS {

        #build body 
        $bodystring = 'grant_type={0}&redirect_uri={1}&code={2}' -f $grant_type, $encodeduri, $AuthCode
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

        return $Response
    }
}

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
        } Catch {$track = $null}
        if ($null -ne $track){
            $output = [PSCustomObject]@{
                Name = $track.item.name
                Artist = $track.item.artists.Name -join " "
                Duration = '{0:mm}:{0:ss}' -f [timespan]::FromMilliseconds($track.item.duration_ms)
                Popularity = $track.item.popularity
                Album = $track.item.album.name
                AlbumType = $track.item.album.album_type
            }
        }

        return $output
    }
}

Function Get-SpotifyDevices {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $AccessCode
    )
    BEGIN {
        $Splatting = @{
            URI     = "https://api.spotify.com/v1/me/player/devices"
            Method  = "Get"
            Headers = @{
                Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
            }
        }
    }
    PROCESS {
        $output = @()
        $Devices = try {
            Invoke-RestMethod @Splatting
        } Catch {$devices = $null}
        if ($null -ne $devices){
            for ($i = 0; $i -lt $Devices.devices.Length; $i++){
                $output += [PSCustomObject]@{
                    Name = $Devices.devices.name[$i]
                    Type = $Devices.devices.type[$i]
                    Volume = $Devices.devices.volume_percent[$i]
                    Actief = $Devices.devices.is_active[$i]
                }
            }
        }
        else{
            $output = "No devices available"
        }
        return $output
    }
}

