# escape=`
#FROM mcr.microsoft.com/windows/servercore:1809 # NB does not work in this base image.
FROM mcr.microsoft.com/windows:1809
SHELL ["powershell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN cd $env:TMP; `
    $url = 'https://nodejs.org/dist/v14.16.1/node-v14.16.1-win-x64.zip'; `
    $sha256 = 'e469db37b4df74627842d809566c651042d86f0e6006688f0f5fe3532c6dfa41'; `
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
RUN npm install
COPY main.js ./
ENTRYPOINT ["node", "main.js"]
