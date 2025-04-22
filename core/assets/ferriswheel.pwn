static  Float:FerrisOrigin[3] = {389.79834594727, -2028.4699707031, 22.0},
        Float:FerrisCageOffsets[NUM_FERRIS_CAGES][3] = {
        	{0.0699, 0.0600, -11.7500},
        	{-6.9100, -0.0899, -9.5000},
        	{11.1600, 0.0000, -3.6300},
        	{-11.1600, -0.0399, 3.6499},
        	{-6.9100, -0.0899, 9.4799},
        	{0.0699, 0.0600, 11.7500},
        	{6.9599, 0.0100, -9.5000},
        	{-11.1600, -0.0399, -3.6300},
        	{11.1600, 0.0000, 3.6499},
        	{7.0399, -0.0200, 9.3600}
        },
        FerrisWheel,
	    FerrisCages[NUM_FERRIS_CAGES],
	    Float:gCurrentTargetYAngle = 0.0,
 	    gWheelTransAlternate = 0;


Hook:FERRIS_OnGameModeInit()
{
    FerrisWheel = CreateObject(FERRIS_WHEEL_ID, FerrisOrigin[0], FerrisOrigin[1], FerrisOrigin[2], 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE);
    CreateObject(FERRIS_BASE_ID, FerrisOrigin[0], FerrisOrigin[1], FerrisOrigin[2], 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE);
    new x=0;
    while (x != NUM_FERRIS_CAGES)
    {
        FerrisCages[x] = CreateObject(FERRIS_CAGE_ID, FerrisOrigin[0], FerrisOrigin[1], FerrisOrigin[2], 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE);
        AttachObjectToObject(FerrisCages[x], FerrisWheel, FerrisCageOffsets[x][0], FerrisCageOffsets[x][1], FerrisCageOffsets[x][2], 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, 0);
        x++;
    }
    SetTimer("RotateWheel",3*1000,0);
    return true;
}


Hook:FERRIS_OnObjectMoved(objectid)
{
    if (objectid != FerrisWheel) return 0;
    SetTimer("RotateWheel",3*1000,0);
    return 1;
}

forward RotateWheel();
public RotateWheel()
{
    gCurrentTargetYAngle += 36.0;
    if (gCurrentTargetYAngle >= 360.0)
    {
		gCurrentTargetYAngle = 0.0;
    }
	if (gWheelTransAlternate) gWheelTransAlternate = 0;
	else gWheelTransAlternate = 1;

    new Float:fModifyWheelZPos = 0.0;
    if (gWheelTransAlternate) fModifyWheelZPos = 0.05;

    MoveObject(FerrisWheel, FerrisOrigin[0], FerrisOrigin[1], FerrisOrigin[2]+fModifyWheelZPos,
				FERRIS_WHEEL_SPEED, 0.0, gCurrentTargetYAngle, FERRIS_WHEEL_Z_ANGLE);
}
