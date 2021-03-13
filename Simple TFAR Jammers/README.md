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
- Conical jammers (i.e. jam only in a set direction+angle)

Features I'd *like* to add (but can't guarantee):
- Full CUPSIGNAL/Spectrum Device integration that adds a functional jammer antenna
- ACRE support

## Installation

Add it to your mission by copying the "cupjam" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupjam\cupjam_init.sqf";`

## Usage

Add a jammer using the following command:- 

`index = [pos, minRange, maxRange] call CUPJAM_addJammer`

`pos` is the position of the jammer. This can either be a constant position, or it can be an object. 

`minRange` is the minimum range of the jammer, in metres. Within this range, radios will be rendered completely inoperable. This parameter is option, and defaults to 25. 

`maxRange` is the maximum range of the jammer, in metres. Outside of this range, the jammer has no effect. Between the minimum and maximum ranges, the jammer will have a varying effect on radio quality. Optional, default 250. 

The returned value - assigned to `index` in the above example - is the index identifying the jammer in the script, to be used for the removal of jammers with the following:-

`index call CUPJAM_removeJammer`

NOTE FOR MULTIPLAYER: make sure you call the above commands on a single machine only, ideally the server (e.g. in an `isServer` block). 