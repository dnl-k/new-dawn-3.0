#if !defined gpci
    native gpci(playerid, serial[], len);
#endif

forward OnPlayerVirtualWorldChange(playerid,newvirtualworld);

static PlayerColors[] = {
    0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,0xF4A460FF,0xEE82EEFF,
    0xFFD720FF,0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,0x10DC29FF,0x534081FF,0x0495CDFF,
    0xEF6CE8FF,0xBD34DAFF,0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,0x65ADEBFF,0x5C1ACCFF,0xF2F853FF,0x11F891FF,
    0x7B39AAFF,0x53EB10FF,0x54137DFF,0x275222FF,0xF09F5BFF,0x3D0A4FFF,0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,
    0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,0x057F94FF,0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,
    0x93AB1CFF,0x95BAF0FF,0x369976FF,0x18F71FFF,0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,
    0x2D74FDFF,0x3C1C0DFF,0x12D6D4FF,0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,
    0x42ACF5FF,0x2FD9DEFF,0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,
    0x3214AAFF,0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,0xDCDE3DFF,
    0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,0xD8C762FF,0x3FE65CFF
};

Hook:FIX_OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, PlayerColors[playerid % sizeof PlayerColors]);
    return true;
}

native B_SetPlayerVirtualWorld(playerid, newvirtualworld) = SetPlayerVirtualWorld;
stock _SetPlayerVirtualWorld(playerid,virtualworld)
{
    SetPlayerVirtualWorld(playerid,virtualworld);
    CallRemoteFunction("OnPlayerVirtualWorldChange", "ii",playerid,virtualworld);
    return true;
}
#if defined _ALS_SetPlayerVirtualWorld
	#undef SetPlayerVirtualWorld
#else
	#define _ALS_SetPlayerVirtualWorld
#endif
#define SetPlayerVirtualWorld _SetPlayerVirtualWorld

native B_Kick(playerid) = Kick;
native B_Ban(playerid) = Ban;
native B_BanEx(playerid,const reason[]) = BanEx;
forward kickplayer(playerid);
forward banplayer(playerid);
forward banexplayer(playerid,const reason[]);
stock _Kick(playerid)
{
	SetTimerEx("kickplayer",100,0,"d",playerid);
	return true;
}
stock _Ban(playerid)
{
	SetTimerEx("banplayer",100,0,"d",playerid);
	return true;
}
stock _BanEx(playerid,const reason[])
{
	SetTimerEx("banexplayer",100,0,"ds",playerid,reason);
	return true;
}
public kickplayer(playerid)
	return B_Kick(playerid);
public banplayer(playerid)
	return B_Ban(playerid);

public banexplayer(playerid,const reason[])
	return B_BanEx(playerid,reason);

#if defined _ALS_Kick
	#undef Kick
#else
	#define _ALS_Kick
#endif
#define Kick _Kick
#if defined _ALS_Ban
	#undef Ban
#else
	#define _ALS_Ban
#endif
#define Ban _Ban
#if defined _ALS_BanEx
	#undef BanEx
#else
	#define _ALS_BanEx
#endif
#define BanEx _BanEx
