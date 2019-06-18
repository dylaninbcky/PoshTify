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