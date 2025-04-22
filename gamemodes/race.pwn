static bool:RequiresReset[MAX_PLAYERS];

forward CreateModeRacePickup(type,Float:X,Float:Y,Float:Z,modelid,gamemodeid);
forward OnPlayerReachHunter(playerid,gamemodeid);
forward DelayPlayerSpawnForGameMode(gamemodeid);

public DelayPlayerSpawnForGameMode(gamemodeid)
{ return CallLocalFunction("InitiatePlayerSpawns", "i", gamemodeid); }

CreateRaceStage(modelid, id, worldid, variable[], skins[], name1[], name2[], name3[])
{
    variable[0] = CreateVehicle(modelid, Stages[id][2][0], Stages[id][2][1], Stages[id][2][2], Stages[id][2][3], -1, -1, -1, false);
    SetVehicleVirtualWorld(variable[0], worldid);
    variable[1] = CreateVehicle(modelid, Stages[id][4][0], Stages[id][4][1], Stages[id][4][2], Stages[id][4][3], -1, -1, -1, false);
    SetVehicleVirtualWorld(variable[1], worldid);
    variable[2] = CreateVehicle(modelid, Stages[id][6][0], Stages[id][6][1], Stages[id][6][2], Stages[id][6][3], -1, -1, -1, false);
    SetVehicleVirtualWorld(variable[2], worldid);

    variable[3] = CreateActor(skins[0], Stages[id][3][0], Stages[id][3][1], Stages[id][3][2], Stages[id][3][3]);
    SetActorVirtualWorld(variable[3], worldid);
    variable[4] = CreateActor(skins[1], Stages[id][5][0], Stages[id][5][1], Stages[id][5][2], Stages[id][5][3]);
    SetActorVirtualWorld(variable[4], worldid);
    variable[5] = CreateActor(skins[2], Stages[id][7][0], Stages[id][7][1], Stages[id][7][2], Stages[id][7][3]);
    SetActorVirtualWorld(variable[5], worldid);

    new string[32];
    format(string, sizeof(string), "1st\n{FFFFFF}» %s «",name1);
    variable[6] = _:CreateDynamic3DTextLabel(string, 0xC98910FF, Stages[id][3][0], Stages[id][3][1], Stages[id][3][2] + 1.32, 300.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, worldid);
    format(string, sizeof(string), "2nd\n{FFFFFF}» %s «",name2);
    variable[7] = _:CreateDynamic3DTextLabel(string, 0xA8A8A8FF, Stages[id][5][0], Stages[id][5][1], Stages[id][5][2] + 1.32, 300.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, worldid);
    format(string, sizeof(string), "3rd\n{FFFFFF}» %s «",name3);
    variable[8] = _:CreateDynamic3DTextLabel(string, 0x965A38FF, Stages[id][7][0], Stages[id][7][1], Stages[id][7][2] + 1.32, 300.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, worldid);
}

Hook:RC_InitiatePlayerSpawns(gamemodeid)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    SetTimerEx("OnCountDownStateChange", 10000, false, "ii", gamemodeid, 4);
	return true;
}

