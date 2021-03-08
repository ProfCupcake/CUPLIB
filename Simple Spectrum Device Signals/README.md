# Dead Simple Spectrum Signal Script

A script that implements signal detection functionality for the Spectrum Device. 

## Installation

Add it to your mission by copying the "cupsignal" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupsignal\cupsignal_init.sqf";`

There are a number of global parameters you can change at the top of cupsignal_init.sqf, if you so choose. 

## Usage

Add a signal using the following command:-

`index = [pos, freq, maxRange, minRange, directional] call CUPSIGNAL_addSignal;`

`pos` is the position of the signal. This can be either a 2D arry, or an object. 

`freq` is the frequency of the signal. Try to keep this in the range of the antennae, for what should be obvious reasons. 

`maxRange` is the maximum range of the signal in metres. Beyond this, it cannot be detected, and its strength attenuates towards 0 as you approach this distance. This parameter is optional, defaulting to 500m. 

`minRange` is the minimum range, in metres. Within this distance, the signal is always at 100% strength. Optional, defaults to 5m. 

`directional` sets whether this signal is directional; that is, if you need to be looking at it to detect it. Optional, defaults to true. 

Note that the defaults for the above can be changed in cupsignal_init.sqf. 

The return value - shown above as being assigned to `index` - is the index of the newly-created signal. This is only required if you intend to remove the signal later, via the following command:-

`index call CUPSIGNAL_removeSignal;`