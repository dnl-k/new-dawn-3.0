static 	this = -1,
		Text:Deathlist[4][3], Stage, StageWorld, StageNames[3][MAX_PLAYER_NAME], StageSkins[3], StageStuff[9];

enum E_DERBY
{
	Spawns,
	StartTick,
	TotalAlive, Alive,
	Map[256], MapID,
	NextMapID, NextMapQID, NextMapAdmin,
	RoundState,
	bool:RedoMap,

	// Main UI
	Text:MainFirst, Text:MainMap, Text:MainNextMap, Text:MainTime, Text:MainLast,
}
static ModeData[E_DERBY];

enum E_DERBY_PLAYER
{
	ORM: ORM_ID,
	Score,
	Wins,
	Runups,
    Kills,
	TimePlayed,
	MapsPlayed,

	JoinTime,

	bool:IsAlive,
	ColArea,
	LastCollisionTime,
	LastCollisionID
}
static PlayerModeData[MAX_PLAYERS][E_DERBY_PLAYER];

forward _Derby();

Hook:DD_OnGameModeExit()
{
	if (ModeData[Map][0] != EOS)
		SendRconCommandf("unloadfs ../maps/%s", ModeData[Map]);
	return true;
}

Hook:DD_initModule()
{
	this = RegisterMode("Derby", "DD", 504, 32);
	Modes[this][Gamemode] = GAMEMODE_RACE;
	Modes[this][HasQueue] = true;
	CreateMainUI(ModeData[MainFirst],ModeData[MainMap],ModeData[MainNextMap],ModeData[MainTime],ModeData[MainLast]);
	CreateDeathlist(Deathlist[3],Deathlist[2],Deathlist[1],Deathlist[0]);

	ModeData[RoundState] = 3;
	return true;
}

Hook:DD_OnPlayerRegister(playerid)
{
	new query[128];
	mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_derby (uid) VALUES (%d)", Player[playerid][ID]);
	mysql_pquery(g_Sql, query);
	return true;
}

Hook:DD_OnPlayerJoinModeHook(playerid, newmode, oldmode)
{
	if (newmode == this)
	{
		TogglePlayerSpectating(playerid, false);
		static const empty_data[E_DERBY_PLAYER];
		PlayerModeData[playerid] = empty_data;

		new ORM: ormid = PlayerModeData[playerid][ORM_ID] = orm_create("module_derby", g_Sql);

		orm_addvar_int(ormid, Player[playerid][ID], "uid");
		orm_addvar_int(ormid, PlayerModeData[playerid][Score], "intScore");
		orm_addvar_int(ormid, PlayerModeData[playerid][Wins], "intWins");
		orm_addvar_int(ormid, PlayerModeData[playerid][Runups], "intRunups");
		orm_addvar_int(ormid, PlayerModeData[playerid][TimePlayed], "intTimePlayed");
		orm_addvar_int(ormid, PlayerModeData[playerid][MapsPlayed], "intMapsPlayed");
        orm_addvar_int(ormid, PlayerModeData[playerid][Kills], "intKills");

		orm_setkey(ormid, "uid");
		orm_load(ormid, "OnPlayerModeDataLoaded", "ii", playerid, this);

		PlayerModeData[playerid][JoinTime] = gettime();

		PlayerModeData[playerid][IsAlive] = false;

		for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
		{
			if (IsValidTextDraw(i))
				TextDrawShowForPlayer(playerid, i);
		}

		for (new Text:i = MoneyTD_Health_First; i <= MoneyTD_Health_Last; i++)
		{
			if (IsValidTextDraw(i))
				TextDrawShowForPlayer(playerid, i);
		}
		PlayerTextDrawShow(playerid, MoneyTD_Health_Value[playerid]);

		switch (ModeData[RoundState])
		{
			case 0:
			{
                TogglePlayerSpectating(playerid, true);
				SetPlayerVirtualWorld(playerid, StageWorld);
				SetPlayerCameraPos(playerid, Stages[Stage][0][3], Stages[Stage][0][4], Stages[Stage][0][5]);
				SetPlayerCameraLookAt(playerid, Stages[Stage][1][3], Stages[Stage][1][4], Stages[Stage][1][5]);
			}
			case 1,2:
			{
				Player[playerid][Spectating] = false;
                SpawnPlayer(playerid);
				SetPlayerSpawn(playerid);
			}
			case 3:
			{
				Player[playerid][Spectating] = true;
				TogglePlayerSpectating(playerid, true);
			}
		}
		if(ModeData[RoundState] != 0)
		{
			if (Player[playerid][MusicType] == 1)
			{
				new URL[128];
				format(URL, sizeof(URL), ""#STREAM_URL"mapmusic/%s.mp3", ModeData[Map]);
				if (Audio_IsClientConnected(playerid))
				{
					StopAudioStreamForPlayer(playerid);
					Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
					SetPVarInt(playerid, "audio.stream", Audio_PlayStreamed(playerid, URL, false, true, false));
				}
				else
				{
					StopAudioStreamForPlayer(playerid);
					PlayAudioStreamForPlayer(playerid, URL);
				}
			}
		}
	}
	else if (oldmode == this)
	{
		PlayerModeData[playerid][TimePlayed] += gettime() - PlayerModeData[playerid][JoinTime];
		orm_save(PlayerModeData[playerid][ORM_ID]);
		orm_destroy(PlayerModeData[playerid][ORM_ID]);

		if (Player[playerid][MusicType] == 1)
		{
			StopAudioStreamForPlayer(playerid);
			Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
			DeletePVar(playerid, "audio.stream");
		}

		if (PlayerModeData[playerid][IsAlive])
			AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick], false);

		Player[playerid][Spectating] = false;

		for (new a; a < sizeof(Deathlist); a++)
			for (new b; b < sizeof(Deathlist[]); b++)
				TextDrawHideForPlayer(playerid, Deathlist[a][b]);

		for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
			if (i != Text:INVALID_TEXT_DRAW)
				TextDrawHideForPlayer(playerid, i);
	}
	return true;
}

