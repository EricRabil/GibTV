# GibTV

Proof-of-concept macOS app for controlling Apple TVs, powered by the `TVRemoteCore` framework.

Features:

- [x] `RemoteTextInput` integration for natural text input
- [x] `CoreGraphics`/`HID` integration for gesture swipes as seen on the [Apple TV HD remote](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP724/SP724_us.png)
- [x] Support for clicking the various buttons on the remote, and key bindings for easy access.

## Demo (YouTube)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=wL1JcmDq7P8" target="_blank">
 <img src="http://img.youtube.com/vi/wL1JcmDq7P8/mqdefault.jpg" alt="Watch the video" border="10" />
</a>

## Prerequisites to run

This uses private entitlements, so you'll need to do one of the following:
- Disable AMFI
- Load your own code signatory using `AMFITrustedKeys`
- Work at Apple
