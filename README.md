# About

[![Build status](https://github.com/rgl/hello-puppeteer-windows-container/workflows/Build/badge.svg)](https://github.com/rgl/hello-puppeteer-windows-container/actions?query=workflow%3ABuild)

This is a [Puppeteer](https://github.com/puppeteer/puppeteer) Node.js example that runs Chromium inside a Windows container.

Also see:

* [rgl/HelloSeleniumWebDriver](https://github.com/rgl/HelloSeleniumWebDriver).
* [rgl/HelloSpecFlowSeleniumWebDriver](https://github.com/rgl/HelloSpecFlowSeleniumWebDriver).

## Caveats

* Chromium only runs inside the [Windows base container image](https://hub.docker.com/_/microsoft-windows) (13.3GB).
  * For more information see the [Container Base Images documentation](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-base-images).
* Chromium only runs in headless mode.

## Usage

Install docker and docker-compose.

Execute `run.ps1` inside a PowerShell session.

See the contents of the `tmp` directory.

**NB** This was tested in a Windows Server 2019 host. If you are using a different Windows version, you must modify the used container tag inside the [Dockerfile](Dockerfile).

## Alternatives

* [cypress](https://www.cypress.io/)
* [Playwright](https://playwright.dev/)