Hook:DD_OnPlayerModeDataLoaded(playerid, gamemodeid)
{
	if (gamemodeid == this)
	{
		SetPlayerScore(playerid, PlayerModeData[playerid][Score]);
	}
	return true;
}

Hook:DD_LoadMap(gamemodeid)
{
	if (gamemodeid == this)
	{
		if (cache_num_rows())
		{
			cache_get_value_name_int(0, "uid", ModeData[MapID]);
			cache_get_value_name(0, "strFilePointer", ModeData[Map], 256);

			for (new a; a < sizeof(Deathlist); a++)
				for (new b; b < sizeof(Deathlist[]); b++)
				{
					TextDrawHideForAll(Deathlist[a][b]);
					TextDrawSetString(Deathlist[a][b], " ");
				}

			TextDrawSetString(Modes[this][AliveCountTextDraw], "~y~ALIVE~w~~n~..");

			new author[64], name[128], string[255];
			cache_get_value(0, "strMapName", name);
			cache_get_value(0, "strMapAuthor", author);
			format(string, sizeof(string), "~w~~>~ %s - %s", author, name);
			TextDrawSetString(ModeData[MainMap], string);
		}
		else ModeData[RoundState] = 3;
	}
	return true;
}

Hook:DD_CreateModeSpawnpoint(modelid,Float:X,Float:Y,Float:Z,Float:rZ,gamemodeid)
{
	if (gamemodeid == this)
		ModeData[Spawns]++;
	return true;
}

