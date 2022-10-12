# GibTV

Proof-of-concept macOS app for controlling Apple TVs, powered by the `TVRemoteCore` framework.

Features:

- [x] `RemoteTextInput` integration for natural text input
- [x] `CoreGraphics`/`HID` integration for gesture swipes as seen on the [Apple TV HD remote](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP724/SP724_us.png)
- [x] Support for clicking the various buttons on the remote, and key bindings for easy access.

## Demo 

[GibTV PIP Final Trimmed.webm](https://user-images.githubusercontent.com/8052613/195455797-517b8b29-632d-4121-8cc8-7048e17d11a7.webm)


## Prerequisites to run

This uses private entitlements, so you'll need to do one of the following:
- Disable AMFI
- Load your own code signatory using `AMFITrustedKeys`
- Work at Apple