Hook:RC_OnCountDownStateChange(gamemodeid,cdstate)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    switch(cdstate)
    {
        case -1:
        {
            for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		    {
		    	if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
		    		continue;
                TextDrawHideForPlayer(playerid, SKEW_BANNER);
		    	PlayerTextDrawHide(playerid, SKEW_BANNER_TEXT_CB[playerid]);
		    }
        }
        case 0:
        {
            SetTimerEx("OnCountDownStateChange", 1000, false, "ii", gamemodeid, -1);

            for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		    {
		    	if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
		    		continue;
		    	if (IsPlayerInAnyVehicle(playerid))
                {
		    		SetVehicleParamsEx(GetPlayerVehicleID(playerid), VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
                    RepairVehicle(GetPlayerVehicleID(playerid));
                }
		    	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

                if (!IsTextDrawVisibleForPlayer(playerid, SKEW_BANNER))
                    TextDrawShowForPlayer(playerid, SKEW_BANNER);

		    	PlayerTextDrawSetString(playerid, SKEW_BANNER_TEXT_CB[playerid], "~g~GO");

                if (!IsPlayerTextDrawVisible(playerid, SKEW_BANNER_TEXT_CB[playerid]))
                    PlayerTextDrawShow(playerid, SKEW_BANNER_TEXT_CB[playerid]);
		    }

		    for (new areaid, j = Streamer_GetUpperBound(STREAMER_TYPE_AREA); areaid <= j; areaid++)
	    	{
	    		if (!IsValidDynamicArea(areaid) || Streamer_GetIntData(STREAMER_TYPE_AREA,areaid,E_STREAMER_TYPE) != STREAMER_AREA_TYPE_SPHERE)
	    			continue;
	    		new ArrayData[5];
	    		Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
				if (ArrayData[0] != AREA_TYPE_SPAWNPOINT || ArrayData[1] != gamemodeid)
					continue;
				if (IsValidObject(ArrayData[4]))
					DestroyObject(ArrayData[4]);
			}
        }
        case 1,2,3:
        {
            SetTimerEx("OnCountDownStateChange", 1000, false, "ii", gamemodeid, cdstate-1);
            if(cdstate == 1)
            {
                for (new vehicleid, j = GetVehiclePoolSize(); vehicleid <= j; vehicleid++)
                {
                    if (!IsValidVehicle(vehicleid))
                        continue;
                    if(GetVehicleVirtualWorld(vehicleid) >= VirtualWorlds[gamemodeid][0] && GetVehicleVirtualWorld(vehicleid) <= VirtualWorlds[gamemodeid][64] && !IsVehicleOccupied(vehicleid))
                        DestroyVehicle(vehicleid);
                }
            }
            new string[4];
            valstr(string,cdstate);
			for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		    {
		    	if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
		    		continue;
		    	PlayerPlaySound(playerid,1056,0.0,0.0,0.0);

                if (!IsTextDrawVisibleForPlayer(playerid, SKEW_BANNER))
                    TextDrawShowForPlayer(playerid, SKEW_BANNER);

		    	PlayerTextDrawSetString(playerid, SKEW_BANNER_TEXT_CB[playerid], string);

                if (!IsPlayerTextDrawVisible(playerid, SKEW_BANNER_TEXT_CB[playerid]))
                    PlayerTextDrawShow(playerid, SKEW_BANNER_TEXT_CB[playerid]);

                if (cdstate == 3 && IsPlayerInAnyVehicle(playerid))
                {
                    new vehicleid = GetPlayerVehicleID(playerid),
                        Float:X,Float:Y,Float:Z,Float:Rot,Color1,Color2;
                    GetVehicleSpawnInfo(vehicleid, X, Y, Z, Rot, Color1, Color2);
                    SetVehiclePos(vehicleid, X, Y, Z);
                    SetVehicleZAngle(vehicleid, Rot);
                }
		    }
        }
        case 4:
        {
            SetTimerEx("OnCountDownStateChange", 1000, false, "ii", gamemodeid, 3);
        }
    }
    return true;
}

public CreateModeRacePickup(type,Float:X,Float:Y,Float:Z,modelid,gamemodeid)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    if (Modes[gamemodeid][Weather] < 20) Z = Z + WaveHeight[Modes[gamemodeid][Weather]];
    else Z = Z + 0.6;

    if ((type == 0 || type == 1) && IsPointInAnyDynamicArea(X, Y, Z))
    {
		for (new id = 0; id <= Streamer_GetUpperBound(STREAMER_TYPE_AREA); id++)
        {
			if (!IsValidDynamicArea(id) || Streamer_GetIntData(STREAMER_TYPE_AREA, id, E_STREAMER_TYPE) != STREAMER_AREA_TYPE_CYLINDER)
				continue;

            new Array[5];
            Streamer_GetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, Array);
            if (Array[0]!= AREA_TYPE_RACE_PICKUP || Array[1] != gamemodeid || Array[2] > 1)
                continue;

			new Float:distance;
			Streamer_GetDistanceToItem(X, Y, Z, STREAMER_TYPE_AREA, id, distance);
			if(distance > 1.0)
				continue;

			Array[2] = 3;
			Streamer_SetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, Array);
			UpdateDynamic3DTextLabelText(Text3D:Array[3], COL_LIGHTBLUE_PURPLE, "[ {FFFFFF}Repair & Nitro"#EMB_COL_LIGHTBLUE_PURPLE" ]");
			return false;
		}
	}

    new pickupid = CreateDynamicCylinder(X, Y, Z - 4.0, Z + 4.0, 4.5),
        ArrayData[5],
        text[64];

    ArrayData[0] = AREA_TYPE_RACE_PICKUP;
    ArrayData[1] = gamemodeid;
    ArrayData[2] = type;
    strins(text, "[ {FFFFFF}", 0);
    switch (type)
    {
        case 0: ArrayData[3] = strins(text, "Repair", strlen(text));
        case 1: ArrayData[3] = strins(text, "Nitro", strlen(text));
        case 2: ArrayData[3] = strins(text, VehicleNames[modelid - 400], strlen(text));
        case 3: strins(text, "Repair & Nitro", strlen(text));
    }
    strins(text, ""#EMB_COL_LIGHTBLUE_PURPLE" ]", strlen(text));
    ArrayData[3] = _:CreateDynamic3DTextLabelEx(text, COL_LIGHTBLUE_PURPLE, X, Y, Z, 100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, false, 100.0, VirtualWorlds[gamemodeid]);
    ArrayData[4] = modelid;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, pickupid, E_STREAMER_EXTRA_ID, ArrayData);
    return pickupid;
}

