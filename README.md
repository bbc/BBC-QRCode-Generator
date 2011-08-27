# BBC QRCode Generator

## Overview

A Sinatra application that will generate QRCodes for a BBC url with a BBC logo embedded in it.

## Requirements

This application requires [ImageMagick](http://www.imagemagick.org/) to be installed. I use [homebrew](http://github.com/mxcl/homebrew) which made the process very easy with:

    brew install imagemagick

Other dependencies can be installed running:

    bundle install

The application uses [bit.ly](https://bitly.com/) to shorten the urls and check they are from the BBC. This service require a bit.ly api key and account which can be got for free from the bit.ly website. Once you have these credentials the app expects them to live in a file called .bitlyrc in your home directory.

## Resources

* [More fun with QRCodes and the BBC logo](http://whomwah.com/2008/03/12/more-fun-with-qr-codes-and-the-bbc-logo/)
* [wikipedia](http://en.wikipedia.org/wiki/QR_Code)
* [Denso-Wave website](http://www.denso-wave.com/qrcode/index-e.html)

## Authors

Original author: [Duncan Robertson](http://whomwah.com)

## Copyright

[MIT Licence](http://www.opensource.org/licenses/mit-license.html)
