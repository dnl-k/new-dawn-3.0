new VirtualWorlds[MAX_MODES][65] = {
    {0},
    {0},
    {200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264},
    {300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364},
    {400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464},
    {500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564},
    {600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664},
    {700,701,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764},
    {800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,830,831,832,833,834,835,836,837,838,839,840,841,842,843,844,845,846,847,848,849,850,851,852,853,854,855,856,857,858,859,860,861,862,863,864}
},
Float:WaveHeight[20] = {0.6,1.1,0.6,1.0,1.9,1.1,0.6,1.9,1.9,0.6,1.0,0.6,1.4,0.6,1.3,2.0,2.1,0.6,1.3,2.0};

forward LoadMap(gamemodeid);
forward CreateModeObject(modelid,Float:X,Float:Y,Float:Z,Float:rX,Float:rY,Float:rZ,Float:scale,bool:collisions,materialcolor,gamemodeid);
forward SetModelMaterialColor(modelid,materialcolor,bool:keep_texture,gamemodeid);
forward SetModeSettings(weather,hours,minutes,gamemodeid);
forward CreateModeSpawnpoint(modelid,Float:X,Float:Y,Float:Z,Float:rZ,gamemodeid);
forward CreateModeMarker(Float:X,Float:Y,Float:Z,Float:size,gamemodeid);
forward CreateModeMarkerEx(Float:X,Float:Y,Float:Z,type[],Float:size,gamemodeid);
forward InitiatePlayerSpawns(gamemodeid);
forward OnCountDownStateChange(gamemodeid,cdstate);
forward UnloadMap(gamemodeid);
forward EndRound(gamemodeid);

forward RequestVirtualWorld(playerid);
forward RequestMapRedo(playerid, gamemodeid);

public UnloadMap(gamemodeid)
{
    for (new objectid, j = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid <= j; objectid++)
	{
		if (!IsValidDynamicObject(objectid) || Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID) != gamemodeid)
			continue;
		DestroyDynamicObject(objectid);
		continue;
	}

    for (new areaid, j = Streamer_GetUpperBound(STREAMER_TYPE_AREA); areaid <= j; areaid++)
	{
		if (!IsValidDynamicArea(areaid))
			continue;
        new ArrayData[5];
        Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
        if((ArrayData[0] == AREA_TYPE_SPAWNPOINT || ArrayData[0] == AREA_TYPE_RACE_PICKUP || ArrayData[0] == AREA_TYPE_MARKER) && ArrayData[1] == gamemodeid)
        {
            DestroyDynamicArea(areaid);
            if(IsValidDynamic3DTextLabel(Text3D:ArrayData[3]))
                DestroyDynamic3DTextLabel(Text3D:ArrayData[3]);
        }
		continue;
	}

    for (new vehicleid, j = GetVehiclePoolSize(); vehicleid <= j; vehicleid++)
    {
        if (!IsValidVehicle(vehicleid))
            continue;
        if(GetVehicleVirtualWorld(vehicleid) >= VirtualWorlds[gamemodeid][0] && GetVehicleVirtualWorld(vehicleid) <= VirtualWorlds[gamemodeid][64])
            DestroyVehicle(vehicleid);
    }
    return true;
}

public LoadMap(gamemodeid)
{
    if (cache_num_rows())
	{
		new tmp[256];

		cache_get_value(0, "strFilePointer", tmp);

        SendRconCommandf("loadfs ../maps/%s", tmp);

        new script[256];
        format(script, sizeof(script), "../maps/%s", tmp);
        CallFunctionInScript(script, "LoadMapFilterscript", "i", gamemodeid);
        if (Modes[gamemodeid][Gamemode] == GAMEMODE_RACE)
            SetTimerEx("DelayPlayerSpawnForGameMode", 2000, false, "i", gamemodeid);
        else
            CallLocalFunction("InitiatePlayerSpawns", "i", gamemodeid);
	}
    return true;
}

