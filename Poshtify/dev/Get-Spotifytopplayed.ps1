<#

Cannot use permission scope user-top-read sigh.  	https://github.com/spotify/web-api/issues/1262

#>

Function Get-SpotifyTopplayed {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        $AccessCode,
        [parameter(Mandatory, Position = 1, HelpMessage = "Artists or Tracks")]
        $Type,
        [parameter(HelpMessage="The number of entities to return. Default: 20. Minimum: 1. Maximum: 50. For example: limit=2")]
        $limit = 50,
        [parameter(HelpMessage="Valid values: long_term (calculated from several years of data), medium_term 
        (approximately last 6 months), short_term (approximately last 4 weeks).")]
        $time_range = "long_term"
    )
    BEGIN {
        if ($type -like "Artist*") {
            $Splatting = @{
                URI     = 'https://api.spotify.com/v1/me/top/artists?limit={0}?time_range={1}' -f $limit,$time_range
                Method  = "GET"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
                }
            }
        }
        elseif ($type -like "Tracks*"){
            $Splatting = @{
                URI     = 'https://api.spotify.com/v1/me/top/tracks?limit={0}?time_range={1}' -f $limit,$time_range
                Method  = "GET"
                Headers = @{
                    Authorization = "$($AccessCode.token_type) $($AccessCode.access_token)"; "contenttype" = "application/json"
                }
            }
        }
    }
    PROCESS {
        ## Cannot use permission scope user-top-read sigh.  	https://github.com/spotify/web-api/issues/1262
        
    }
}