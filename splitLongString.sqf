/**
Splits a string into an array of substrings, each smaller than or equal to a given length. 

Input: Array:
	0 - The string to be split
	1 - The desired length

Output: Array of strings, of the desired length (or less).

[string, length] execVM "splitLongString.sqf";

by Professor Cupcake
**/

_inputString = _this select 0;
_length = _this select 1;

_outputArray = [_inputString];

while {count (_outputArray select (count _outputArray - 1)) > _length} do
{
	_curString = _outputArray select (count _outputArray - 1);
	_newStringShort = _curString select [0, _length];
	_newStringLong = _curString select [_length];
	_outputArray set [count _outputArray - 1, _newStringShort];
	_outputArray pushBack _newStringLong;
};

_outputArray