Hook:DD_InitiatePlayerSpawns(gamemodeid)
{
	if (gamemodeid == this)
	{
		RevertFade(this);

		DestroyVehicle(StageStuff[0]);
		DestroyVehicle(StageStuff[1]);
		DestroyVehicle(StageStuff[2]);
		DestroyActor(StageStuff[3]);
		DestroyActor(StageStuff[4]);
		DestroyActor(StageStuff[5]);
		DestroyDynamicObject(StageStuff[6]);
		DestroyDynamicObject(StageStuff[7]);
		DestroyDynamicObject(StageStuff[8]);

		TextDrawSetString(ModeData[MainTime], "~w~00:00");
		ModeData[RoundState] = 1;
		for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this)
				continue;
			PlayerModeData[playerid][MapsPlayed]++;
			Player[playerid][Spectating] = false;
			TogglePlayerSpectating(playerid, false);
			TogglePlayerControllable(playerid, true);
			SetPlayerSpawn(playerid);
			if (Player[playerid][MusicType] == 1)
			{
				new URL[128];
				format(URL, sizeof(URL), ""#STREAM_URL"mapmusic/%s.mp3", ModeData[Map]);
				if (Audio_IsClientConnected(playerid))
				{
					StopAudioStreamForPlayer(playerid);
					Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
					SetPVarInt(playerid, "audio.stream", Audio_PlayStreamed(playerid, URL, false, true, false));
				}
				else
				{
					StopAudioStreamForPlayer(playerid);
					PlayAudioStreamForPlayer(playerid, URL);
				}
			}
		}
	}
	return true;
}

Hook:DD_OnCountDownStateChange(gamemodeid,cdstate)
{
	if (gamemodeid == this)
	{
		switch (cdstate)
		{
			case 0:
			{
				ModeData[RoundState] = 3;
				ModeData[StartTick] = GetTickCount();
				new string[64];
				format(string, sizeof(string), "~y~ALIVE~w~~n~%d", ModeData[Alive]);
				TextDrawSetString(Modes[this][AliveCountTextDraw], string);
				for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
				{
					if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this || !PlayerModeData[playerid][IsAlive])
						continue;
					if (IsPlayerPaused(playerid))
						AddPlayerToDeathlist(playerid, 0);
				}
			}
			case 4:
			{
				ModeData[RoundState] = 2;
			}
		}
	}
	return true;
}

task Derby[500]()
{
	if (!Modes[this][Players])
		return false;
	if (ModeData[Alive] >= 2 && ModeData[RoundState] == 3)
	{
		new string[16];
		format(string, sizeof(string), "~w~%s", Tick(GetTickCount() - ModeData[StartTick], false));
		TextDrawSetString(ModeData[MainTime], string);

		for (new playerid,j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this)
				continue;
			if (!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && PlayerModeData[playerid][IsAlive])
			{
				AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
				continue;
			}
		}
	}
	else if (ModeData[Alive] < 2 && ModeData[RoundState] == 3)
	{
		Stage = random(sizeof(Stages));
		StageWorld = random(12000-2000)+2000;

        for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this)
				continue;
            if (PlayerModeData[playerid][IsAlive])
                AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
			Player[playerid][Spectating] = false;
			SetPlayerWeather(playerid, _:Stages[Stage][8][0]);
			SetPlayerTime(playerid, _:Stages[Stage][8][1], _:Stages[Stage][8][2]);
			SetPlayerVirtualWorld(playerid, StageWorld);
			SetPlayerPos(playerid, Stages[Stage][2][0], Stages[Stage][2][1], Stages[Stage][2][2] - 5.0);
			TogglePlayerControllable(playerid, false);

			InterpolateCameraPos(playerid, Stages[Stage][0][0], Stages[Stage][0][1], Stages[Stage][0][2], Stages[Stage][0][3], Stages[Stage][0][4], Stages[Stage][0][5], _:Stages[Stage][0][6], CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, Stages[Stage][1][0], Stages[Stage][1][1], Stages[Stage][1][2], Stages[Stage][1][3], Stages[Stage][1][4], Stages[Stage][1][5], _:Stages[Stage][1][6], CAMERA_MOVE);
		}

        ModeData[RoundState] = 0;
		ModeData[Spawns] = 0;
		ModeData[TotalAlive] = 0;
        ModeData[Alive] = 0;

		CreateRaceStage(415, Stage, StageWorld, StageStuff, StageSkins, StageNames[0], StageNames[1], StageNames[2]);

		StageSkins[0] = 56;
		format(StageNames[0], MAX_PLAYER_NAME, "Nobody");
		StageSkins[1] = 56;
		format(StageNames[1], MAX_PLAYER_NAME, "Nobody");
		StageSkins[2] = 56;
		format(StageNames[2], MAX_PLAYER_NAME, "Nobody");

		UnloadMap(this);

		SetTimerEx("EndRound", 8000, false, "i", this);
	}
	return true;
}

