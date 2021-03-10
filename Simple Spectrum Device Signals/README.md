# Dead Simple Spectrum Signal Script

A script that implements signal detection functionality for the Spectrum Device. 

Features include:
- Automatic setup of Spectrum Device parameters
- Dead Simple setup
- Signals can be either a set position or attached to an object
- Signals attenuated by both distance and direction
- Simulated in 3D; optional 2D mode also available
- Sync'd for multiplayer
- Different frequency ranges for different Spectrum Device antennae
- Optional TFAR integration; active radios will appear as trackable signals
- A whole bunch of options for customisation

Features that are planned to be added:
- Nothing! Everything is here already

Features I'd *like* to add:
- Implement Spectrum Device "transmit" function, which will add a signal for others to track
- Implement ACRE integration

Features that are not included, and not planned:
- Terrain/obstacles blocking signals
- Proper signal strength simulation (it simply works on a 0-100% scale, relative to the max/min ranges of signals)

## Installation

Add it to your mission by copying the "cupsignal" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupsignal\cupsignal_init.sqf";`

There are a number of global parameters you can change at the top of cupsignal_init.sqf, if you so choose. 

## Usage

Add a signal using the following command:-

`index = [pos, freq, maxRange, minRange, directional] call CUPSIGNAL_addSignal;`

`pos` is the position of the signal. This can be either a position (above ground level; if the height is omitted, it defaults to 0), or an object (the signal will be attached to the object). 

`freq` is the frequency of the signal. Try to keep this in the range of the antennae, for what should be obvious reasons. 

`maxRange` is the maximum range of the signal in metres. Beyond this, it cannot be detected, and its strength attenuates towards 0 as you approach this distance. This parameter is optional, defaulting to 500m. 

`minRange` is the minimum range, in metres. Within this distance, the signal is always at 100% strength. Optional, defaults to 5m. 

`directional` sets whether this signal is directional; that is, if you need to be looking at it to detect it. Optional, defaults to true. 

Note that the defaults for the above can be changed in cupsignal_init.sqf. 

IMPORTANT NOTE FOR MULTIPLAYER: Make sure you only add signals on a single machine! Ideally, this should be the server, so you should add these inside an `isServer` block. You can add them on the client-side, but only do that if you know for sure that it will only run locally. 

The return value - shown above as being assigned to `index` - is the index of the newly-created signal. This is only required if you intend to remove the signal later, via the following command:-

`index call CUPSIGNAL_removeSignal;`

There is also the following command:

`index call CUPSIGNAL_calculateSignalStrength`

As it says, this will calculate the signal strength for the given signal index for the local player and return it. If the signal index is invalid, it will return -1. 

## TFAR Integration

Enabling the TFAR integration is a simple matter of using the following command:

`[minSWrange, maxSWrange, minLRrange, maxLRrange] call CUPSIGNAL_enableTFARIntegration;`

Obviously, this requires TFAR to function. Make sure you only call this server-side (e.g. in an `isServer` block). 

The parameters should be self-explanatory; they are the minimum and maximum ranges for short-wave and long-range radios respectively (diver radios are ignored). They are all optional, defaulting to `[1, 500, 5, 2500]`.