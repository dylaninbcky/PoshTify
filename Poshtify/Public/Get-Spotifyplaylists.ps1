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
            $Session.access_token = (New-PoshtifyAccesstoken -Client_ID $session.Client_id -Client_Secret $session.Client_Secret -refresh_token $session.refresh_token)
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
                $output += [PSCustomObject]@{
                    Name = [string]$list.items.name[$i]
                    Owner = [string]$list.items.owner.display_name[$i]
                    Totaltracks = [string]$list.items.tracks.total[$i]
                    Public = [string]$list.items.public[$i]
                    ID = [string]$list.items.id[$i]
                }
            }
        }
        else{
            $output += [PsCustomObject]@{
                Name = $list.items.name
                Owner = $list.items.owner.display_name
                Totaltracks = $list.items.tracks.total
                Public = $list.items.public
                ID = $list.items.id
            }
        }
        return $output
    }
}
