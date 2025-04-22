#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 128

#if !defined KEY_AIM
	#define KEY_AIM (128)
#endif

#include <YSI\YSI\y_hooks>
#include <audio>
#include <YSI\YSI\y_timers>
#include <a_mysql>
#include <a_json>
#include <discord-connector>
#include <hash>
#include <Pawn.CMD>
#include <sscanf2>
#include <socket>
#include <streamer>
#include <YSF>
#include <regex>
#include <profiler>

#define API "new-dawn.ml/api/"

new MySQL:g_Sql,
	DCC_Channel:g_Echo,
	DCC_Channel:g_Moderation;

enum E_PLAYER
{
	ORM: ORM_ID,
	ID,
	Password[SHA512_LENGTH + 1],
	Name[MAX_PLAYER_NAME],
	Premium,
	AdminLevel,
	VW,
	Money,
	Skin,
	ClanID,
	ClanRank,
	Muted,

	ModeID,
	MusicType,
	bool:GlobalChat,
	bool:PM,
	CarColor1,
	CarColor2,

	bool:Spectating,
	SpectateID,

	bool:IsLoggedIn,
	LoginAttempts,
}

new Player[MAX_PLAYERS][E_PLAYER],
	Ranks[6][20] = {"Player", "Trial Moderator", "Moderator", "Senior Moderator", "Lead Moderator", "Administrator"};

static MySQLSafetyCheck[MAX_PLAYERS];

#include "..\gamemodes\core\constants.pwn"
#include "..\gamemodes\core\configurations.pwn"

#include "..\gamemodes\core\assets\ip-lookup.pwn"
#include "..\gamemodes\core\assets\fixes.pwn"
#include "..\gamemodes\core\assets\stages.pwn"
#include "..\gamemodes\core\assets\ferriswheel.pwn"
#include "..\gamemodes\core\assets\textdraws.pwn"

#include "..\gamemodes\core\functions.pwn"
#include "..\gamemodes\core\anticheat.pwn"

DEFINE_HOOK_REPLACEMENT(OnPlayer, OP);
DEFINE_HOOK_REPLACEMENT(OnVehicle, OV);

// Modularity
enum E_MODES
{
	Name[MAX_MODE_NAME],
	Alias[MAX_MODE_NAME],
	Players,
	PlayerLimit,
	Text:ClickTextDraw,
	Text:PlayerCountTextDraw,
	Text:AliveCountTextDraw,
	bool:HasQueue,
	bool:Locked,

	Weather,
	TimeH,
	TimeM,

	Gamemode
};

new Modes[MAX_MODES][E_MODES],
	mCount,
	lastRowPosition,
	lastColPosition;
forward OnSQLConnection();
forward initModule();
forward OnPlayerJoinMode(playerid, newmode, oldmode);
forward OnPlayerJoinModeHook(playerid, newmode, oldmode);
forward OnPlayerModeDataLoaded(playerid, gamemodeid);
forward OnPlayerNextmapRequest(playerid, bool:adminset);
forward OnPlayerSetNextmap(playerid, rowcount, mapname[], mapauthor[], mapid, bool:adminset);
forward OnQueueContinues(gamemodeid);

forward OnPlayerRequestHuntertime(playerid, tick);
forward OnPlayerSetHuntertime(playerid, tick);

enum(<<=1)
{
	CMD_TRIAL_MODERATOR = 1,
	CMD_MODERATOR,
	CMD_SENIOR_MODERATOR,
	CMD_LEAD_MODERATOR,
	CMD_ADMINISTRATOR,

	HAS_TARGET,
	SPAM_PENALTY_EXCEPTION
};

enum
{
	DIALOG_NO_RESPONSE,
	DIALOG_REGISTER,
	DIALOG_REGISTER_MAIL,
	DIALOG_LOGIN,
	DIALOG_MAP_SEARCH_RESULTS,
	DIALOG_ADMIN_MAP_SEARCH_RESULTS,
	DIALOG_CHANGEPASSWORD_OLD,
	DIALOG_CHANGEPASSWORD_NEW
}

#include "..\gamemodes\core\assets\fade.pwn"

#include "..\gamemodes\gamemodes\main.pwn"
#include "..\gamemodes\gamemodes\race.pwn"
#include "..\gamemodes\gamemodes\play.pwn"

#include "..\gamemodes\features\clans.pwn"
#include "..\gamemodes\features\customizations.pwn"
#include "..\gamemodes\features\music-player.pwn"

#include "..\gamemodes\modes\derby.pwn"
#include "..\gamemodes\modes\deathmatch.pwn"
#include "..\gamemodes\modes\easy-deathmatch.pwn"
#include "..\gamemodes\modes\hunger-games.pwn"
#include "..\gamemodes\modes\clanwar.pwn"
//#include "..\gamemodes\modes\freeroam.pwn"

#include "..\gamemodes\core\commands.pwn"

main()
{
	print(" *** Waiting for Database connection...");

	new MySQLOpt:options = mysql_init_options();
	mysql_set_option(options, AUTO_RECONNECT, true);
	mysql_set_option(options, POOL_SIZE, 8);
	mysql_set_option(options, MULTI_STATEMENTS, true);
	g_Sql = mysql_connect(CONF_MYSQL_HOST, CONF_MYSQL_USER, CONF_MYSQL_PASS, CONF_MYSQL_DATA, options);
	if (mysql_errno())
	{
		printf(" *** Error %d", mysql_errno());

		new rndString[16];
		for (new i = 0; i < 16; i++) rndString[i] = random(94) + 33;
		SendRconCommandf("password %s", rndString);
		SendRconCommand("hostname ND: Database Error! Please contact an administrator!");
	}
	else
	{
		print(" *** Database connection established!");
		CallLocalFunction("OnSQLConnection", "");
	}
}