Hook:DD_EndRound(gamemodeid)
{
	if(gamemodeid == this)
	{
		if (Modes[this][Players] < 2)
		{
			for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
			{
				if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][ModeID] != this)
					continue;
				if (!IsTextDrawVisibleForPlayer(playerid, SKEW_BANNER))
					TextDrawShowForPlayer(playerid, SKEW_BANNER);
				PlayerTextDrawSetString(playerid, SKEW_BANNER_TEXT_CB[playerid], "~y~waiting for players..");
				if (!IsPlayerTextDrawVisible(playerid, SKEW_BANNER_TEXT_CB[playerid]))
					PlayerTextDrawShow(playerid, SKEW_BANNER_TEXT_CB[playerid]);
			}
			return SetTimerEx("EndRound", 1000, false, "i", this);
		}
		for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][ModeID] != this)
				continue;
			TextDrawHideForPlayer(playerid, SKEW_BANNER);
			PlayerTextDrawHide(playerid, SKEW_BANNER_TEXT_CB[playerid]);
			InterpolateCameraPos(playerid, Stages[Stage][0][3], Stages[Stage][0][4], Stages[Stage][0][5], Stages[Stage][0][0], Stages[Stage][0][1], Stages[Stage][0][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, Stages[Stage][1][3], Stages[Stage][1][4], Stages[Stage][1][5], Stages[Stage][1][0], Stages[Stage][1][1], Stages[Stage][1][2], 10000, CAMERA_MOVE);
		}
		FadeMode(this, true);

		new query[180];
		if (ModeData[Map][0] != EOS)
			SendRconCommandf("unloadfs ../maps/%s", ModeData[Map]);

		if (!ModeData[RedoMap])
		{
			if (ModeData[NextMapQID] != 0)
			{
				mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE strMode = '%e' AND uid = '%d' LIMIT 1", Modes[this][Alias], ModeData[NextMapID]);
				if(!ModeData[NextMapAdmin])
					mysql_format(g_Sql, query, sizeof(query), "%s; UPDATE module_maps SET intLastBought = '%d' WHERE uid = '%d'", query, gettime(), ModeData[NextMapID]);
				mysql_pquery(g_Sql, query, "LoadMap", "i", this);

				mysql_format(g_Sql, query, sizeof(query), "DELETE FROM module_mapqueue WHERE strMode = '%e' AND uid = '%d'", Modes[this][Alias], ModeData[NextMapQID]);
				mysql_tquery(g_Sql, query);
			}
			else
			{
				mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE strMode = '%e' AND boolEnabled = true ORDER BY rand() LIMIT 1", Modes[this][Alias]);
				mysql_pquery(g_Sql, query, "LoadMap", "i", this);
			}
			mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_mapqueue WHERE strMode = '%e' ORDER BY uid ASC LIMIT 1", Modes[this][Alias]);
			mysql_tquery(g_Sql, query, "OnQueueContinues", "i", this);
		}
		else
		{
			ModeData[RedoMap] = false;
			mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE strMode = '%e' AND uid = '%d' LIMIT 1", Modes[this][Alias], ModeData[MapID]);
			mysql_pquery(g_Sql, query, "LoadMap", "i", this);
		}
	}
	return true;
}

Hook:DD_RequestMapRedo(playerid, gamemodeid)
{
	if (gamemodeid == this)
	{
		// due to the compilers false "assignment to itself" warning
		if (ModeData[RedoMap]) ModeData[RedoMap] = false;
		else ModeData[RedoMap] = true;
		SendModeMessagef(gamemodeid, COL_LIGHTRED, "An administrator has decided that this map will %s.", (ModeData[RedoMap] == true ? ("be replayed") : ("no longer be replayed")));
	}
	return true;
}

Hook:DD_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (Player[playerid][ModeID] == this && PlayerModeData[playerid][IsAlive])
	{
		if (newkeys & 16)
			AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
	}
	return true;
}

Hook:DD_OnPlayerDeath(playerid, killerid, reason)
{
	if (Player[playerid][ModeID] == this && PlayerModeData[playerid][IsAlive])
		AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
	return true;
}

