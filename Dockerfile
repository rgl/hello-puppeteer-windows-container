# escape=`
#FROM mcr.microsoft.com/windows/servercore:ltsc2022 # NB does not work in this base image.
FROM mcr.microsoft.com/windows/server:ltsc2022
SHELL ["powershell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN cd $env:TMP; `
    $url = 'https://nodejs.org/dist/v18.16.0/node-v18.16.0-win-x64.zip'; `
    $sha256 = '4b3bd4cb5570cc217490639e93a7e1b7a7a341981366661e514ce61941824a85'; `
    Write-Host ('Downloading Node.js from {0}...' -f $url); `
    Invoke-WebRequest -Uri $url -OutFile node.zip; `
    Write-Host ('Verifying sha256 ({0})...' -f $sha256); `
    if ((Get-FileHash node.zip -Algorithm sha256).Hash -ne $sha256) { `
        Write-Host 'FAILED!'; `
        Exit 1; `
    }; `
    Write-Host 'Installing Node.js...'; `
    Expand-Archive node.zip .; `
    Rename-Item (Resolve-Path node-*-win-x64) node; `
    Move-Item node c:/; `
    Write-Host 'Removing unneeded files...'; `
    Remove-Item node.zip;
ENV PATH='C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0;C:\node'

WORKDIR c:/app
COPY package.json package-lock.json ./
RUN npm ci
COPY main.js ./
ENTRYPOINT ["node", "main.js"]