public OnGameModeInit()
{
	for (new modeid; modeid < MAX_MODES; modeid++)
	{
		Modes[modeid][ClickTextDraw] = Text:INVALID_TEXT_DRAW;
		Modes[modeid][PlayerCountTextDraw] = Text:INVALID_TEXT_DRAW;
		Modes[modeid][AliveCountTextDraw] = Text:INVALID_TEXT_DRAW;
	}

	SetGameModeText("New Dawn 3.0");

	#if defined SERVER_DEV
		#define DEV_VERSION DEVVERSION
		#define DEV_BRANCH DEVBRANCH

		SetGameModeText("3.0_" #DEV_VERSION);
		SendRconCommand("hostname ND3 Test Server | Branch: " #DEV_BRANCH);
	#endif

	SetObjectsDefaultCameraCol(true);
	EnableStuntBonusForAll(false);
    DisableInteriorEnterExits();
	UsePlayerPedAnims();
    ManualVehicleEngineAndLights();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);

    AllowNickNameCharacter('#',true);
    AllowNickNameCharacter('<',true);
    AllowNickNameCharacter('>',true);
    AllowNickNameCharacter('!',true);

	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	DCC_Connect("MzA3NTQxOTEwMjc1MzU4NzMw.C-UKRQ.55IW9cUwS_Wv1XrnpxwgHOGvNo4");
	g_Echo = DCC_FindChannelByName("newdawn");
	g_Moderation = DCC_FindChannelByName("moderation");

	RegisterMode("Connecting", "Connecting");
	RegisterMode("Lobby", "Lobby");
	CallLocalFunction("initModule", "");
	return true;
}

public OnGameModeExit()
{
	for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
	{
		if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn])
			continue;
		CallLocalFunction("OnPlayerDisconnect", "ii", playerid, 1);
	}
	mysql_tquery(g_Sql, "UPDATE core_playerinfo SET boolIsOnline = '0'");
    mysql_close(g_Sql);
	return true;
}

public OnPlayerConnect(playerid)
{
	Streamer_ToggleIdleUpdate(playerid, true);
	SendClientBlankLines(playerid, 30);
	MySQLSafetyCheck[playerid]++;

	RemoveBuildingForPlayer(playerid, 6298, 389.77334594727, -2028.4699707031, 22.0, 200);
	RemoveBuildingForPlayer(playerid, 6461, 389.77334594727, -2028.4699707031, 22.0, 200);
	RemoveBuildingForPlayer(playerid, 3752, 389.77334594727, -2028.4699707031, 22.0, 200);
	RemoveBuildingForPlayer(playerid, 3751, 389.77334594727, -2028.4699707031, 22.0, 200);

	static const empty_player[E_PLAYER];
	Player[playerid] = empty_player;

	GetPlayerName(playerid, Player[playerid][Name], MAX_PLAYER_NAME);

	#if !defined SERVER_DEV
	new string[128], IP[16];
	GetPlayerIp(playerid, IP, sizeof(IP));

	format(string, sizeof(string), "server.new-dawn.io/proxycheck.php?ip=%s&name=%s", IP, urlencode(Player[playerid][Name]));
	HTTP(playerid, HTTP_GET, string, "", "OnPlayerIPAddressChecked");
	#endif
	return true;
}

forward OnPlayerIPAddressChecked(index, response_code, data[]);
public OnPlayerIPAddressChecked(index, response_code, data[])
{
	new IP[16];
	GetPlayerIp(index, IP, sizeof(IP));

	if (response_code == 200)
	{
		new JSONNode:node = json_parse_string(data),
			proxy[4];

		if (strfind(data, "error") == -1)
		{
			json_get_string(node, proxy, sizeof(proxy), "proxy");

			if (!strcmp(proxy, "yes"))
			{
				SendAdminMessagef(COL_PUNISHMENT, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) has been kicked for potentially using a VPN / Proxy (%s)", Player[index][Name], index, IP);
				SendClientMessage(index, COL_PUNISHMENT, "You have been kicked for potentially using a VPN / Proxy !");
				SendClientMessage(index, COL_PUNISHMENT, "Please contact an administrator if you think that this is a false positive.");
				BlockIpAddress(IP, 60 * 10000);
				Kick(index);
				return true;
			}
		}
	}
	else if (response_code == 400)
	{
		printf("[ IP CHECK ] Unknown error IP %s ; Player %d ; Response %s", IP, index, data);
	}
	else if (response_code == 429)
	{
		SendAdminMessagef(COL_PUNISHMENT, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) IP Check failed with response code #%d (%s).", Player[index][Name], index, response_code, IP);
	}
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (Player[playerid][IsLoggedIn])
		Kick(playerid);
	else
	{
    	TogglePlayerSpectating(playerid, true);
    	SetTimerEx("OnPlayerFullyConnected", 100, false, "i", playerid);
	}
	return true;
}

forward OnPlayerFullyConnected(playerid);
public OnPlayerFullyConnected(playerid)
{
	SetPlayerTime(playerid, 21, 30);
	SetPlayerWeather(playerid, 5);
	SetPlayerPos(playerid, 1093.000000,-2036.000000,90.000000);
	SetPlayerCameraPos(playerid, 1093.000000, -2036.000000, 90.000000);
	SetPlayerCameraLookAt(playerid, 487.5, -1629.3000488281, 30.200000762939);

	new ORM: ormid = Player[playerid][ORM_ID] = orm_create("core_playerinfo", g_Sql);

	orm_addvar_int(ormid, Player[playerid][ID], "uid");
	orm_addvar_string(ormid, Player[playerid][Name], MAX_PLAYER_NAME, "strPlayerName");
	orm_addvar_string(ormid, Player[playerid][Password], SHA512_LENGTH + 1, "strPassword");
	orm_addvar_int(ormid, Player[playerid][Premium], "utPremium");
	orm_addvar_int(ormid, Player[playerid][AdminLevel], "intAdminLevel");
	orm_addvar_int(ormid, Player[playerid][VW], "intVirtualWorld");
	orm_addvar_int(ormid, Player[playerid][Money], "intMoney");
	orm_addvar_int(ormid, Player[playerid][Skin], "intSkin");
	orm_addvar_int(ormid, Player[playerid][ClanID], "intClanID");
	orm_addvar_int(ormid, Player[playerid][ClanRank], "intClanRank");
	orm_addvar_int(ormid, Player[playerid][Muted], "intMuted");
	orm_addvar_int(ormid, Player[playerid][MusicType], "intMusicType");
	orm_addvar_int(ormid, Player[playerid][GlobalChat], "boolGlobalChat");
	orm_addvar_int(ormid, Player[playerid][PM], "boolPM");
	orm_addvar_int(ormid, Player[playerid][CarColor1], "intCarColor1");
	orm_addvar_int(ormid, Player[playerid][CarColor2], "intCarColor2");
	orm_setkey(ormid, "strPlayerName");

	orm_load(ormid, "OnPlayerDataLoaded", "ii", playerid, MySQLSafetyCheck[playerid]);
    return true;
}