static AddPlayerToDeathlist(playerid, tick, bool:spectate = true)
{
	new string[64];
	for (new a = sizeof(Deathlist) - 1; a > 0; a--)
		for (new b; b < sizeof(Deathlist[]); b++)
		{
			TextDrawGetString(Deathlist[a-1][b], string);
			if (strcmp(string, " "))
				TextDrawSetString(Deathlist[a][b], string);
		}
	if (ModeData[Alive] <= 3)
	{
		if (ModeData[Alive] == 1) PlayerModeData[playerid][Wins]++;
		else if (ModeData[Alive] == 2) PlayerModeData[playerid][Runups]++;

		GetPlayerName(playerid, StageNames[ModeData[Alive] - 1], MAX_PLAYER_NAME);
		StageSkins[ModeData[Alive] - 1] = GetPlayerSkin(playerid);
	}

	format(string, sizeof(string), "%d%s", ModeData[Alive], Ordinal(ModeData[Alive]));
	TextDrawSetString(Deathlist[0][0], string);

	format(string, sizeof(string), "~w~%s", Player[playerid][Name]);
	TextDrawSetString(Deathlist[0][1], string);

	if (ModeData[RoundState] == 3)
	{
		format(string, sizeof(string), "~w~%s", Tick(tick));
		TextDrawSetString(Deathlist[0][2], string);
	}
	else
		TextDrawSetString(Deathlist[0][2], "~w~00:00.000");

	for (new p, j = GetPlayerPoolSize(); p <= j; p++)
	{
		if (!IsPlayerConnected(p) || Player[p][ModeID] != this)
			continue;
		for (new aa; aa < sizeof(Deathlist); aa++)
			for (new bb; bb < sizeof(Deathlist[]); bb++)
			{
				TextDrawGetString(Deathlist[aa][bb], string);
				if (strcmp(string, " "))
				{
					if (!bb)
					{
						if (!strcmp(string, "1st"))
							TextDrawColor(Deathlist[aa][bb], -913764097);
						else if (!strcmp(string, "2nd"))
							TextDrawColor(Deathlist[aa][bb], -1465341697);
						else if (!strcmp(string, "3rd"))
							TextDrawColor(Deathlist[aa][bb], -1772472065);
						else
							TextDrawColor(Deathlist[aa][bb], -859651329);
					}
					TextDrawShowForPlayer(p, Deathlist[aa][bb]);
				}
			}
	}

	if (ModeData[Alive] > 1)
	{
		if (GetTickCount() - PlayerModeData[playerid][LastCollisionTime] < 15000 && IsPlayerConnected(PlayerModeData[playerid][LastCollisionID]) && Player[PlayerModeData[playerid][LastCollisionID]][ModeID] == this)
		{
			PlayerModeData[PlayerModeData[playerid][LastCollisionID]][Kills]++;
			SendClientMessagef(PlayerModeData[playerid][LastCollisionID], -1, "You have killed %s", Player[playerid][Name]);
			SendClientMessagef(playerid, -1, "You were killed by %s", Player[PlayerModeData[playerid][LastCollisionID]][Name]);
		}
	}

	PlayerModeData[playerid][Score] += (ModeData[TotalAlive] - ModeData[Alive]) * 2;
	Player[playerid][Money] += ((ModeData[TotalAlive] - ModeData[Alive]) * 2) * 5;

	SetPlayerScore(playerid, PlayerModeData[playerid][Score]);
	UpdatePlayerMoneyOverlay(playerid);

	ModeData[Alive]--;
	PlayerModeData[playerid][IsAlive] = false;

	format(string, sizeof(string), "~y~ALIVE~w~~n~%d", ModeData[Alive]);
	TextDrawSetString(Modes[this][AliveCountTextDraw], string);

	if (IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		RemovePlayerFromVehicle(playerid);
		DestroyVehicle(vehicleid);
	}

	if (spectate)
	{
		SetCameraBehindPlayer(playerid);
		Player[playerid][Spectating] = true;
		TogglePlayerSpectating(playerid, true);
	}
	return true;
}

