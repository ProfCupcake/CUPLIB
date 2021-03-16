# Dead Simple Spectrum Signal Script

A script that implements signal detection functionality for the Spectrum Device. 

Features include:
- Automatic setup of Spectrum Device parameters
- Dead Simple setup
- Signals can be either a set position or attached to an object
- Signals attenuated by both distance and direction
- Signals can be either a sphere or a cone
- Simulated in 3D; optional 2D mode also available
- Sync'd for multiplayer
- Different frequency ranges for different Spectrum Device antennae
- Optional transmission function, allowing your Spectrum Device to emit a signal for others to track
- Optional jamming function for the jammer antenna (requires [CUPJAM](https://github.com/ProfCupcake/CUPLIB/tree/master/Simple%20TFAR%20Jammers) )
- Optional TFAR integration; active radios will appear as trackable signals
- A whole bunch of options for customisation

Features I'd *like* to add (but can't guarantee):
- Implement ACRE integration
- Better documentation; this readme is a mess
- Support for Zeus Remote Control

Features that are not included, and not planned:
- Terrain/obstacles blocking signals
- Proper signal strength simulation (it simply works on a 0-100% scale, relative to the max/min ranges of signals)

## Installation

Add it to your mission by copying the "cupsignal" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupsignal\cupsignal_init.sqf";`

There are a number of global parameters you can change at the top of cupsignal_init.sqf, if you so choose. 

## Usage

Add a signal using the following command:-

`index = [pos, freq, maxRange, minRange, directional, forwardsDirection, angle, args] call CUPSIGNAL_addSignal;`

`pos` is the position of the signal. This can be either a position (above ground level; if the height is omitted, it defaults to 0), or an object (the signal will be attached to the object). 

`freq` is the frequency of the signal. Try to keep this in the range of the antennae, for what should be obvious reasons. 

`maxRange` is the maximum range of the signal in metres. Beyond this, it cannot be detected, and its strength attenuates towards 0 as you approach this distance. This parameter is optional, defaulting to 500m. 

`minRange` is the minimum range, in metres. Within this distance, the signal is always at 100% strength. Optional, defaults to 5m. 

`directional` sets whether this signal is directional; that is, if you need to be looking at it to detect it. Optional, defaults to true. 

`forwardsDirection` defines the direction the signal is facing. If this is set, the signal will be simulated as a cone facing this direction, and only detectable by units within this cone. This can be either a single number for azimuth, which will simulate it in 2D (i.e. ignores height), or an array defining a vector direction for 3D simulation. By default, this is nil, i.e. disabled. 

`angle` defines the angle of the signal cone in degrees, only used if the `forwardsDirection` is set. Players must be within this angle of the direction from the signal position to detect it. Note that the actual effective angle is double this (think radius vs diameter). Default 60.

Note that the defaults for the above can be changed in cupsignal_init.sqf. 

For more advanced applications, you can also pass code blocks as any of the parameters above. These will have the value of `args` passed to them, and should return a valid value for that parameter. `args` is set to `[]` (empty array) by default. Note that they will run locally for each player. 

IMPORTANT NOTE FOR MULTIPLAYER: Make sure you only add signals on a single machine! Ideally, this should be the server, so you should add these inside an `isServer` block. You can add them on the client-side, but only do that if you know for sure that it will only run locally. 

The return value - shown above as being assigned to `index` - is the index of the newly-created signal. This is only required if you intend to remove the signal later, via the following command:-

`index call CUPSIGNAL_removeSignal;`

There is also the following command:-

 `strength = index call CUPSIGNAL_calculateSignalStrength`

As it says, this will calculate the signal strength for the given signal index for the local player and return it. If the signal index is invalid, it will return -1. 

## Transmission Function

Enabling the transmission function is a simple matter of using the following command:

`[maxRange, minRange, angle] call CUPSIGNAL_addTransmitAction;`

This will add an action to the player, available when they have the Spectrum Device in their hand, which will let them transmit on the current frequency. 

You can also toggle transmission via your primary fire bind (LMB by default). 

The parameters should be self-explanatory; they are the maximum and minimum ranges of transmission signals, and the angle of the signal cone. They are all optional, and default to `[500, 1, 60]`. 

In order to be able to transmit, you must:-
- Have the Spectrum Device equipped and selected (you cannot even see the action without this)
- Have an antenna attached
- Have a frequency selected that is within the antenna's range

If you switch weapon, change antenna, or change frequency while transmitting, the transmission will automatically deactivate. 

## Jamming Function

Enabling the jamming function is similarly simple: 

`[maxRange, minRange, angle, antenna] call CUPSIGNAL_setupJammerAntenna;`

This will setup the jammer antenna so that, if you transmit with it, it will actually function as a radio jammer. This requires [CUPJAM](https://github.com/ProfCupcake/CUPLIB/tree/master/Simple%20TFAR%20Jammers) and the above `addTransmitAction`. Without CUPJAM, it will break, and without `addTransmitAction`, it just won't do anything. 

The parameters are the same as above; max and min ranges and angle for the jammer, defaulting to `[250, 25, 60]`. The jammer will still emit a signal at the selected frequency. The parameter `antenna` defines which antenna is counted as the jammer antenna; this is set to `muzzle_antenna_03_f` by default (the jammer antenna) and should probably be left that way. 

## TFAR Integration

Enabling the TFAR integration is also quite simple:

`[minSWrange, maxSWrange, minLRrange, maxLRrange] call CUPSIGNAL_enableTFARIntegration;`

Obviously, this requires TFAR to function, and must be called on every client. 

The parameters should be self-explanatory; they are the minimum and maximum ranges for short-wave and long-range radios respectively (diver radios are ignored). They are all optional, defaulting to `[1, 500, 5, 2500]`.