CMD:color(playerid, params[])
{
    new col1, col2;
    if (sscanf(params, "ii", col1, col2)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/color [primary] [secondary]");
    if ((-1 <= col1 <= 255) && (-1 <= col2 <= 255))
    {
        Player[playerid][CarColor1] = col1;
        Player[playerid][CarColor2] = col2;
        orm_save(Player[playerid][ORM_ID]);
        if (IsPlayerInAnyVehicle(playerid))
            ChangeVehicleColor(GetPlayerVehicleID(playerid), col1, col2);
        SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You have changed your vehicles color to "#EMB_COL_INFORMATION"%d {FFFFFF}- "#EMB_COL_INFORMATION"%d{FFFFFF}.", col1, col2);
    }
    return true;
}