static SetPlayerSpawn(playerid)
{
	new rnd = random(ModeData[Spawns] + 1),
		c;
	if (rnd)
		rnd--;
	for (new areaid, k = Streamer_GetUpperBound(STREAMER_TYPE_AREA); areaid <= k; areaid++)
	{
		if (!IsValidDynamicArea(areaid) || Streamer_GetIntData(STREAMER_TYPE_AREA,areaid,E_STREAMER_TYPE) != STREAMER_AREA_TYPE_SPHERE)
			continue;
		new ArrayData[5];
		Streamer_GetArrayData(STREAMER_TYPE_AREA,areaid,E_STREAMER_EXTRA_ID,ArrayData);
		if (ArrayData[0] != AREA_TYPE_SPAWNPOINT || ArrayData[1] != this)
			continue;
		if (c == rnd)
		{
			new Float:X,Float:Y,Float:Z,Float:rZ = Float:ArrayData[3];
			Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_X, X);
			Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Y, Y);
			Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Z, Z);
			new vehicleid = CreateVehicle(ArrayData[2], X, Y, Z, rZ, Player[playerid][CarColor1], Player[playerid][CarColor2], -1, IsPlayerPremium(playerid));
			SetPlayerVirtualWorld(playerid,VirtualWorlds[this][1]);
			SetVehicleVirtualWorld(vehicleid,VirtualWorlds[this][1]);
			PutPlayerInVehicle(playerid, vehicleid, 0);
			SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
			break;
		}
		c++;
	}
	ModeData[Alive]++;
	ModeData[TotalAlive]++;
	PlayerModeData[playerid][IsAlive] = true;
}

Hook:DD_OnPlayerSetNextmap(playerid, rowcount, mapname[], mapauthor[], mapid, bool:adminset)
{
	if (Player[playerid][ModeID] == this)
	{
		cache_set_result(0);
		if (!rowcount || adminset)
		{
			new string[64 + 128];
			ModeData[NextMapQID] = cache_insert_id();
			ModeData[NextMapID] = mapid;
			format(string, sizeof(string), "~y~Next ~w~%s - %s", mapauthor, mapname);
			TextDrawSetString(ModeData[MainNextMap], string);
		}
		new string[256];
		if (!adminset)
			format(string, sizeof(string), "%s {FFFFFF}added "#EMB_COL_LIGHTBLUE_PURPLE"%s - %s{FFFFFF} to the map queue (%d/3).", Player[playerid][Name], mapauthor, mapname, rowcount + 1);
		else
			format(string, sizeof(string), ""#EMB_COL_LIGHTRED"An administrator has forced '%s - %s' as the next map.", mapauthor, mapname);
		SendModeMessage(this, GetPlayerColor(playerid), string);
	}
}

Hook:DD_OnQueueContinues(gamemodeid)
{
	if (gamemodeid == this)
	{
		new rows = cache_num_rows();
		if (rows)
		{
			new mapauthor[64], mapname[128], string[64 + 128];
			cache_get_value_name(0, "strMapAuthor", mapauthor);
			cache_get_value_name(0, "strMapName", mapname);
			cache_get_value_name_int(0, "uid", ModeData[NextMapQID]);
			cache_get_value_name_int(0, "intMapID", ModeData[NextMapID]);
			cache_get_value_name_int(0, "intAdminSet", ModeData[NextMapAdmin]);
			format(string, sizeof(string), "~y~Next ~w~%s - %s", mapauthor, mapname);
			TextDrawSetString(ModeData[MainNextMap], string);
		}
		else
		{
			ModeData[NextMapQID] = 0;
			TextDrawSetString(ModeData[MainNextMap], "~y~Next ~w~Random");
		}
	}
}

Hook:DD_OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (IsValidDynamicArea(PlayerModeData[playerid][ColArea]))
    {
		DestroyDynamicArea(PlayerModeData[playerid][ColArea]);
		PlayerModeData[playerid][ColArea] = -1;
    }
    if (Player[playerid][ModeID] == this)
    {
        if (newstate == PLAYER_STATE_DRIVER)
        {
            new Float:sX,Float:sY,Float:sZ,ArrayData[2];
            ArrayData[0] = AREA_TYPE_HITBOX;
            ArrayData[1] = playerid;

            GetVehicleModelInfo(GetVehicleModel(GetPlayerVehicleID(playerid)), VEHICLE_MODEL_INFO_SIZE, sX, sY, sZ);

			PlayerModeData[playerid][ColArea] = CreateDynamicCuboid(- (sX / 2), - (sY / 2), - (sZ / 2), (sX / 2), (sY / 2), (sZ / 2));
			AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea], GetPlayerVehicleID(playerid), 0.0, 0.0, 0.0);
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea], E_STREAMER_EXTRA_ID, ArrayData);

            /*PlayerModeData[playerid][ColArea][0] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // Front Right
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][0], GetPlayerVehicleID(playerid), sX / 2, sY / 2);
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][0], E_STREAMER_EXTRA_ID, ArrayData);

            PlayerModeData[playerid][ColArea][1] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // 2 / 4
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][1], GetPlayerVehicleID(playerid), 0.0, sY / 2 - (sY / 4));
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][1], E_STREAMER_EXTRA_ID, ArrayData);

            PlayerModeData[playerid][ColArea][2] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // 3 / 4
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][2], GetPlayerVehicleID(playerid), 0.0, -sY / 2 + (sY / 4));
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][2], E_STREAMER_EXTRA_ID, ArrayData);

            PlayerModeData[playerid][ColArea][3] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // Rear Right
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][3], GetPlayerVehicleID(playerid), sX / 2, -sY / 2);
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][3], E_STREAMER_EXTRA_ID, ArrayData);

			PlayerModeData[playerid][ColArea][4] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // Front Left
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][4], GetPlayerVehicleID(playerid), -sX / 2, sY / 2);
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][4], E_STREAMER_EXTRA_ID, ArrayData);

			PlayerModeData[playerid][ColArea][5] = CreateDynamicSphere(0.0, 0.0, 0.0, (sX / 2) + 0.8); // Rear Left
            AttachDynamicAreaToVehicle(PlayerModeData[playerid][ColArea][5], GetPlayerVehicleID(playerid), -sX / 2, -sY / 2);
            Streamer_SetArrayData(STREAMER_TYPE_AREA, PlayerModeData[playerid][ColArea][5], E_STREAMER_EXTRA_ID, ArrayData);*/

        }
    }
    return true;
}