Hook:RC_CreateModeSpawnpoint(modelid,Float:X,Float:Y,Float:Z,Float:rZ,gamemodeid)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    if (Modes[gamemodeid][Weather] < 20) Z = Z + WaveHeight[Modes[gamemodeid][Weather]];
    else Z = Z + 0.6;
	new spawnid = CreateDynamicSphereEx(X, Y, Z, 1.0, VirtualWorlds[gamemodeid]),
		Float:VModelX,Float:VModelY,Float:VModelZ,
		ArrayData[5];

	GetVehicleModelInfo(modelid, VEHICLE_MODEL_INFO_SIZE, VModelX, VModelY, VModelZ);

    ArrayData[0] = AREA_TYPE_SPAWNPOINT;
    ArrayData[1] = gamemodeid;
    ArrayData[2] = modelid;
    ArrayData[3] = _:rZ;
	ArrayData[4] = CreateObject(6959, X, Y, Z - (VModelZ / 2), 0.0, 0.0, 0.0, 300.0);
	SetObjectMaterial(ArrayData[4], 0, 16644, "a51_detailstuff", "roucghstonebrtb", 0);

	Streamer_SetArrayData(STREAMER_TYPE_AREA, spawnid, E_STREAMER_EXTRA_ID, ArrayData);
	return spawnid;
}

Hook:RC_CreateModeMarker(Float:X,Float:Y,Float:Z,Float:size,gamemodeid)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    if (Modes[gamemodeid][Weather] < 20) Z = Z + WaveHeight[Modes[gamemodeid][Weather]];
    else Z = Z + 0.6;

    new markerid = CreateDynamicSphereEx(X, Y, Z, size, VirtualWorlds[gamemodeid]),
        ArrayData[2];
    ArrayData[0] = AREA_TYPE_MARKER;
    ArrayData[1] = gamemodeid;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, markerid, E_STREAMER_EXTRA_ID, ArrayData);
    return markerid;
}

Hook:RC_CreateModeMarkerEx(Float:X,Float:Y,Float:Z,type[],Float:size,gamemodeid)
{
    if (Modes[gamemodeid][Gamemode] != GAMEMODE_RACE)
        return -1;
    if (Modes[gamemodeid][Weather] < 20) Z = Z + WaveHeight[Modes[gamemodeid][Weather]];
    else Z = Z + 0.6;

    new markerid = -1, ArrayData[2];
    if (!strcmp(type, "checkpoint", true))
        markerid = CreateDynamicCylinderEx(X, Y, Z, Z + size, size / 2, VirtualWorlds[gamemodeid]);
    ArrayData[0] = AREA_TYPE_MARKER;
    ArrayData[1] = gamemodeid;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, markerid, E_STREAMER_EXTRA_ID, ArrayData);
    return markerid;
}


static CurrentVehicle[MAX_PLAYERS];

Hook:RC_OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(Modes[Player[playerid][ModeID]][Gamemode] == GAMEMODE_RACE)
    {
        if (newstate == PLAYER_STATE_DRIVER)
        {
            CurrentVehicle[playerid] = GetPlayerVehicleID(playerid);
            Audio_StopRadio(playerid);
        }
        else if (oldstate == PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_ONFOOT)
            CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
    }
    return true;
}

