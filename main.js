"use strict";

const { program } = require('commander');
const puppeteer = require('puppeteer');

function log(message) {
    console.log(`${new Date().toISOString()} ${message}`);
}

async function main(options) {
    var browserConfig = {};
    if (options.debug) {
        browserConfig = {
            headless: false,
            devtools: true,
            slowMo: 250,
        };
    }

    log("Launching the browser...");
    const browser = await puppeteer.launch(browserConfig);
    const page = await browser.newPage();
    await page.setViewport({
        width: parseInt(options.viewportSize.split('x')[0], 10),
        height: parseInt(options.viewportSize.split('x')[1], 10),
        deviceScaleFactor: 1,
    });
    log(`Launched the ${await browser.version()} browser.`);

    log(`Opening ${options.url}...`);
    await page.goto(options.url);

    log("Taking a screenshot...");
    await page.screenshot({ path: options.screenshotPath });

    log("Closing the browser...");
    await browser.close();

    log("Exiting...");
}

program
    .option('--url <url>', 'web page to open', 'https://en.m.wikipedia.org/wiki/Main_Page')
    .option('--screenshot-path <path>', 'screenshot output path', 'screenshot.png')
    .option('--viewport-size <size>', 'browser viewport size', '800x600')
    .option('--debug', 'run the browser in foreground', false)
    .parse(process.argv);

main(program.opts());