public SetModeSettings(weather,hours,minutes,gamemodeid)
{
    Modes[gamemodeid][Weather] = weather;
    Modes[gamemodeid][TimeH] = hours;
    Modes[gamemodeid][TimeM] = minutes;
	for (new playerid,j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
			continue;
		SetPlayerWeather(playerid, weather);
		SetPlayerTime(playerid, hours, minutes);
	}
	return true;
}

public CreateModeObject(modelid,Float:X,Float:Y,Float:Z,Float:rX,Float:rY,Float:rZ,Float:scale,bool:collisions,materialcolor,gamemodeid)
{
    if (!collisions || (modelid == 9812 && floatcmp(1.0, scale)) || modelid == 19945)
		return INVALID_OBJECT_ID;
    if (Modes[gamemodeid][Weather] < 20) Z = Z + WaveHeight[Modes[gamemodeid][Weather]];
    else Z = Z + 0.6;
    new objectid = CreateDynamicObjectEx(modelid, X, Y, Z, rX, rY, rZ, 300.0, 300.0, VirtualWorlds[gamemodeid]);
    Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, gamemodeid);
	if (!floatcmp(scale, 0.0))
    {
    	for (new id, iterations = GetMaterialIterationsForModel(modelid); id < iterations; id++)
			SetDynamicObjectMaterial(objectid, id, 0, "none", "none", 0);
    }
    if(materialcolor != 0x00000000)
        SetDynamicObjectMaterial(objectid, 0, 18646, "matcolours", "white", materialcolor);
    return objectid;
}

public SetModelMaterialColor(modelid,materialcolor,bool:keep_texture,gamemodeid)
{
    for (new objectid, j = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid <= j; objectid++)
	{
		if (!IsValidDynamicObject(objectid) || Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID) != gamemodeid)
			continue;
        if (Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID) == modelid && !IsDynamicObjectMaterialUsed(objectid, 0))
        {
            for (new id, iterations = GetMaterialIterationsForModel(modelid); id < iterations; id++)
            {
                if (keep_texture)
                    SetDynamicObjectMaterial(objectid, id, -1, "none", "none", materialcolor);
                else
                    SetDynamicObjectMaterial(objectid, id, 18646, "matcolours", "white", materialcolor);
            }
        }
		continue;
	}
    return true;
}


stock SendModeMessage(gamemodeid, color, message[])
{
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][ModeID] != gamemodeid)
			continue;
		SendClientMessage(playerid, color, message);
	}
}

stock SendModeMessagef(gamemodeid, color, format[], va_args<>)
{
	new out[256];
	va_format(out, sizeof(out), format, va_start<3>);
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][ModeID] != gamemodeid)
			continue;
		SendClientMessage(playerid, color, out);
	}
}

stock SendAdminModeMessagef(gamemodeid, color, format[], va_args<>)
{
	new out[256];
	va_format(out, sizeof(out), format, va_start<3>);
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn])
			continue;
        if (Player[playerid][ModeID] == gamemodeid || Player[playerid][AdminLevel])
		      SendClientMessage(playerid, color, out);
	}
}

stock SendAdminMessage(color, message[])
{
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || !Player[playerid][AdminLevel])
			continue;
		SendClientMessage(playerid, color, message);
	}
}

stock SendAdminMessagef(color, format[], va_args<>)
{
	new out[256];
	va_format(out, sizeof(out), format, va_start<2>);
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || !Player[playerid][AdminLevel])
			continue;
		SendClientMessage(playerid, color, out);
	}
}

/** ------------------- **/
/** S P E C T A T I N G **/
/** ------------------- **/

Hook:MAIN_OPVirtualWorldChange(playerid, newvirtualworld)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER || GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        for (new spectateid, j = GetPlayerPoolSize(); spectateid <= j; spectateid++)
        {
            if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || !Player[spectateid][Spectating] || Player[spectateid][SpectateID] != playerid || GetPlayerState(spectateid) != PLAYER_STATE_SPECTATING)
                continue;
            SetPlayerVirtualWorld(spectateid, newvirtualworld);
        }
    }
    return true;
}

