# Overview

Reign for Spotify is a remote for friends, colleagues, housemates and yourself that works in any browser.
It's available for download at [reignalot.com](http://reignalot.com) and in the [Mac App Store](https://itunes.apple.com/en/app/reign-for-spotify/id553794498?mt=12).

What makes Reign unique is that it uses a web page to feed commands to Spotify. Making any device with a web browser a potential remote; iPhone/Android phones, tablets, but also Playstation Vita's, e-Readers etc.

![Reign for Spotify](https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-prn1/66291_454088921295852_55691272_n.jpg)

# Compiling

## Opening the project

* Double click the `SpotifyRemoteWorkspace.xcworkspace` to open the project in Xcode.

## Quick look around

* The workspace consists of two projects: Reign and a Helper. The Helper is used to launch Reign on startup;
* There are build schemes for App Store and Non App Store distribution;
* Some code (like the preferences window) differs between App Store and Non App Store (mainly because of Sparkle);
* The Server opens a http socket using CocoaHTTPServer, broadcasts it using Bonjour and feeds commands to Spotify using AppleScript;
* The Client uses CocoAsyncSocket looks around for other Reign servers;
* Comments are minimal, sorry, might fix that later.

## Things you need to add

* The App Store build uses [Receigen](http://receigen.etiemble.com/) for receipt validation, remove the build step and code in main.m if you don't have it;
* The dsa_pub.pem file for Sparkle is obviously missing.

# Purpose and pull-requests

* For us, this is a pet project, but we'll try our best to merge additions to our code;
* Bug-fixes and other stuff we can learn from are awesome;
* New features are great.

# Credits

Robbie Hanson - [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)

Robbie Hanson - [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)

Robbie Hanson - [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack)

Ahmet Ardal - [DisableSubviews](https://github.com/ardalahmet/DisableSubviews)

Vadim Shpakovski - [MASPreferences](https://github.com/shpakovski/MASPreferences)

Alex Zielenski - [StartAtLoginController](https://github.com/alexzielenski/StartAtLoginController)

Andy Matuschak - [Sparkle](http://sparkle.andymatuschak.org/)

# Contributors

Boy van Amstel - [boyvanamstel](https://github.com/boyvanamstel)

Dan Gilbert - [daentech](https://github.com/daentech)

# License for the rest of it

New BSD License, see `LICENSE` for details.
