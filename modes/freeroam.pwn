#define MAX_STUNTS 64
#define MAX_GARAGES 64
#define MAX_SUB_HOUSES 64
#define MAX_HOUSES 64
#define MAX_PLAYER_HOUSES 5
#define DIALOG_FR_FIRST_SPAWN 31
#define DIALOG_FR_STUNT_TELE 32

enum(<<=1)
{
	CMD_FR
}

enum E_STUNT {
	StuntCount
};

static ModeData[E_STUNT];

enum E_STUNT_PLAYER {
	bool:FirstSpawn,
	bool:IsFreeroam,
	StuntId,
	Float:Health,
	Float:x,
	Float:y,
	Float:z,
	Agression
};

static PlayerModeData[MAX_PLAYERS][E_STUNT_PLAYER];

enum E_FREEROAM_VEHICLE
{
	ModelId,
	OwnerId,
	Colour[2],
	Houses[MAX_PLAYER_HOUSES][E_FREEROAM_PLY_HOUSES]
}
static Vehicle[MAX_VEHICLES][E_FREEROAM_VEHICLE];

enum E_FREEROAM_GARAGE
{
	Name[32],
	InteriorWorld,
	InteriorId,
	Capacity,
}
static Garage[MAX_GARAGES][E_FREEROAM_VEHICLE];

enum E_FREEROAM_HOUSE
{
	Name[32],
	Float:Entrance[3],
	ItemCapacity,
	InteriorWorld,
	InteriorId,
	Float:Door[3],
	bool:hasGarage,
	GarageId
};
static House[MAX_HOUSES][E_FREEROAM_HOUSE] = {
	{"Pershing Square", {0.0,0.0,0.0}, 0, 0, 2, {0.0,0.0,0.0}, false, -1},
};

enum E_INTERIOR_LIST {
	InteriorWorld,
	Float:x,
	Float:y,
	Float:z
};

static Float:Interiors[1][E_INTERIOR_LIST] = {
	{0,0,0,0},
	//{interiorWorld, X, Y, Z}
};

enum E_FREEROAM_PLY_HOUSES
{
	HouseId,
	GarageId,
}
static PlayerHouse[MAX_PLAYERS][MAX_HOUSES][E_FREEROAM_PLY_HOUSES];

static Float:DefaultSpawn[3] = {
	0.0,
	0.0,
	0.0
};

enum E_STUNTS {
	Name[32],
	Alias[16],
	Float:Spawn[3],
	Float:BoundaryX[2],
	Float:BoundaryY[2],
	bool:AllowVehicles,
	bool:AllowWeapons
};

new Stunts[MAX_STUNTS][E_STUNTS];
new StuntMenu[1024];

new AgressionCol[6] = {
	COL_WHITE, // Innocent
	COL_WHITE, // Neutral
	COL_LIGHTPINK, // Low Risk
	COL_SMOOTHPINK, // Guarenteed Risk
	COL_SMOOTHPINK, // Bounty
	COL_RPRED  // Double Bounty
};

static Float:HospitalSpawns[1][3] = {
	{0.0,0.0,0.0}
};

forward OnPlayerStuntSpawn(stuntid, playerid);

static this = -1;

stock NewStuntMap()
{
    ModeData[StuntCount]++;
	return ModeData[StuntCount];
}

#include "./stunts/blank.pwn"
#include "./stunts/underwater.pwn"

Hook:FR_initModule()
{
    this = RegisterMode("Freeroam", "FR", 2994, -1);
    print("Freeroam loading..");
    ModeData[StuntCount] = -1;
	Modes[this][Gamemode] = GAMEMODE_PLAY;
	CallLocalFunction("InitStunt", "");
	SetTimer("OnStuntsLoaded", 2500, false);
	//#include ".\stunts\nigerian-halfpipe.pwn"
}