Hook:RC_OnPlayerUpdate(playerid)
{
    if (Modes[Player[playerid][ModeID]][Gamemode] == GAMEMODE_RACE)
    {
        if (!IsPlayerInAnyVehicle(playerid) && GetPlayerAnimationIndex(playerid) == 1208 && (GetVehicleModelGroup(GetVehicleModel(CurrentVehicle[playerid])) == VEHICLE_GROUP_BIKE || GetVehicleModelGroup(GetVehicleModel(CurrentVehicle[playerid])) == VEHICLE_GROUP_BICYCLE))
            PutPlayerInVehicle(playerid, CurrentVehicle[playerid], 0);

        if (IsPlayerInAnyVehicle(playerid) || Player[playerid][Spectating])
            UpdatePlayerMoneyOverlay(playerid);

    	if (IsPlayerInAnyVehicle(playerid))
    	{
    		new vehicleid = GetPlayerVehicleID(playerid);
        	if (IsVehicleBodyInAnyDynamicArea(vehicleid))
        	{
                new engine, lights, alarm, door, bonnet, boot, objective;
                GetVehicleParamsEx(vehicleid, engine, lights, alarm, door, bonnet, boot, objective);
                if(engine == VEHICLE_PARAMS_ON)
                {
        			for (new areaid = 0, j = Streamer_GetUpperBound(STREAMER_TYPE_AREA); areaid <= j; areaid++)
        			{
        				if (!IsValidDynamicArea(areaid))
        					continue;

            			new ArrayData[6];
            			Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
                        if (ArrayData[1] != Player[playerid][ModeID])
                            continue;
                        if (IsVehicleBodyInDynamicArea(vehicleid, areaid) && Streamer_IsToggleItem(playerid, STREAMER_TYPE_AREA, areaid))
                        {
                            if (ArrayData[0] == AREA_TYPE_RACE_PICKUP)
                            {
                				switch (ArrayData[2])
                				{
                					case 0:
                					{
                						RepairVehicle(vehicleid);
                						PlayerPlaySound(playerid,1133, 0, 0, 0);
                					}
                					case 1:
                					{
                						AddVehicleComponent(vehicleid, 1010);
                						PlayerPlaySound(playerid, 1133, 0, 0, 0);
                					}
                					case 2:
                					{
                						if (GetVehicleModel(vehicleid) == ArrayData[4])
                							continue;
                                        new Float:curX,Float:curY,Float:curZ,Float:newX,Float:newY,Float:newZ;
                                        GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, curX, curY, curZ);
                                        GetVehicleModelInfo(ArrayData[4], VEHICLE_MODEL_INFO_SIZE, newX, newY, newZ);

                                        new Float:PosX,Float:PosY,Float:PosZ,Float:RotZ,Float:VelX,Float:VelY,Float:VelZ,Color1,Color2,Float:Health;
                                        GetVehiclePos(vehicleid, PosX, PosY, PosZ);
                                        GetVehicleZAngle(vehicleid, RotZ);
                                        GetVehicleVelocity(vehicleid, VelX, VelY, VelZ);
                                        GetVehicleColor(vehicleid, Color1, Color2);
                                        GetVehicleHealth(vehicleid, Health);

                                        curZ = curZ / 2;
                                        newZ = newZ / 2;
                                        if (curZ > newZ)
                                            PosZ = PosZ - newZ + curZ;
                                        PosZ = PosZ + 1.0;

                                        if (ArrayData[4] == 425)
                                        {
                                            PosZ = PosZ + 250.0;
                                            VelX = 0.0;
                                            VelY = 0.0;
                                            VelZ = 0.0;
                                            CallLocalFunction("OnPlayerReachHunter", "ii", playerid, Player[playerid][ModeID]);
                                        }

                                        DestroyVehicle(vehicleid);
                                        vehicleid = CreateVehicle(ArrayData[4], PosX, PosY, PosZ, RotZ, Color1, Color2, -1, IsPlayerPremium(playerid));
                                        SetVehicleHealth(vehicleid, Health);
                                        SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
                                        PutPlayerInVehicle(playerid, vehicleid, 0);
                                        SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);

                                        SetVehicleVelocity(vehicleid, VelX, VelY, VelZ);

                                        CallRemoteFunction("OnPlayerStateChange", "iii", playerid, PLAYER_STATE_DRIVER, PLAYER_STATE_ONFOOT);
                					}
                					case 3:
                					{
                						AddVehicleComponent(vehicleid, 1010);
                						RepairVehicle(vehicleid);
                						PlayerPlaySound(playerid, 1133, 0, 0, 0);
                					}
                				}
                                RequiresReset[playerid] = true;
                				Streamer_ToggleItem(playerid, STREAMER_TYPE_AREA, areaid, false);
                			}
                            else if (ArrayData[0] == AREA_TYPE_MARKER)
                            {
                                CallRemoteFunction("OnPlayerEnterMarker", "ii", playerid, areaid);
                                Streamer_ToggleItem(playerid, STREAMER_TYPE_AREA, areaid, false);
                            }
                        }
                        else if (!IsVehicleBodyInDynamicArea(vehicleid, areaid) && !Streamer_IsToggleItem(playerid, STREAMER_TYPE_AREA, areaid))
                            Streamer_ToggleItem(playerid, STREAMER_TYPE_AREA, areaid, true);
        			}
        		}
            }
            else
            {
                if (RequiresReset[playerid])
                {
                    RequiresReset[playerid] = false;
                    Streamer_ToggleAllItems(playerid, STREAMER_TYPE_AREA, true);
                }
            }
    	}
    }
	return true;
}

Hook:RACE_OVDamageStatusUpdate(vehicleid, playerid)
{
    if (Modes[Player[playerid][ModeID]][Gamemode] == GAMEMODE_RACE)
        UpdateVehicleDamageStatus(vehicleid, 0, 0, 0, 0);
    return true;
}