public OnPlayerDisconnect(playerid, reason)
{
	MySQLSafetyCheck[playerid]++;
	if (Player[playerid][IsLoggedIn])
	{
		OnPlayerJoinMode(playerid, 0, Player[playerid][ModeID]);
		orm_save(Player[playerid][ORM_ID]);
		orm_destroy(Player[playerid][ORM_ID]);

		CallLocalFunction("MUSIC_OnPlayerDisconnect", "dd", playerid, reason);

		Player[playerid][IsLoggedIn] = false;

		new dcc[128];
		format(dcc, sizeof(dcc), "`#LEAVE`  %s (ID %d) has left the server.", Player[playerid][Name], playerid);
		DCC_SendChannelMessage(g_Echo, dcc);
		mysql_format(g_Sql, dcc, sizeof(dcc),"UPDATE core_playerinfo SET boolIsOnline = '0' WHERE uid = '%d'", Player[playerid][ID]);
		mysql_pquery(g_Sql, dcc);
		switch (reason)
		{
			case 0: Log("NETWORK", playerid, -1, "disconnect", "timed out");
			case 1: Log("NETWORK", playerid, -1, "disconnect", "leaving");
			case 2:	Log("NETWORK", playerid, -1, "disconnect", "kick/ban");
		}
	}
	return true;
}