forward OnStuntsLoaded();
public OnStuntsLoaded() {
	printf("%d", ModeData[StuntCount]);
	for(new i = 0; i < ModeData[StuntCount]+1; i++)
	{
	    if(i == 0) {
			format(StuntMenu, sizeof(StuntMenu), "%s [/t %s]", Stunts[i][Name], Stunts[i][Alias]);
			continue;
		}
	    format(StuntMenu, sizeof(StuntMenu), "%s\n%s [/t %s]", StuntMenu, Stunts[i][Name], Stunts[i][Alias]);
	}
	printf("%s", StuntMenu);
}

Hook:FR_OnPlayerJoinModeHook(playerid, newmode, oldmode)
{
    if (newmode == this)
    {
        PlayerModeData[playerid][FirstSpawn] = true;
        PlayerModeData[playerid][IsFreeroam] = false;
        PlayerModeData[playerid][Health] = 0.0;
        PlayerModeData[playerid][StuntId] = -1;
        PlayerModeData[playerid][Agression] = 0;
        SetAgressionLevel(playerid, PlayerModeData[playerid][Agression]);
        SendClientMessage(playerid, -1, StuntMenu);
		if(PlayerModeData[playerid][FirstSpawn])
		{
			ShowPlayerDialog(playerid,DIALOG_FR_FIRST_SPAWN, DIALOG_STYLE_MSGBOX, "Welcome", "Welcome to Freeroam.\nWhere would you like to spawn?", "Freeroam", "Stunt");
		    /*if(PlayerModeData[playerid][IsFreeroam]) {

			} else {
				ShowStuntMenu(playerid);
			}*/
		} else {
		    // If player has joined Freeroam at least once
		}
    }
    else if (oldmode == this)
    {
    	SetSpawnInfo(playerid, -1, 0, DefaultSpawn[0], DefaultSpawn[1], DefaultSpawn[2], 0, 0, 0, 0, 0, 0, 0);
    }
}

Hook:FR_OnPlayerSpawn(playerid)
{
	if(Player[playerid][ModeID] != this) return true;
	PlayerModeData[playerid][Health] = 100.0;
	return 1;
}

SetAgressionLevel(playerid, level) {
	if(level > 5) level = 5;
	PlayerModeData[playerid][Agression] = level;
	if(level < 0) level = 0;
	SetPlayerColor(playerid, AgressionCol[level]);
}

Hook:FR_OnPlayerDeath(playerid, killerid, reason)
{
	if(Player[playerid][ModeID] != this) return true;
	if(PlayerModeData[playerid][StuntId] > -1) {
	    SetPlayerStunt(playerid, PlayerModeData[playerid][StuntId]);
	} else {
		if(PlayerModeData[playerid][Agression] <= 2) { // If the victim was Low risk, neutral or innocent
		    SetAgressionLevel(playerid, PlayerModeData[killerid][Agression]+1); // +1 to Agression
		}
		if(PlayerModeData[playerid][Agression] == 0) {
		    SetAgressionLevel(playerid, -1); // +1 to Agression
		}
		if(PlayerModeData[playerid][Agression] > 1) SetAgressionLevel(playerid, 1);
		else SetAgressionLevel(playerid, 0);
		SendClientMessage(playerid, COL_WHITE, "You dead, nigga");
		TogglePlayerSpectating(playerid, true);
		SetPlayerToNearestHospital(playerid);
		TogglePlayerSpectating(playerid, false);
	}
	return true;
}

forward SetPlayerToNearestHospital(playerid);
public SetPlayerToNearestHospital(playerid)
{
	new closest[2];
	closest[0] = -1;
	closest[1] = 20000; // Max X/Y
	for(new i = 0; i < sizeof(HospitalSpawns); i++) {
		new Float:curr = GetPlayerDistanceFromPoint(playerid, HospitalSpawns[i][0], HospitalSpawns[i][1], HospitalSpawns[i][2]);
		if(curr < Float:closest[1]) {
			closest[0] = i;
			closest[1] = _:curr;
		}
	}
	SetSpawnInfo(playerid, -1, Player[playerid][Skin], HospitalSpawns[closest[0]][0],HospitalSpawns[closest[0]][1],HospitalSpawns[closest[0]][2],0,0,0,0,0,0,0);
}

