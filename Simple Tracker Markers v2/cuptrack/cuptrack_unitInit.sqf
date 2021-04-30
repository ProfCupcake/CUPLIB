_this spawn
{
	waitUntil {!(isNil "CUPTRACK_setTrack")};
	_this call CUPTRACK_setTrack;
};