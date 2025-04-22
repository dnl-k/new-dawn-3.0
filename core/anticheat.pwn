enum E_ACPLAYER
{
    LastUpdate,
    bool:PlayerAttacked[MAX_PLAYERS],
    WeaponSlotID[13],
    WeaponSlotAmmo[13],

    Float:g_X, Float:g_Y, Float:g_Z
}

static AC[MAX_PLAYERS][E_ACPLAYER];

Hook:AC_OnPlayerConnect(playerid)
{
    for (new var = 0; var <= GetPlayerPoolSize(); var++) {
        AC[playerid][PlayerAttacked][var] = false;
        AC[var][PlayerAttacked][playerid] = false;
    }
    return true;
}


Hook:AC_OnPlayerUpdate(playerid)
{
    if (gettime() - AC[playerid][LastUpdate] >= 2 && (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER))
    {
        new weapondata[13][2];
        for (new slot = 0; slot <= 12; slot++)
        {
            GetPlayerWeaponData(playerid, slot, weapondata[slot][0], weapondata[slot][1]);
            if(weapondata[slot][0] < 1 || weapondata[slot][0] > 42)
                continue;
            if (weapondata[slot][0] != AC[playerid][WeaponSlotID][slot] || weapondata[slot][1] > AC[playerid][WeaponSlotAmmo][slot])
            {
                AC_Ban(playerid, "Weapon Cheat");
                break;
            }
        }
        AC[playerid][LastUpdate] = gettime();
    }

    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        new Float:X, Float:Y, Float:Z,
            Float:vX, Float:vY, Float:vZ,
            string[9];

        if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new vehicleid = GetPlayerVehicleID(playerid);

            GetVehiclePos(vehicleid, X, Y, Z);
            GetVehicleVelocity(vehicleid, vX, vY, vZ);

            new Speed = floatround(floatsqroot(floatpower(floatabs(vX), 2.0) + floatpower(floatabs(vY), 2.0) + floatpower(floatabs(vZ), 2.0)) * 179.28625);

            format(string, sizeof(string), "%.6f", floatabs(vZ));
            new Float:Val = floatstr(string);

            new Float:dist = GetVehicleDistanceFromPoint(vehicleid, AC[playerid][g_X], AC[playerid][g_Y], AC[playerid][g_Z]);

            if (floatcmp(dist, 1.0) == 1 && floatcmp(dist, 4.0) == -1 && floatcmp(floatabs(vX), 0.000000) == 1 && floatcmp(floatabs(vY), 0.000000) == 1 && floatcmp(Val, 0.000000) == 0 && !Speed)
                AC_Ban(playerid, "Airbrake (In-car)");
        }

        AC[playerid][g_X] = X;
		AC[playerid][g_Y] = Y;
		AC[playerid][g_Z] = Z;
    }
    return true;
}


Hook:AC_OnPlayerTakeDamage(playerid,issuerid,Float:amount,weaponid,bodypart)
{
    if (issuerid != INVALID_PLAYER_ID)
        AC[issuerid][PlayerAttacked][playerid] = true;
    return true;
}

Hook:AC_OnPlayerDeath(playerid,killerid,reason)
{
    static empty_ac[E_ACPLAYER];
    AC[playerid][WeaponSlotID] = empty_ac[WeaponSlotID];
    AC[playerid][WeaponSlotAmmo] = empty_ac[WeaponSlotAmmo];
    if (killerid != INVALID_PLAYER_ID)
    {
        if (!AC[killerid][PlayerAttacked][playerid])
        {
            AC_Ban(playerid, "Fake Kill");
            return true;
        }
    }
    for (new var = 0; var <= GetPlayerPoolSize(); var++)
        AC[var][PlayerAttacked][playerid] = false;
    return true;
}

stock AC_GivePlayerWeapon(playerid, weaponid, ammo)
{
    if(GivePlayerWeapon(playerid, weaponid, ammo))
    {
        new slot = GetWeaponSlot(weaponid);
        AC[playerid][WeaponSlotID][slot] = weaponid;
        AC[playerid][WeaponSlotAmmo][slot] = ammo;
        return true;
    }
    return false;
}
#if defined _ALS_GivePlayerWeapon
    #undef GivePlayerWeapon
#else
    #define _ALS_GivePlayerWeapon
#endif
#define GivePlayerWeapon AC_GivePlayerWeapon

stock AC_ResetPlayerWeapons(playerid)
{
    if(ResetPlayerWeapons(playerid))
    {
        static empty_ac[E_ACPLAYER];
        AC[playerid][WeaponSlotID] = empty_ac[WeaponSlotID];
        AC[playerid][WeaponSlotAmmo] = empty_ac[WeaponSlotAmmo];
        return true;
    }
    return false;
}
#if defined _ALS_ResetPlayerWeapons
    #undef ResetPlayerWeapons
#else
    #define _ALS_ResetPlayerWeapons
#endif
#define ResetPlayerWeapons AC_ResetPlayerWeapons

stock AC_SetPlayerAmmo(playerid, weaponid, ammo)
{
    if(SetPlayerAmmo(playerid, weaponid, ammo))
    {
        new weapondata[13][2];
        for (new slot = 0; slot <= 12; slot++)
        {
            GetPlayerWeaponData(playerid, slot, weapondata[slot][0], weapondata[slot][1]);
            if(weapondata[slot][0] == weaponid)
            {
                new slot = GetWeaponSlot(weaponid);
                AC[playerid][WeaponSlotAmmo][slot] = ammo;
            }
            else continue;
        }
        return true;
    }
    return false;
}
#if defined _ALS_SetPlayerAmmo
    #undef SetPlayerAmmo
#else
    #define _ALS_SetPlayerAmmo
#endif
#define SetPlayerAmmo AC_SetPlayerAmmo

static AC_Ban(playerid, reason[])
{
    if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn]) return false;
    SendClientMessageToAllf(COL_PUNISHMENT, "Sofia has banned %s for '%s' (Permanent).", Player[playerid][Name], reason);

    new query[500], Country[MAX_COUNTRY_NAME], ISP[MAX_COUNTRY_NAME], IP[16], Serial[40 + 1];
    GetPlayerCountry(playerid, Country, sizeof(Country));
    GetPlayerISP(playerid, ISP, sizeof(ISP));
    GetPlayerIp(playerid, IP, sizeof(IP));
    gpci(playerid, Serial, sizeof(Serial));

    mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_bans (strType, strValue, strPlayerName, strReason, uidAdmin, strAdmin, utExpires, strSerial, strIP, strISP, strCountry, dtBanned) VALUES ('uid', '%d', '%e', '%s', '-1', 'Sofia', '-1', '%e', '%e', '%e', '%e', now())", Player[playerid][ID], Player[playerid][Name], reason, Serial, IP, ISP, Country);
    mysql_pquery(g_Sql, query);

    return Kick(playerid);
}