Hook:DD_OnPlayerUpdate(playerid)
{
    if (Player[playerid][ModeID] == this && PlayerModeData[playerid][IsAlive] && IsPlayerInAnyVehicle(playerid) && GetTickCount() - PlayerModeData[playerid][LastCollisionTime] >= 1000)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if (IsVehicleBodyInAnyDynamicArea(vehicleid))
        {
            new countAreas = Streamer_GetUpperBound(STREAMER_TYPE_AREA);
    		for (new areaid = 0; areaid <= countAreas; areaid++)
    		{
    			if (!IsValidDynamicArea(areaid))
    				continue;
				if (Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_TYPE) != STREAMER_AREA_TYPE_CUBOID)
					continue;
                if (areaid == PlayerModeData[playerid][ColArea])
                    continue;
                new ArrayData[2];
                Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
                if (ArrayData[0] != AREA_TYPE_HITBOX)
                    continue;
                new otherplayerid = ArrayData[1];
                if (!IsPlayerConnected(otherplayerid))
                    break;
                if (Player[otherplayerid][ModeID] == this && PlayerModeData[otherplayerid][IsAlive] && IsPlayerInAnyVehicle(otherplayerid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(otherplayerid))
                {
        			if (IsVehicleBodyInDynamicArea(vehicleid,areaid))
        			{
                        PlayerModeData[playerid][LastCollisionTime] = GetTickCount();
						PlayerModeData[playerid][LastCollisionID] = otherplayerid;
						PlayerModeData[otherplayerid][LastCollisionTime] = GetTickCount();
						PlayerModeData[otherplayerid][LastCollisionID] = playerid;
        				new string[128];
                        format(string, sizeof(string), "[id:%d vehicle:%d] collided with [id:%d vehicle:%d]", playerid, vehicleid, otherplayerid, GetPlayerVehicleID(otherplayerid));
                        SendClientMessageToAll(COL_LIGHTRED, string);
                        break;
        			}
                }
    		}
        }
    }
    return true;
}