forward OnPlayerDataLoaded(playerid, check);
public OnPlayerDataLoaded(playerid, check)
{
	if (check != MySQLSafetyCheck[playerid]) return Kick(playerid);

	orm_setkey(Player[playerid][ORM_ID], "uid");

	new query[512], Serial[40 + 1], Country[MAX_COUNTRY_NAME], IP[16];
	GetPlayerCountry(playerid, Country, sizeof(Country));
	gpci(playerid, Serial, sizeof(Serial));
	GetPlayerIp(playerid, IP, sizeof(IP));
	strmid(IP, IP, 0, strfind(IP, ".", true, strfind(IP, ".", true) + 1));

	switch (orm_errno(Player[playerid][ORM_ID]))
	{
		case ERROR_OK:
		{
			new string[128];
			format(string, sizeof(string), ""#EMB_COL_SAMP_MSG"Welcome back, %s.\n\nPlease login by entering your password in the field below:", Player[playerid][Name]);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "New Dawn >> Login", string, "Login", "Quit");
		}

		case ERROR_NO_DATA:
		{
			new string[256];
			format(string, sizeof(string), ""#EMB_COL_SAMP_MSG"Welcome to "#EMB_COL_LIGHTBLUE_PURPLE"New Dawn"#EMB_COL_SAMP_MSG", %s.\n\nThis username is not registered to an account. \nPlease choose a password to continue:", Player[playerid][Name]);
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "New Dawn >> Registration", string, "Register", "Quit");
		}
	}

	mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM core_bans WHERE boolEnabled = '1' AND (utExpires > '%d' OR utExpires = '-1')", gettime());
	mysql_pquery(g_Sql, query, "OnPlayerBanCheck", "i", playerid);
	return true;
}

forward OnPlayerBanCheck(playerid);
public OnPlayerBanCheck(playerid)
{
	new rows = cache_num_rows(), pSerial[40 + 1], pIP[16], pISP[MAX_COUNTRY_NAME], pCountry[MAX_COUNTRY_NAME], IPBlocks[8],
		type[8], value[40 + 1], reason[32], admin[MAX_PLAYER_NAME], expires, serial[40 + 1], ip[16], isp[MAX_COUNTRY_NAME], country[MAX_COUNTRY_NAME], pIPBlocks[8];

	gpci(playerid, pSerial, sizeof(pSerial));
	GetPlayerIp(playerid, pIP, sizeof(pIP));
	strmid(pIPBlocks, pIP, 0, strfind(pIP, ".", true, strfind(pIP, ".", true) + 1));
	strins(pIPBlocks, ".", strlen(pIPBlocks));
	GetPlayerISP(playerid, pISP, sizeof(pISP));
	GetPlayerCountry(playerid, pCountry, sizeof(pCountry));
	for (new rowid; rowid < rows; rowid++)
	{
		cache_get_value_name_int(rowid, "utExpires", expires);
		if (expires < gettime() && expires != -1)
			continue;

		cache_get_value_name(rowid, "strType", type);
		cache_get_value_name(rowid, "strValue", value);
		cache_get_value_name(rowid, "strReason", reason);
		cache_get_value_name(rowid, "strAdmin", admin);
		cache_get_value_name_int(rowid, "utExpires", expires);
		cache_get_value_name(rowid, "strSerial", serial);
		cache_get_value_name(rowid, "strIP", ip);
		strmid(IPBlocks, ip, 0, strfind(ip, ".", true, strfind(ip, ".", true) + 1));
		strins(IPBlocks, ".", strlen(IPBlocks));
		cache_get_value_name(rowid, "strISP", isp);
		cache_get_value_name(rowid, "strCountry", country);

		if (!strcmp(type, "uid", true))
		{
			new value_int = strval(value);
			if (value_int == Player[playerid][ID] || !strcmp(pIP, ip, true) || !strcmp(pIPBlocks, IPBlocks, true))
			{
				new bannedUser[MAX_PLAYER_NAME];
				cache_get_value_name(rowid, "strPlayerName", bannedUser);
				ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "1", "1", "1", "1");
				SendClientMessagef(playerid, COL_PUNISHMENT, "This account (%s) has been %s banned by %s for '%s'.", bannedUser, (expires == -1 ? ("permanently") : "temporarily"), admin, reason);
				if (expires != 1)
				{
					new difference = expires - gettime();

					new days = floatround(difference / 86400);
					difference = difference % 86400;
					new hours = floatround(difference / 3600);
					difference = difference % 3600;
					new minutes = floatround(difference / 60);
					difference = difference % 60;
					SendClientMessagef(playerid, COL_PUNISHMENT, "The ban expires in %dd %dh %dm %ds.", days, hours, minutes, difference);
				}
				Kick(playerid);
				break;
			}
			else
			{
				if (!strcmp(pSerial, serial, true) && !strcmp(pCountry, country, true))
				{
					new dcc[128], bannedUser[MAX_PLAYER_NAME];
					cache_get_value_name(rowid, "strPlayerName", bannedUser);
					format(dcc, sizeof(dcc), "`#WARNING`  %s (ID %d) is suspected for ban evasion (Serial & Country Match > %s (uid %d))", Player[playerid][Name], playerid, bannedUser, value_int);
					DCC_SendChannelMessage(g_Moderation, dcc);
					SendAdminMessagef(COL_PUNISHMENT, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) is suspected for ban evasion ("#EMB_COL_GREEN"Serial & Country Match > %s (uid %d"#EMB_COL_PUNISHMENT").", Player[playerid][Name], playerid, bannedUser, value_int);
					break;
				}
				else if (strcmp(pSerial, serial, true) && !strcmp(pCountry, country, true))
				{
					if (!strcmp(pIPBlocks, IPBlocks, true))
					{
						new dcc[128], bannedUser[MAX_PLAYER_NAME];
						cache_get_value_name(rowid, "strPlayerName", bannedUser);
						format(dcc, sizeof(dcc), "`#WARNING`  %s (ID %d) is suspected for ban evasion (IP Range Match > %s (uid %d))", Player[playerid][Name], playerid, bannedUser, value_int);
						DCC_SendChannelMessage(g_Moderation, dcc);
						SendAdminMessagef(COL_PUNISHMENT, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) is suspected for ban evasion ("#EMB_COL_GREEN"IP Range Match > %s (uid %d"#EMB_COL_PUNISHMENT").", Player[playerid][Name], playerid, bannedUser, value_int);
						break;
					}
					else if (!strcmp(pISP, isp, true))
					{
						new dcc[128], bannedUser[MAX_PLAYER_NAME];
						cache_get_value_name(rowid, "strPlayerName", bannedUser);
						format(dcc, sizeof(dcc), "`#WARNING`  %s (ID %d) is suspected for ban evasion (ISP Match > %s (uid %d))", Player[playerid][Name], playerid, bannedUser, value_int);
						DCC_SendChannelMessage(g_Moderation, dcc);
						SendAdminMessagef(COL_PUNISHMENT, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) is suspected for ban evasion ("#EMB_COL_GREEN"ISP Match > %s (uid %d"#EMB_COL_PUNISHMENT").", Player[playerid][Name], playerid, bannedUser, value_int);
						break;
					}
				}
			}
		}
		else if (!strcmp(type, "serial", true) && !strcmp(pSerial, serial, true))
		{
			ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "1", "1", "1", "1");
			SendClientMessagef(playerid, COL_PUNISHMENT, "This account (*) has been %s banned by %s for '%s'.", (expires == -1 ? ("temporarily") : "permanently"), admin, reason);
			Kick(playerid);
			break;
		}
	}
	return true;
}

forward OnPlayerLogin(playerid, bool:fromRegistration);
public OnPlayerLogin(playerid, bool:fromRegistration)
{
	new query[256], serial[40 + 1], ip[16];
	gpci(playerid, serial, sizeof(serial));
	GetPlayerIp(playerid, ip, sizeof(ip));
	mysql_format(g_Sql, query, sizeof(query),"UPDATE core_playerinfo SET boolIsOnline = '1', strSerial = '%e', strIP = '%e', dtLastLogged = now() WHERE uid = '%d'", serial, ip, Player[playerid][ID]);
	mysql_pquery(g_Sql, query);

	Player[playerid][IsLoggedIn] = true;

	format(query, sizeof(query), "`#JOIN`  %s (ID %d) has joined the server.", Player[playerid][Name], playerid);
	DCC_SendChannelMessage(g_Echo, query);

	Log("NETWORK", playerid, -1, "connect", "logged in");

	for(new Text:i = MoneyTD_First; i <= MoneyTD_Last; i++)
	{
		if (IsValidTextDraw(i))
			TextDrawShowForPlayer(playerid, i);
	}
	PlayerTextDrawShow(playerid, MoneyTD_Value[playerid]);

	UpdatePlayerMoneyOverlay(playerid);

	if (fromRegistration)
	{
		// do some stuff
	}

	if (Player[playerid][AdminLevel] >= 5)
		SetPlayerAdmin(playerid, true);
	SpawnPlayer(playerid);
	SetPlayerSkin(playerid, Player[playerid][Skin]);
	SetSpawnInfo(playerid, 0, Player[playerid][Skin], 1093.000000,-2036.000000,90.000000, 0.0, 0, 0, 0, 0, 0, 0);
	CallLocalFunction("OnPlayerJoinMode", "iii", playerid, 1, -1);
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	new query[128];
	mysql_format(g_Sql, query, sizeof(query),"UPDATE core_playerinfo SET dtDateRegistered = now() WHERE uid = '%d'", Player[playerid][ID]);
	mysql_pquery(g_Sql, query);
	CallLocalFunction("OnPlayerLogin", "ii", playerid, true);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_LOGIN:
		{
			if (response)
			{
				if (strlen(inputtext))
				{
					new hash[SHA512_LENGTH + 1];
					sha512(inputtext, hash);
					if (strcmp(hash, Player[playerid][Password], true) == 0)
					{
						PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
						CallLocalFunction("OnPlayerLogin", "ii", playerid, false);
					}
					else
					{
						PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
						Player[playerid][LoginAttempts]++;
						new string[156];
						if (Player[playerid][LoginAttempts] == MAX_LOGIN_ATTEMPTS)
						{
						    SendClientMessage(playerid, COL_LIGHTRED, "You have been kicked for too many incorrect password attemepts.");
						    Kick(playerid);
						}
						format(string, sizeof(string), ""#EMB_COL_SAMP_MSG"Welcome back, %s.\n\nPlease login by entering your password in the field below:\n\n"#EMB_COL_LIGHTRED"[ ERROR ] Wrong password! (%d/%d)", Player[playerid][Name], Player[playerid][LoginAttempts], MAX_LOGIN_ATTEMPTS);
						ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "New Dawn >> Login", string, "Login", "Quit");
					}
				}
				else
				{
					PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
					new string[128];
					format(string, sizeof(string), ""#EMB_COL_SAMP_MSG"Welcome back, %s.\n\nPlease login by entering your password in the field below:", Player[playerid][Name]);
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "New Dawn >> Login", string, "Login", "Quit");
				}
			}
			else Kick(playerid);
		}

		case DIALOG_REGISTER:
		{
			if (response)
			{
				if (strlen(inputtext) > 5)
				{
					PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
					sha512(inputtext, Player[playerid][Password], SHA512_LENGTH + 1);
					Player[playerid][Skin] = 29;
					Player[playerid][MusicType] = 1;
					Player[playerid][PM] = true;
					Player[playerid][GlobalChat] = true;
					orm_save(Player[playerid][ORM_ID], "OnPlayerRegister", "i", playerid);
					//ShowPlayerDialog(playerid, DIALOG_REGISTER_MAIL, DIALOG_STYLE_INPUT, "New Dawn >> Registration >> E-Mail", ""#EMB_COL_LIGHTBLUE_PURPLE"An e-mail address is required for you to be able to access our ucp!"#EMB_COL_SAMP_MSG"\n\nIf you don't want to give us your e-mail address just leave this field empty and click on 'Continue'.\nYou can also do this step later once you try to login to the ucp.", "Continue", "Quit");
				}
				else
				{
					PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
					new string[256];
					format(string, sizeof(string), ""#EMB_COL_SAMP_MSG"Welcome to "#EMB_COL_LIGHTBLUE_PURPLE"New Dawn"#EMB_COL_SAMP_MSG", %s.\n\nThis username is not registered to an account. \nPlease choose a password to continue:\n\n"#EMB_COL_LIGHTRED"[ ERROR ] Your password must be longer than 5 characters!", Player[playerid][Name]);
					ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "New Dawn >> Registration", string, "Register", "Quit");
				}
			}
			else Kick(playerid);
		}
		case DIALOG_REGISTER_MAIL:
		{
			if (response)
			{
				if (strlen(inputtext))
				{
					if (regex_match(inputtext, "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?") && strlen(inputtext) < 64)
					{
						new data[32];
						format(data, sizeof(data), "{email: '%s'}", inputtext);
						HTTP(playerid, HTTP_POST, ""#API"registermail", data, "OnEMailRegistrated");
						orm_save(Player[playerid][ORM_ID], "OnPlayerRegister", "i", playerid);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_REGISTER_MAIL, DIALOG_STYLE_INPUT, "New Dawn >> Registration >> E-Mail", ""#EMB_COL_LIGHTBLUE_PURPLE"An e-mail address is required for you to be able to access our ucp!"#EMB_COL_SAMP_MSG"\n\nIf you don't want to give us your e-mail address just leave this field empty and click on 'Continue'.\nYou can also do this step later once you try to login to the ucp.\n\n"#EMB_COL_LIGHTRED"[ ERROR ] Not a valid e-mail address!", "Continue", "Quit");
					}
				}
				else
					orm_save(Player[playerid][ORM_ID], "OnPlayerRegister", "i", playerid);
			}
			else Kick(playerid);
		}
	}
	return true;
}

forward OnEMailRegistrated(index, response_code, data[]);
public OnEMailRegistrated(index, response_code, data[])
{
	printf("%d %s", response_code, data);
	return true;
}

static LastNetworkCheck[MAX_PLAYERS],
		NetworkWarnings[MAX_PLAYERS];

ptask ND[1000](playerid)
{
	if (!Player[playerid][IsLoggedIn]) return false;
	if (Player[playerid][Muted])
	{
		if (--Player[playerid][Muted] == 0)
		{
			SendClientMessage(playerid, COL_PUNISHMENT, "You have been unmuted.");
		}
	}
	if (Player[playerid][ModeID] > 1)
	{
		if (GetTickCount() - LastNetworkCheck[playerid] >= 10000)
		{
			new Float:packetloss, floatAsString[4];
			GetPlayerPacketloss(playerid, packetloss);
			format(floatAsString, sizeof(floatAsString), "%.2f", packetloss);
			if (packetloss > 1.0)
			{
				SendClientMessagef(playerid, COL_LIGHTRED, "Your current packet loss is %.2f, please check your internet connection.", packetloss);
				NetworkWarnings[playerid]++;
				if (NetworkWarnings[playerid] >= 3)
				{
					Log("NETWORK", playerid, -1, "packetloss", floatAsString);

					SendClientMessage(playerid, COL_LIGHTRED, "You have been force to the lobby because your packet loss did not decrease in the past 30 seconds.");
					OnPlayerJoinMode(playerid, 1, Player[playerid][ModeID]);
				}
			}
			else if (packetloss > 3.0)
			{
				Log("NETWORK", playerid, -1, "packetloss", floatAsString);

				SendClientMessagef(playerid, COL_LIGHTRED, "Your current packetloss is %.2f, that's too high!");
				SendClientMessage(playerid, COL_LIGHTRED, "You have been forced to the lobby because your packet loss is too high.");
				OnPlayerJoinMode(playerid, 1, Player[playerid][ModeID]);
			}
			else
				NetworkWarnings[playerid] = 0;
			LastNetworkCheck[playerid] = GetTickCount();
		}
	}
	return true;
}

static 	LastChatMessageTick[MAX_PLAYERS],
		LastChatMessage[MAX_PLAYERS][128],
		ChatSpamWarnings[MAX_PLAYERS];

public OnPlayerText(playerid, text[])
{
	if (!Player[playerid][IsLoggedIn] || Player[playerid][ModeID] <= 1)
		return false;

	if (Player[playerid][Muted] > 0)
	{
		new seconds = Player[playerid][Muted];
		new minutes = floatround(seconds / 60);
		seconds = seconds % 60;
		SendClientMessagef(playerid, COL_PUNISHMENT, "You are muted for %dm %ds.", minutes, seconds);
		return false;
	}

	if (!Player[playerid][AdminLevel])
	{
		if (!strcmp(text, LastChatMessage[playerid], true) && LastChatMessage[playerid][0] != EOS)
		{
			SendClientMessage(playerid, COL_PUNISHMENT, "Please do not repeat yourself.");
			return false;
		}
		if (GetTickCount() - LastChatMessageTick[playerid] <= 2000)
		{
			ChatSpamWarnings[playerid]++;
			switch(ChatSpamWarnings[playerid])
			{
				case 3:
				{
					SendClientMessageToAllf(COL_PUNISHMENT, "%s has been muted by Sofia for 1 minute.", Player[playerid][Name]);
					Player[playerid][Muted] = 60;
					return false;
				}
				case 6:
				{
					SendClientMessageToAllf(COL_PUNISHMENT, "%s has been muted by Sofia for 5 minutes.", Player[playerid][Name]);
					Player[playerid][Muted] = 300;
					return false;
				}
				case 9:
				{
					SendClientMessageToAllf(COL_PUNISHMENT, "%s has been muted by Sofia for 10 minutes.", Player[playerid][Name]);
					Player[playerid][Muted] = 600;
					return false;
				}
				case 12:
				{
					Log("SOFIA", playerid, -1, "kick", "chat spam");
					SendClientMessageToAllf(COL_PUNISHMENT, "Sofia has kicked %s for 'Continuous/Excessive Spam'.", Player[playerid][Name]);
					Kick(playerid);
					return false;
				}
			}
		}
		else
		{
			switch(ChatSpamWarnings[playerid])
			{
				case 1, 2: ChatSpamWarnings[playerid] = 0;
				case 4, 5: ChatSpamWarnings[playerid] = 3;
				case 7, 8: ChatSpamWarnings[playerid] = 6;
				case 10, 11: ChatSpamWarnings[playerid] = 9;
			}
		}

		if (regex_match(text, "[^\x20-\x7E£€°»]"))
		{
			SendClientMessage(playerid, COL_ERROR, "Please speak English.");
			return false;
		}

		if (regex_match(text, "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b"))
		{
			SendAdminMessagef(COL_LIGHTRED, "[ANTI-RETARD WARNING] {FFFFFF}%s (%d) said '"#EMB_COL_LIGHTRED"%s{FFFFFF}'", Player[playerid][Name], playerid, text);
		}
	}

	strdel(LastChatMessage[playerid], 0, strlen(LastChatMessage[playerid]));
	strins(LastChatMessage[playerid], text, 0);
	LastChatMessageTick[playerid] = GetTickCount();

	Log("CHAT", playerid, -1, Modes[Player[playerid][ModeID]][Alias], text);

	SendModeMessagef(Player[playerid][ModeID], COL_LIGHTGREY, "[%s] {%06x}%s (%d): {FFFFFF}%s", Modes[Player[playerid][ModeID]][Alias], GetPlayerColor(playerid) >>> 8, Player[playerid][Name], playerid, text);

	new dcc[256];
	format(dcc, sizeof(dcc), "`#%s`  %s (ID %d): %s", Modes[Player[playerid][ModeID]][Alias], Player[playerid][Name], playerid, text);
	DCC_SendChannelMessage(g_Echo, dcc);
	return false;
}

public DCC_OnChannelMessage(DCC_Channel:channel, const author[], const message[])
{
	if (!strcmp(author, "NEW-DAWN", false)) return true;

	new search[8], messageWithoutCommand[128];
	if (channel == g_Echo)
	{
		for (new modeid; modeid < MAX_MODES; modeid++)
		{
			if (modeid > 1)
			{
				format(search, sizeof(search), "#%s ", Modes[modeid][Alias]);
				if (strfind(message, search, true) == 0)
				{
					strmid(messageWithoutCommand, message, strlen(search), strlen(message));
					SendModeMessagef(modeid, COL_LIGHTGREY, "[DISCORD #%s] {4956FF}%s: {FFFFFF}%s", Modes[modeid][Alias], author, messageWithoutCommand);
					return true;
				}
			}
		}
		if (strfind(message, "#g ", true) == 0)
		{
			strmid(messageWithoutCommand, message, strlen("#g "), strlen(message));
			for (new target, j = GetPlayerPoolSize(); target <= j; target++)
			{
				if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || !Player[target][GlobalChat])
					continue;
				SendClientMessagef(target, COL_LIGHTGREY, "[DISCORD #G] {4956FF}%s: {FFFFFF}%s", author, messageWithoutCommand);
			}
			return true;
		}
	}
	else if(channel == g_Moderation)
	{
		if (strfind(message, "#a ", true) == 0)
		{
			strmid(messageWithoutCommand, message, strlen("#a "), strlen(message));
			SendAdminMessagef(COL_ORANGE, "[DISCORD #A] %s: {FFFFFF}%s", author, messageWithoutCommand);
			return true;
		}
	}
	return true;
}

public OnPlayerJoinMode(playerid, newmode, oldmode)
{
	Player[playerid][ModeID] = newmode;
	if (newmode == 1)
	{
		if (IsPlayerInAnyVehicle(playerid))
		{
			RemovePlayerFromVehicle(playerid);
			DestroyVehicle(GetPlayerVehicleID(playerid));
		}

		Player[playerid][Spectating] = false;

		SetPlayerScore(playerid, 1337);
		SetPlayerTime(playerid, 21, 30);
		SetPlayerWeather(playerid, 5);

		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		TogglePlayerSpectating(playerid, true);
		InterpolateCameraPos(playerid, 1093.000000,-2036.000000,90.000000, 450.7999,-2004.1322,16.7117, 5000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid, 487.5, -1629.3000488281, 30.200000762939, 388.1844,-2028.6141,8.0331, 2500, CAMERA_MOVE);

		SetPlayerVirtualWorld(playerid, 0);

		TextDrawHideForPlayer(playerid, SKEW_BANNER);
		PlayerTextDrawHide(playerid, SKEW_BANNER_TEXT_CB[playerid]);

		TextDrawShowForPlayer(playerid, TD_Lobby[0]);
		TextDrawShowForPlayer(playerid, TD_Lobby[1]);
		TextDrawShowForPlayer(playerid, TD_Lobby[2]);
		TextDrawShowForPlayer(playerid, TD_Lobby[3]);
		for (new modeid = 0; modeid < sizeof(Modes); modeid++)
		{
			if (_:Modes[modeid][ClickTextDraw] != INVALID_TEXT_DRAW)
			{
				TextDrawShowForPlayer(playerid, Modes[modeid][ClickTextDraw]-Text:1);
				TextDrawShowForPlayer(playerid, Modes[modeid][ClickTextDraw]);
				TextDrawShowForPlayer(playerid, Modes[modeid][ClickTextDraw]+Text:1);
				TextDrawShowForPlayer(playerid, Modes[modeid][ClickTextDraw]+Text:2);
				TextDrawShowForPlayer(playerid, Modes[modeid][PlayerCountTextDraw]);
				TextDrawShowForPlayer(playerid, Modes[modeid][AliveCountTextDraw]);
			}
		}

		for (new Text:i = MoneyTD_Health_First; i <= MoneyTD_Health_Last; i++)
		{
			if (IsValidTextDraw(i))
				TextDrawHideForPlayer(playerid, i);
		}
		PlayerTextDrawHide(playerid, MoneyTD_Health_Value[playerid]);

		SelectTextDraw(playerid, 0x00000088);
	}
	else if (oldmode == 1)
	{
		TextDrawHideForPlayer(playerid, TD_Lobby[0]);
		TextDrawHideForPlayer(playerid, TD_Lobby[1]);
		TextDrawHideForPlayer(playerid, TD_Lobby[2]);
		TextDrawHideForPlayer(playerid, TD_Lobby[3]);
		for (new modeid = 0; modeid < sizeof(Modes); modeid++)
		{
			if (_:Modes[modeid][ClickTextDraw] != INVALID_TEXT_DRAW)
			{
				TextDrawHideForPlayer(playerid, Modes[modeid][ClickTextDraw]-Text:1);
				TextDrawHideForPlayer(playerid, Modes[modeid][ClickTextDraw]);
				TextDrawHideForPlayer(playerid, Modes[modeid][ClickTextDraw]+Text:1);
				TextDrawHideForPlayer(playerid, Modes[modeid][ClickTextDraw]+Text:2);
				TextDrawHideForPlayer(playerid, Modes[modeid][PlayerCountTextDraw]);
				TextDrawHideForPlayer(playerid, Modes[modeid][AliveCountTextDraw]);
			}
		}
		CancelSelectTextDraw(playerid);
	}

	if (newmode > 1)
	{
		if (Modes[newmode][Locked] && !Player[playerid][AdminLevel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}This mode is locked.");
		SendClientBlankLines(playerid, 1);
		Modes[newmode][Players]++;
		SetPlayerWeather(playerid, Modes[newmode][Weather]);
		SetPlayerTime(playerid, Modes[newmode][TimeH], Modes[newmode][TimeM]);
		for (new mplayerid, j = GetPlayerPoolSize(); mplayerid <= j; mplayerid++)
		{
			if (!IsPlayerConnected(mplayerid) || Player[mplayerid][ModeID] != newmode)
				continue;
			SendClientMessagef(mplayerid, COL_LIGHTGREY, "[JOIN] {%06x}%s (%d) {FFFFFF}has joined %s.", GetPlayerColor(playerid) >>> 8, Player[playerid][Name], playerid, Modes[newmode][Name]);
		}
		new string[64];
		if (Modes[newmode][PlayerLimit] > 0)
			format(string, sizeof(string), "~y~PLAYERS~w~~n~%d/%d", Modes[newmode][Players], Modes[newmode][PlayerLimit]);
		else
			format(string, sizeof(string), "~y~PLAYERS~w~~n~%d", Modes[newmode][Players]);
		TextDrawSetString(Modes[newmode][PlayerCountTextDraw], string);
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Type "#EMB_COL_INFORMATION"/lobby{FFFFFF} to return to the lobby.");
	}
	if (oldmode > 1)
	{
		Modes[oldmode][Players]--;
		new string[64];
		if (Modes[oldmode][PlayerLimit] > 0)
			format(string, sizeof(string), "~y~PLAYERS~w~~n~%d/%d", Modes[oldmode][Players], Modes[oldmode][PlayerLimit]);
		else
			format(string, sizeof(string), "~y~PLAYERS~w~~n~%d", Modes[oldmode][Players]);
		TextDrawSetString(Modes[oldmode][PlayerCountTextDraw], string);
	}

	CallLocalFunction("OnPlayerJoinModeHook", "iii", playerid, newmode, oldmode);
	return true;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if (Player[playerid][ModeID] == 1)
	{
		for (new i = 0; i < sizeof(Modes); i++)
		{
			if (clickedid == Modes[i][ClickTextDraw])
			{
				if (Modes[i][PlayerLimit] > 0)
				{
					if (Modes[i][Players] >= Modes[i][PlayerLimit])
					{
						SendClientMessage(playerid, COL_ERROR, "[ERROR] This mode is full.");
						break;
					}
				}
				OnPlayerJoinMode(playerid, i, Player[playerid][ModeID]);
				break;
			}
		}
	}
	return true;
}

RegisterMode(mName[], mAlias[], previewModelID = -1, plimit = -1, Float:prevZRot = 24.0, Float:prevScale = 1.0, Float:XOff = 0.0, Float:YOff = 0.0)
{
	format(Modes[mCount][Name], MAX_MODE_NAME, mName);
	format(Modes[mCount][Alias], MAX_MODE_NAME, mAlias);
	Modes[mCount][Gamemode] = -1;
	Modes[mCount][PlayerLimit] = plimit;
	if (previewModelID > 0)
	{
		new Float:X = 320 - (LOBBY_LENGTH/2) + (((LOBBY_LENGTH / LOBBY_ROWS) - LOBBY_PADDING) * lastRowPosition) + (lastRowPosition > 0 ? (LOBBY_PADDING+(LOBBY_PADDING/2))*lastRowPosition : 0.0),
			Float:YHead = 122.0 + LOBBY_PADDING+(LOBBY_PADDING/2) + ((66.0 + LOBBY_PADDING+(LOBBY_PADDING/2)) * lastColPosition),
			Float:YBody = 134.0 + LOBBY_PADDING+(LOBBY_PADDING/2) + ((66.0 + LOBBY_PADDING+(LOBBY_PADDING/2)) * lastColPosition),
		 	Text:TD = TextDrawCreate(X, YHead, "LD_SPAC:white");
		TextDrawTextSize(TD, (LOBBY_LENGTH / LOBBY_ROWS) - LOBBY_PADDING, 12.000000);
		TextDrawColor(TD, 674910207);
		TextDrawFont(TD, 4);

		Modes[mCount][ClickTextDraw] = TextDrawCreate(X, YBody, "LD_SPAC:white");
		TextDrawTextSize(Modes[mCount][ClickTextDraw], (LOBBY_LENGTH / LOBBY_ROWS) - LOBBY_PADDING, 54.000000);
		TextDrawColor(Modes[mCount][ClickTextDraw], 128);
		TextDrawSetSelectable(Modes[mCount][ClickTextDraw], true);
		TextDrawFont(Modes[mCount][ClickTextDraw], 4);

		TD = TextDrawCreate(X + 48.894547, YHead + 1.166703, mName);
		TextDrawLetterSize(TD, 0.225241, 0.987496);
		TextDrawAlignment(TD, 2);
		TextDrawSetShadow(TD, 0);
		TextDrawSetOutline(TD, 1);
		TextDrawColor(TD, -1);
		TextDrawBackgroundColor(TD, 25);
		TextDrawFont(TD, 1);
		TextDrawSetProportional(TD, 1);
		TextDrawSetShadow(TD, 0);

		TD = TextDrawCreate(X + XOff, YBody-26.0 + YOff, "");
		TextDrawTextSize(TD, 90.000000, 90.000000);
		TextDrawColor(TD, -1);
		TextDrawBackgroundColor(TD, 0);
		TextDrawFont(TD, 5);
		TextDrawSetPreviewModel(TD, previewModelID);
		TextDrawSetPreviewRot(TD, 0.000000, 0.000000, prevZRot, prevScale);
		TextDrawSetPreviewVehCol(TD, 45, 1);

		if (plimit > 0)
		{
			new string[64];
			format(string, sizeof(string), "~y~PLAYERS~w~~n~0/%d", plimit);
			Modes[mCount][PlayerCountTextDraw] = TextDrawCreate(X+16.0, YBody+34.0, string);
		}
		else
			Modes[mCount][PlayerCountTextDraw] = TextDrawCreate(X+16.0, YBody+34.0, "~y~PLAYERS~w~~n~0");
		TextDrawLetterSize(Modes[mCount][PlayerCountTextDraw], 0.194315, 0.987495);
		TextDrawAlignment(Modes[mCount][PlayerCountTextDraw], 2);
		TextDrawSetShadow(Modes[mCount][PlayerCountTextDraw], 0);
		TextDrawSetOutline(Modes[mCount][PlayerCountTextDraw], 0);
		TextDrawFont(Modes[mCount][PlayerCountTextDraw], 1);
		TextDrawSetProportional(Modes[mCount][PlayerCountTextDraw], 1);
		TextDrawSetShadow(Modes[mCount][PlayerCountTextDraw], 0);

		Modes[mCount][AliveCountTextDraw] = TextDrawCreate(X+90.0, YBody+34.0, "~y~ALIVE~w~~n~0");
		TextDrawLetterSize(Modes[mCount][AliveCountTextDraw], 0.194315, 0.987495);
		TextDrawAlignment(Modes[mCount][AliveCountTextDraw], 2);
		TextDrawSetShadow(Modes[mCount][AliveCountTextDraw], 0);
		TextDrawSetOutline(Modes[mCount][AliveCountTextDraw], 0);
		TextDrawFont(Modes[mCount][AliveCountTextDraw], 1);
		TextDrawSetProportional(Modes[mCount][AliveCountTextDraw], 1);
		TextDrawSetShadow(Modes[mCount][AliveCountTextDraw], 0);

		lastRowPosition++;
		if (lastRowPosition >= LOBBY_ROWS)
		{
			lastRowPosition = 0;
			lastColPosition++;
		}
	}
	mCount++;
	return mCount-1;
}

UpdatePlayerMoneyOverlay(playerid)
{
	if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn]) return false;
	new string[16];

	format(string, sizeof(string), "~g~$~w~%d", Player[playerid][Money]);
	PlayerTextDrawSetString(playerid, MoneyTD_Value[playerid], string);

	if (IsTextDrawVisibleForPlayer(playerid, MoneyTD_Health_First))
	{
		new Float:Health, target = playerid;
		if (Player[playerid][Spectating])
		{
			if (IsPlayerConnected(Player[playerid][SpectateID]))
				target = Player[playerid][SpectateID];
		}

		if (!IsPlayerInAnyVehicle(target))
			GetPlayerHealth(target, Health);
		else
		{
			GetVehicleHealth(GetPlayerVehicleID(target), Health);
			Health = Health / 10;
		}
		format(string, sizeof(string), "~w~%d%%", floatround(Health));
		PlayerTextDrawSetString(playerid, MoneyTD_Health_Value[playerid], string);

		PlayerTextDrawTextSize(playerid, MoneyTD_Health_Background[playerid], 543.55 + ((615.60 - 543.55) / 100 * Health), 0.0);
		PlayerTextDrawShow(playerid, MoneyTD_Health_Background[playerid]);
	}
	return true;
}
