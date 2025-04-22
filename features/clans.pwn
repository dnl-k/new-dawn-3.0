enum E_CLANS
{
    ID,
    Name[MAX_CLAN_NAME],
    Tag[MAX_CLAN_NAME]
}

new Clans[MAX_CLANS][E_CLANS];

Hook:CLANS_OnSQLConnection()
{
    mysql_pquery(g_Sql, "SELECT * FROM module_clans", "OnClansLoaded", "i", INVALID_PLAYER_ID);
    return true;
}

forward OnClansLoaded(admin);
public OnClansLoaded(admin)
{
    new results;
    cache_get_result_count(results);
    if (results > 1)
    {
        SendClientMessagef(admin, COL_INFORMATION, "[INFO] {FFFFFF}Created clan ID %d.", cache_insert_id());
        cache_set_result(1);
    }

    new rows = cache_num_rows();
    if (rows)
    {
        for (new rowid; rowid < rows; rowid++)
        {
            cache_get_value_name_int(rowid, "uid", Clans[rowid][ID]);
            cache_get_value_name(rowid, "strName", Clans[rowid][Name]);
            cache_get_value_name(rowid, "strTag", Clans[rowid][Tag]);
        }
    }
    return true;
}

Hook:CLANS_OnPlayerLogin(playerid)
{
    if (Player[playerid][ClanID])
    {
        new id = GetPlayerClanInternalID(Player[playerid][ClanID]);
        for (new pid, j = GetPlayerPoolSize(); pid <= j; pid++)
        {
            if (!IsPlayerConnected(pid) || !Player[pid][IsLoggedIn] || Player[pid][ClanID] != Player[playerid][ClanID])
                continue;
            SendClientMessagef(pid, COL_GREEN, "[%s] {%06x}%s (%d) {FFFFFF}has logged in.", Clans[id][Tag], GetPlayerColor(playerid) >>> 8, Player[playerid][Name], playerid);
        }
    }
    return true;
}

CMD:c(playerid, params[])
{
    if (Player[playerid][ClanID] <= 0) return false;
    new text[128];
    if (sscanf(params, "s[128]", text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/c [text]");
    new id = GetPlayerClanInternalID(Player[playerid][ClanID]);
    for (new pid, j = GetPlayerPoolSize(); pid <= j; pid++)
    {
        if (!IsPlayerConnected(pid) || !Player[pid][IsLoggedIn] || Player[pid][ClanID] != Player[playerid][ClanID])
            continue;
        SendClientMessagef(pid, COL_GREEN, "[%s] {%06x}%s (%d): {FFFFFF}%s", Clans[id][Tag], GetPlayerColor(playerid)  >>> 8, Player[playerid][Name], playerid, text);
    }
    return true;
}

CMD:cinvite(playerid, params[])
{
    return true;
}

CMD:ckick(playerid, params[])
{
    return true;
}

CMD:cleave(playerid, params[])
{
    return true;
}

CMD:createclan(playerid, params[])
{
    new name[MAX_CLAN_NAME], tag[MAX_CLAN_NAME];
    if (sscanf(params, "s[MAX_CLAN_NAME]s[MAX_CLAN_NAME]", tag, name)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/createclan [tag] [name]");
    if (Clans[MAX_CLANS - 1][ID] > 0) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Clan limit has been reached.");
    new query[128];
    mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_clans (strTag, strName) VALUES ('%e', '%e'); SELECT * FROM module_clans", tag, name);
    mysql_pquery(g_Sql, query, "OnClansLoaded", "i", playerid);
    return true;
}
flags:createclan(CMD_SENIOR_MODERATOR);

CMD:setplayerclan(playerid, params[])
{
    new target, clanid, rank;
    if (sscanf(params, "uii", target, clanid, rank)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/setplayerclan [player] [clanid] [rank]");
    if (rank < 0 || rank > 1) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Invalid rank.");
    if (clanid > 0)
    {
        for (new i; i < MAX_CLANS; i++)
        {
            if (Clans[i][ID] == clanid)
            {
                Player[target][ClanID] = Clans[i][ID];
                Player[target][ClanRank] = rank;
                orm_save(Player[target][ORM_ID]);
                SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You made %s a member of %s.", Player[target][Name], Clans[i][Name]);
                SendClientMessagef(target, COL_INFORMATION, "[INFO] {FFFFFF}Administrator %s made you a member of %s.", Player[playerid][Name], Clans[i][Name]);
                break;
            }
        }
    }
    else
    {
        new id = GetPlayerClanInternalID(Player[target][ClanID]);
        SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You made removed %s from %s.", Player[target][Name], Clans[id][Name]);
        SendClientMessagef(target, COL_INFORMATION, "[INFO] {FFFFFF}Administrator %s removed you from %s.", Player[playerid][Name], Clans[id][Name]);
        Player[target][ClanID] = 0;
        Player[target][ClanRank] = 0;
        orm_save(Player[target][ORM_ID]);
    }
    return true;
}
flags:setplayerclan(CMD_SENIOR_MODERATOR);

GetPlayerClanInternalID(clanid)
{
    for (new i; i < MAX_CLANS; i++)
    {
        if (Clans[i][ID] == clanid)
            return i;
    }
    return -1;
}

IsSomeoneFromClanConnected(internalClanID)
{
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i) && GetPlayerClanInternalID(Player[i][ClanID]) == internalClanID && Player[i][IsLoggedIn])
            return true;
    }

    return false;
}

GetClanIDByName(clanname[])
{
    for (new i; i < MAX_CLANS; i++)
    {
        if (!strcmp(clanname, Clans[i][Name]))
            return i;
    }
    return -1;
}