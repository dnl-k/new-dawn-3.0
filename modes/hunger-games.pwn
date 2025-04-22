static this = -1;

enum E_HUNGERGAMES
{
	Spawns,
	StartTick,
	TotalAlive, Alive,
	Map[256], MapID,
	NextMapID, NextMapQID, NextMapAdmin,
	RoundState,

    // Main UI
	Text:MainFirst, Text:MainMap, Text:MainNextMap, Text:MainTime, Text:MainLast,
}
static ModeData[E_HUNGERGAMES];

enum E_HUNGERGAMES_PLAYER
{
	ORM: ORM_ID,
	Score,
	Wins,
    Kills,
    Deaths,
	TimePlayed,
	MapsPlayed,

	JoinTime,

	bool:IsAlive
}
static PlayerModeData[MAX_PLAYERS][E_HUNGERGAMES_PLAYER];

Hook:HG_OnGameModeExit()
{
	if (ModeData[Map][0] != EOS)
		SendRconCommandf("unloadfs ../maps/%s", ModeData[Map]);
	return true;
}

Hook:HG_initModule()
{
    this = RegisterMode("Hunger Games", "HG", 2768, 64);
    Modes[this][HasQueue] = true;

    CreateMainUI(ModeData[MainFirst],ModeData[MainMap],ModeData[MainNextMap],ModeData[MainTime],ModeData[MainLast]);

    ModeData[RoundState] = 3;

    SetTimer("_HungerGames", 500, true);
    return true;
}

Hook:HG_OnPlayerRegister(playerid)
{
	new query[128];
	mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_hunger_games (uid) VALUES (%d)", Player[playerid][ID]);
	mysql_pquery(g_Sql, query);
	return true;
}

Hook:HG_OnPlayerJoinModeHook(playerid, newmode, oldmode)
{
    if (newmode == this)
    {
        TogglePlayerSpectating(playerid, false);
		static const empty_data[E_HUNGERGAMES_PLAYER];
		PlayerModeData[playerid] = empty_data;

		new ORM: ormid = PlayerModeData[playerid][ORM_ID] = orm_create("module_hunger_games", g_Sql);

		orm_addvar_int(ormid, Player[playerid][ID], "uid");
		orm_addvar_int(ormid, PlayerModeData[playerid][Score], "intScore");
		orm_addvar_int(ormid, PlayerModeData[playerid][Wins], "intWins");
		orm_addvar_int(ormid, PlayerModeData[playerid][TimePlayed], "intTimePlayed");
		orm_addvar_int(ormid, PlayerModeData[playerid][MapsPlayed], "intMapsPlayed");
        orm_addvar_int(ormid, PlayerModeData[playerid][Kills], "intKills");
        orm_addvar_int(ormid, PlayerModeData[playerid][Deaths], "intDeaths");

		orm_setkey(ormid, "uid");
		orm_load(ormid, "OnPlayerModeDataLoaded", "ii", playerid, this);

		PlayerModeData[playerid][JoinTime] = gettime();

		PlayerModeData[playerid][IsAlive] = false;
    }
    else if (oldmode == this)
    {
        PlayerModeData[playerid][TimePlayed] += gettime() - PlayerModeData[playerid][JoinTime];
		orm_save(PlayerModeData[playerid][ORM_ID]);
		orm_destroy(PlayerModeData[playerid][ORM_ID]);

        Player[playerid][Spectating] = false;
    }
    return true;
}

Hook:HG_OnPlayerModeDataLoaded(playerid, gamemodeid)
{
	if (gamemodeid == this)
	{
		SetPlayerScore(playerid, PlayerModeData[playerid][Score]);
	}
	return true;
}

Hook:HG_LoadMap(gamemodeid)
{
	if (gamemodeid == this)
	{
		if (cache_num_rows())
		{
			cache_get_value_name_int(0, "uid", ModeData[MapID]);
			cache_get_value_name(0, "strFilePointer", ModeData[Map], 256);

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

Hook:HG_CreateSpawnForGameMode(modelid,Float:X,Float:Y,Float:Z,Float:rZ,gamemodeid)
{
	if (gamemodeid == this)
		ModeData[Spawns]++;
	return true;
}