Hook:MAIN_OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_SPECTATING && oldstate != PLAYER_STATE_NONE)
    {
        if (Player[playerid][Spectating])
        {
            Player[playerid][SpectateID] = playerid;
            for (new spectateid, j = GetPlayerPoolSize(); spectateid <= j; spectateid++)
            {
                if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || GetPlayerState(spectateid) == PLAYER_STATE_SPECTATING)
                    continue;
                /*if(GetPlayerState(spectateid) == PLAYER_STATE_SPECTATING)
                {
                    if (Player[spectateid][SpectateID] == playerid)
                        CallLocalFunction("OnPlayerStateChange", "iii", spectateid, PLAYER_STATE_SPECTATING, PLAYER_STATE_NONE);
                    continue;
                }*/
                Player[playerid][SpectateID] = spectateid;
                SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectateid));
                if (IsPlayerInAnyVehicle(spectateid))
                    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectateid));
                else
                    PlayerSpectatePlayer(playerid, spectateid);
                break;
            }
        }
    }
    else if (newstate == PLAYER_STATE_ONFOOT)
    {
        for (new spectateid, j = GetPlayerPoolSize(); spectateid <= j; spectateid++)
        {
            if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || !Player[spectateid][Spectating] || Player[spectateid][SpectateID] != playerid)
                continue;
            PlayerSpectatePlayer(spectateid, playerid);
        }
    }
    else if (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        for (new spectateid, j = GetPlayerPoolSize(); spectateid <= j; spectateid++)
        {
            if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || !Player[spectateid][Spectating] || Player[spectateid][SpectateID] != playerid)
                continue;
            PlayerSpectateVehicle(spectateid, GetPlayerVehicleID(playerid));
        }
    }
    return true;
}

Hook:MAIN_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && Player[playerid][Spectating])
    {
        if (newkeys & KEY_FIRE) // Left -> Backwards
        {
            new bool:restartedLoop = false;
            for (new spectateid = Player[playerid][SpectateID] - 1; spectateid >= -1; spectateid--)
            {
                if (spectateid == -1 && !restartedLoop)
                {
                    spectateid = GetPlayerPoolSize() + 1;
                    restartedLoop = true;
                    continue;
                }
                else if (spectateid == -1 && restartedLoop)
                    break;
                if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || GetPlayerState(spectateid) == PLAYER_STATE_SPECTATING)
                    continue;
                Player[playerid][SpectateID] = spectateid;
                SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectateid));
                if (IsPlayerInAnyVehicle(spectateid))
                    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectateid));
                else
                    PlayerSpectatePlayer(playerid, spectateid);
                break;
            }
        }
        if (newkeys & KEY_AIM) // Right - Forwards
        {
            new bool:restartedLoop = false;
            for (new spectateid = Player[playerid][SpectateID] + 1, j = GetPlayerPoolSize() + 1; spectateid <= j; spectateid++)
            {
                if (spectateid == j && !restartedLoop)
                {
                    spectateid = -1;
                    restartedLoop = true;
                    continue;
                }
                else if (spectateid == j && restartedLoop)
                    break;
                if (!IsPlayerConnected(spectateid) || Player[spectateid][ModeID] != Player[playerid][ModeID] || GetPlayerState(spectateid) == PLAYER_STATE_SPECTATING)
                    continue;
                Player[playerid][SpectateID] = spectateid;
                SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectateid));
                if (IsPlayerInAnyVehicle(spectateid))
                    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectateid));
                else
                    PlayerSpectatePlayer(playerid, spectateid);
                break;
            }
        }
    }
    return true;
}

/** -------------------------- **/
/** S P E C T A T I N G  E N D **/
/** -------------------------- **/
