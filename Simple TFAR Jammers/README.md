# Dead Simple Task Force Radio Jammer Script

A script that implements TFAR radio jammers. 

Features include:
- Dead Simple setup
- Radio quality scales with proximity to jammers
- Within a certain range, radios are completely useless
- Multiple jammers can overlap, applying their effects multiplicatively
- Sync'd for multiplayer
- Optional CUPSIGNAL integration, allowing jammers to be tracked down with the Spectrum Device

Features that are planned to be added:
- Support for Zeus Remote Control

Features I'd *like* to add (but can't guarantee):
- Full CUPSIGNAL/Spectrum Device integration that adds a functional jammer antenna
- ACRE support
- Better documentation

## Installation

Add it to your mission by copying the "cupjam" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupjam\cupjam_init.sqf";`

## Usage

Add a jammer using the following command:- 

`index = [pos, maxRange, minRange, direction, angle] call CUPJAM_addJammer`

`pos` is the position of the jammer. This can either be a constant position, or it can be an object. 

`maxRange` is the maximum range of the jammer, in metres. Outside of this range, the jammer has no effect. Between the minimum and maximum ranges, the jammer will have a varying effect on radio quality. Optional, default 250. 

`minRange` is the minimum range of the jammer, in metres. Within this range, radios will be rendered completely inoperable. Optional, default 25.

`direction` is the direction the jammer is facing. If this is set, the jammer will only affect units in a cone in this direction. This can be either a single number for azimuth, in which case it will be simulated in 2D (i.e. height is ignored), or an array for a vector direction, in which case it will be simulated in 3D. By default, this is nil, i.e. disabled. 

`angle` is the angle of the cone in degrees, if the above `direction` is set. Note that the actual cone angle is double this number (think radius vs diameter). Default 60.

For more advanced applications, you can pass code as any of the above parameters. It will be run with an array parameter as follows: `[pos, maxRange, minRange, signalIndex, direction, angle]`. `signalIndex` is the index of the CUPSIGNAL signal linked to this jammer (or nil, if CUPSIGNAL integration is disabled); all other parameters are as defined in the `addJammer` call. Note that the code will run locally for each player. 

The returned value - assigned to `index` in the above example - is the index identifying the jammer in the script, to be used for the removal of jammers with the following:-

`index call CUPJAM_removeJammer`

NOTE FOR MULTIPLAYER: make sure you call the above commands on a single machine only, ideally the server (e.g. in an `isServer` block). 