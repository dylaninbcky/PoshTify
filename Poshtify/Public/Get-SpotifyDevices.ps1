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
        }
        Catch { $devices = $null }
        if ($null -ne $devices) {
            if ($devices.devices.Count -gt 1) {
                for ($i = 0; $i -lt $Devices.devices.Count; $i++) {
                    $output += [PSCustomObject]@{
                        Name   = $Devices.devices.name[$i]
                        Type   = $Devices.devices.type[$i]
                        Volume = $Devices.devices.volume_percent[$i]
                        Actief = $Devices.devices.is_active[$i]
                    }
                }
            }
            else {
                $output = [PSCustomObject]@{
                    Name   = $Devices.devices.name
                    Type   = $Devices.devices.type
                    Volume = $Devices.devices.volume_percent
                    Actief = $Devices.devices.is_active
                }
            }
        }
        else {
            $output = "No devices available"
        }
        return $output
    }
}