stock ShowStuntMenu(playerid)
{
	SendClientMessage(playerid, -1, "Here, ok");
	ShowPlayerDialog(playerid, DIALOG_FR_STUNT_TELE, DIALOG_STYLE_LIST, "Stunt Teleports", StuntMenu, "Teleport", "Close");
	return true;
}

stock SetPlayerStunt(playerid, stuntid, bool:isAlive = true)
{
	PlayerModeData[playerid][StuntId] = stuntid;
	if(PlayerModeData[playerid][Health] == 0.0) {
       	SetSpawnInfo(playerid, -1, 0, Stunts[stuntid][Spawn][0], Stunts[stuntid][Spawn][1], Stunts[stuntid][Spawn][2], 0, 0, 0, 0, 0, 0, 0);
	    TogglePlayerSpectating(playerid, false);
	    return true;
	}
	FreezeTimer(playerid, true);
	if(isAlive == true) {
		SetPlayerPos(playerid, Stunts[stuntid][Spawn][0], Stunts[stuntid][Spawn][1], Stunts[stuntid][Spawn][2]);
		SetPlayerWorldBounds(playerid, Stunts[stuntid][BoundaryX][0], Stunts[stuntid][BoundaryX][1], Stunts[stuntid][BoundaryY][0], Stunts[stuntid][BoundaryY][1]);
	} else {
	    SetSpawnInfo(playerid, -1, Player[playerid][Skin], Stunts[stuntid][Spawn][0], Stunts[stuntid][Spawn][1], Stunts[stuntid][Spawn][2], 0, 0,0,0,0,0,0);
	}
	return true;
}

CreateStuntObject(id, Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ, Float:scale, bool:collision, materialcolor)
{
	return CallLocalFunction("CreateObjectForGameMode", "ifffffffixi", id, X, Y, Z, rX, rY, rZ, scale, collision, materialcolor, this);
}

forward FreezeTimer(playerid, bool:freeze);
public FreezeTimer(playerid, bool:freeze)
{
	if(freeze)
	{
	    TogglePlayerControllable(playerid, false);
		SetTimerEx("FreezeTimer", 750, false, "ii", playerid, false);
	}
	else
	{
	    TogglePlayerControllable(playerid, true);
	}
}

flags:tele(CMD_FR);
cmd:tele(playerid, params[])
{
	if(Player[playerid][ModeID] != this) return SendClientMessageWrongMode(playerid, this);
	new StuntMap[16];
	if(sscanf(params, "s[16]", StuntMap)) return ShowStuntMenu(playerid);
	for(new i = 0; i < MAX_STUNTS; i++) {
		if(strcmp(Stunts[i][Alias], StuntMap, true) == 0) {
			SetPlayerStunt(playerid, i);
			break;
		}
	}
	return true;
}
alias:tele("t");

Hook:FR_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_FR_FIRST_SPAWN:
		{
		    SendClientMessage(playerid, -1, "Hello");
		    if(response) {
		    	SendClientMessage(playerid, -1, "Reponse!");
				PlayerModeData[playerid][FirstSpawn] = false;
				PlayerModeData[playerid][IsFreeroam] = false;
				SetSpawnInfo(playerid, -1, 0, DefaultSpawn[0], DefaultSpawn[1], DefaultSpawn[2], 0, 0, 0, 0, 0, 0, 0);
		    } else {
		    	SendClientMessage(playerid, -1, "Cheeky!");
		        ShowStuntMenu(playerid);
		    }
		}
		case DIALOG_FR_STUNT_TELE:
		{
			if(response) {
			    SetPlayerStunt(playerid, listitem);
			}
		}
	}
	return 1;
}
