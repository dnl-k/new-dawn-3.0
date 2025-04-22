static  this = -1,
        Text:Deathlist[4][3];

enum
{
    DIALOG_CW_MAIN_VIEW = 1337,

    DIALOG_CW_SETUP_A,
    DIALOG_CW_SETUP_A_AUTO,
    DIALOG_CW_SETUP_A_AUTO_PLAYER,
    DIALOG_CW_SETUP_A_MANUAL,
    DIALOG_CW_SETUP_A_MANUAL_PLAYER,

    DIALOG_CW_SETUP_B,
    DIALOG_CW_SETUP_B_AUTO,
    DIALOG_CW_SETUP_B_AUTO_PLAYER,
    DIALOG_CW_SETUP_B_MANUAL,
    DIALOG_CW_SETUP_B_MANUAL_PLAYER,

    DIALOG_CW_START_MAP,
    DIALOG_CW_START_MAP_SELECT
}

enum
{
    CW_STATE_SETUP,
    CW_STATE_IDLE,
    CW_STATE_RUNNING
}

enum
{
    ROUND_STATE_LOADING,
    ROUND_STATE_SPAWNED,
    ROUND_STATE_COUNTDOWN,
    ROUND_STATE_ONGOING
}

enum E_CLANWAR
{
    Spawns, VW_Counter,
	StartTick,
	TotalAlive, Alive,
	Map[256], MapID, MapRoundsLeft,
    ModeState,
	RoundState,

	// Main UI
	Text:MainFirst, Text:MainMap, Text:MainNextMap, Text:MainTime, Text:MainLast,

	// CW Info
	Text:CWInfoFirst, Text:CWInfoLineTop, Text:CWInfoRoundsLeft, Text:CWInfoTeamA, Text:CWInfoVersus, Text:CWInfoTeamB,
	Text:CWInfoLine, Text:CWInfoTeamAPlayers, Text:CWInfoTeamAScore, Text:CWInfoScoreDash, Text:CWInfoTeamBScore,
	Text:CWInfoLine2, Text:CWInfoTeamBPlayers,

	LastDead,

	Team_A[8], Team_B[8],
    Team_A_Related_Clan_ID, Team_B_Related_Clan_ID,
    Team_A_Score, Team_B_Score
}
static ModeData[E_CLANWAR];

enum E_CLANWAR_PLAYER
{
	Team,
	IsAlive
}
static PlayerModeData[MAX_PLAYERS][E_CLANWAR_PLAYER];

Hook:CW_initModule()
{
    this = RegisterMode("Clanwar", "CW", 1247, 0, 0.0, 1.5, 0.0, 4.0);
    CreateMainUI(ModeData[MainFirst],ModeData[MainMap],ModeData[MainNextMap],ModeData[MainTime],ModeData[MainLast]);
    CreateDeathlist(Deathlist[3],Deathlist[2],Deathlist[1],Deathlist[0]);
    CreateCWInfo(ModeData[CWInfoFirst], ModeData[CWInfoLineTop], ModeData[CWInfoRoundsLeft], ModeData[CWInfoTeamA],
                 ModeData[CWInfoVersus], ModeData[CWInfoTeamB], ModeData[CWInfoLine], ModeData[CWInfoTeamAPlayers],
                 ModeData[CWInfoTeamAScore], ModeData[CWInfoScoreDash], ModeData[CWInfoTeamBScore],
                 ModeData[CWInfoLine2], ModeData[CWInfoTeamBPlayers]);
    TextDrawSetString(Modes[this][AliveCountTextDraw], "~y~Score~w~~n~0:0");
    TextDrawSetString(ModeData[MainNextMap], "~y~Next ~w~DISABLED");

    ModeData[Team_A_Related_Clan_ID] = -1;
    ModeData[Team_B_Related_Clan_ID] = -1;

    return true;
}

Hook:CW_OnPlayerJoinModeHook(playerid, newmode, oldmode)
{
    if (newmode == this)
    {
        TogglePlayerSpectating(playerid, false);
		static const empty_data[E_CLANWAR_PLAYER];
		PlayerModeData[playerid] = empty_data;

        DisableRemoteVehicleCollisions(playerid, true);

        switch(ModeData[ModeState])
        {
            case CW_STATE_SETUP: // No active clanwar || Setup required
            {
                SetFadeStateBlack(this);
                TogglePlayerSpectating(playerid, true);
                TextDrawShowForPlayer(playerid, SKEW_BANNER);
                PlayerTextDrawSetString(playerid, SKEW_BANNER_TEXT_CB[playerid], "~y~No active clanwar");
                PlayerTextDrawShow(playerid, SKEW_BANNER_TEXT_CB[playerid]);
            }
            case CW_STATE_IDLE: // Active clanwar || Idle
            {
                TogglePlayerSpectating(playerid, true);
                ShowFadeTextdrawForPlayer(playerid, this);

                for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
                    if (i != Text:INVALID_TEXT_DRAW)
                        TextDrawShowForPlayer(playerid, i);
            }
            case CW_STATE_RUNNING: // Running map
            {
                Player[playerid][Spectating] = true;
                TogglePlayerSpectating(playerid, true);

                for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
                    if (i != Text:INVALID_TEXT_DRAW)
                        TextDrawShowForPlayer(playerid, i);

                for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
                    if (i != Text:INVALID_TEXT_DRAW)
                        TextDrawShowForPlayer(playerid, i);
            }
        }
    }
    else if (oldmode == this)
    {
        PlayerModeData[playerid][Team] = 0;
        HideFadeTextdrawForPlayer(playerid, this);

        if (Player[playerid][MusicType] == 1)
        {
            StopAudioStreamForPlayer(playerid);
            Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
            DeletePVar(playerid, "audio.stream");
        }

        if (PlayerModeData[playerid][IsAlive])
            AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick], false);

        Player[playerid][Spectating] = false;
        DisableRemoteVehicleCollisions(playerid, false);

        for (new a; a < sizeof(Deathlist); a++)
            for (new b; b < sizeof(Deathlist[]); b++)
                TextDrawHideForPlayer(playerid, Deathlist[a][b]);

        for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
            if (i != Text:INVALID_TEXT_DRAW)
                TextDrawHideForPlayer(playerid, i);

        for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
            if (i != Text:INVALID_TEXT_DRAW)
                TextDrawHideForPlayer(playerid, i);

        UpdateCWInfoTextdrawData();
    }
    return true;
}

Hook:CW_OnGameModeExit()
{
	if (ModeData[Map][0] != EOS)
		SendRconCommandf("unloadfs ../maps/%s", ModeData[Map]);
	return true;
}

Hook:CW_OnPlayerDisconnect(playerid, reason)
{
    PlayerModeData[playerid][Team] = 0;
}

task Clanwar[500]()
{
	if (!Modes[this][Players])
		return false;

	if (ModeData[RoundState] == ROUND_STATE_ONGOING)
	{
	    new teamAPlayersAlive, teamBPlayersAlive;

        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 1 && Player[i][ModeID] == this && PlayerModeData[i][IsAlive])
                teamAPlayersAlive++;
            else if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 2 && Player[i][ModeID] == this && PlayerModeData[i][IsAlive])
                teamBPlayersAlive++;
        }

        if ((teamAPlayersAlive > 0 && !teamBPlayersAlive) || (teamBPlayersAlive > 0 && !teamAPlayersAlive))
        {
            new teamRoundVictory;

            if (teamAPlayersAlive > 0 && !teamBPlayersAlive)
            {
                teamRoundVictory = 1;
                SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s has won the round!", ModeData[Team_A]);
            }
            else
            {
                teamRoundVictory = 2;
                SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s has won the round!", ModeData[Team_B]);
            }

            GiveTeamVictory(teamRoundVictory);

            FadeMode(this, true);
            SetTimer("DelayedKillAll", 3800, false);
            ModeData[RoundState] = ROUND_STATE_LOADING; // Loop fix
            SetTimerEx("EndRound", 4500, false, "i", this);
        }

		new string[16];
		format(string, sizeof(string), "~w~%s", Tick(GetTickCount() - ModeData[StartTick], false));
		TextDrawSetString(ModeData[MainTime], string);

		for (new playerid,j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this)
				continue;
			if (IsPlayerInAnyVehicle(playerid) && GetVehicleModelGroup(GetVehicleModel(GetPlayerVehicleID(playerid))) != VEHICLE_GROUP_BOAT)
			{
				new Float:X,Float:Y,Float:Z;
				GetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
				if (Z < 0.0 && Z > -5.0)
				{
					AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
					continue;
				}
			}
			if (!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && PlayerModeData[playerid][IsAlive])
			{
				AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
				continue;
			}
		}
	}
	else if (!ModeData[Alive] && ModeData[RoundState] == ROUND_STATE_ONGOING)
	{
        // last player died within task-interval

        new winnerTeam = PlayerModeData[ModeData[LastDead]][Team];

        if (winnerTeam == 1)
            SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] %s has won the round!", ModeData[Team_A]);
        else
            SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] %s has won the round!", ModeData[Team_B]);

        GiveTeamVictory(winnerTeam);

        FadeMode(this, true);
        SetTimer("DelayedKillAll", 3800, false);
        ModeData[RoundState] = ROUND_STATE_LOADING; // Loop fix
        SetTimerEx("EndRound", 4500, false, "i", this);
	}
	return true;
}

CMD:cw(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;
    new text[256];
    if (ModeData[ModeState] == CW_STATE_SETUP)
        strcat(text, ""#EMB_COL_LIGHTRED"Start map\n \n");
    else if (ModeData[ModeState] == CW_STATE_IDLE)
        strcat(text, ""#EMB_COL_PALLIDGREEN"Start map\n \n");
    else if (ModeData[ModeState] == CW_STATE_RUNNING)
        strcat(text, ""#EMB_COL_LIGHTRED"End map\n \n");

    strcat(text, "{FFFFFF}Edit Team A\n{FFFFFF}Edit Team B\n \n");

    if (ModeData[ModeState] == CW_STATE_SETUP)
        strcat(text, ""#EMB_COL_PALLIDGREEN"Start Clanwar");
    else
        strcat(text, ""#EMB_COL_LIGHTRED"End Clanwar");

    ShowPlayerDialog(playerid, DIALOG_CW_MAIN_VIEW, DIALOG_STYLE_LIST, "Clanwar", text, "Select", "Abort");
    return true;
}
flags:cw(CMD_TRIAL_MODERATOR);

CMD:cwassign(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    new target, team;
    if (sscanf(params, "ui", target, team) || (team != 0 && team != 1)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/cwassign [player] [0 = Team A | 1 = Team B]");

    if (IsPlayerConnected(target) && Player[target][IsLoggedIn])
    {
        new teamChar;
        if (team == 0)
            teamChar = 'A';
        else
            teamChar = 'B';

        PlayerModeData[target][Team] = team + 1;
        SendClientMessagef(playerid, COL_GREEN, "[CLANWAR] {FFFFFF}%s has been assigned to Team %c.", Player[target][Name], teamChar);
        SendClientMessage(target, COL_INFORMATION, "[CLANWAR] {FFFFFF}You have been assigned to your team.");
    }
    else
        SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Player is not online.");

    return true;
}
flags:cwassign(CMD_TRIAL_MODERATOR);

CMD:cwunassign(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    new target;
    if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/cwunassign [player]");

    if (IsPlayerConnected(target) && Player[target][IsLoggedIn] && PlayerModeData[target][Team] != 0)
    {
        PlayerModeData[target][Team] = 0;

        SendClientMessagef(playerid, COL_GREEN, "[CLANWAR] {FFFFFF}%s has been removed from the team.", Player[target][Name]);
        SendClientMessage(target, COL_INFORMATION, "[CLANWAR] {FFFFFF}You have been removed from the team.");
    }
    else
        SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Player is not assigned to a team.");

    return true;
}
flags:cwunassign(CMD_TRIAL_MODERATOR);

CMD:cwsetmap(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    if (ModeData[ModeState] != CW_STATE_IDLE && ModeData[RoundState] != ROUND_STATE_LOADING) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Another map is currently being played or you didn't start the clanwar yet.");

    if (CountTeamPlayers(1) < 1 || CountTeamPlayers(2) < 1) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Every team must have at least 1 player assigned.");

    new mapname[128], rounds;
    if (sscanf(params, "is[128]", rounds, mapname)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/cwsetmap [rounds] [(part of) name / author(s)]");

    if (rounds < 1)
        rounds = 1;

    new query[256];
    SetPVarInt(playerid, "cwsetmap_rounds", rounds);
    mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE (strMode = 'DM' OR strMode = 'DD' OR strMode = 'EDM') AND (strMapAuthor LIKE '%%%e%%' OR strMapName LIKE '%%%e%%')", mapname, mapname);
    mysql_pquery(g_Sql, query, "OnCWMapSearch", "i", playerid);

    return true;
}
flags:cwsetmap(CMD_TRIAL_MODERATOR);

CMD:cwgivepoint(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    if (ModeData[ModeState] != CW_STATE_IDLE) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The clanwar didn't start yet.");

    new team;
    if (sscanf(params, "i", team) || (team != 0 && team != 1)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/cwgivepoint [0 = Team A | 1 = Team B]");

    GiveTeamVictory(team + 1);

    return true;
}
flags:cwgivepoint(CMD_TRIAL_MODERATOR);

CMD:cwremovepoint(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    if (ModeData[ModeState] != CW_STATE_IDLE) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The clanwar didn't start yet.");

    new team;
    if (sscanf(params, "i", team) || (team != 0 && team != 1)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/cwremovepoint [0 = Team A | 1 = Team B]");

    RemoveTeamVictory(team + 1);

    return true;
}
flags:cwremovepoint(CMD_TRIAL_MODERATOR);

CMD:t(playerid, params[])
{
    if (Player[playerid][ModeID] != this) return false;

    if (PlayerModeData[playerid][Team] == 0) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You are not assigned to a team.");

    new text[128];
    if (sscanf(params, "s[128]", text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/t [text]");

    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && (PlayerModeData[i][Team] == PlayerModeData[playerid][Team] || PlayerModeData[i][Team] == 0 && Player[playerid][AdminLevel]) && Player[i][ModeID] == this)
        {
            SendClientMessagef(i, COL_LIGHTGREY, "[CW | TEAMCHAT] {%06x}%s (%d): {FFFFFF}%s", GetPlayerColor(playerid) >>> 8, Player[playerid][Name], playerid, text);
        }
    }

    return true;
}

CMD:cwinfo(playerid, params[])
{
    new text[736]; // Calculated with 10vs10, + 256 normal chars
    strcat(text, "{FFFFFF}Status: ");

    switch(ModeData[ModeState])
    {
        case CW_STATE_SETUP:
        {
            strcat(text, ""#EMB_COL_INFORMATION"Setting up{FFFFFF}");
        }

        case CW_STATE_IDLE:
        {
            strcat(text, ""#EMB_COL_ORANGE"Idle{FFFFFF}");
        }

        case CW_STATE_RUNNING:
        {
            strcat(text, ""#EMB_COL_GREEN"Ongoing{FFFFFF}");
        }
    }

    strcat(text, "\n\nTeam A");

    if (ModeData[Team_A][0] != EOS)
    {
        new teamAString[15];
        format(teamAString, sizeof(teamAString), " (%s):\n", ModeData[Team_A]);
        strcat(text, teamAString);

        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 1 && Player[i][ModeID] == this)
            {
                new playerName[MAX_PLAYER_NAME + 1];
                format(playerName, sizeof(playerName), "%s ", Player[i][Name]);
                strcat(text, playerName);
            }
        }
    }
    else
        strcat(text, ":\n"#EMB_COL_LIGHTRED"Not yet set up.{FFFFFF}");

    strcat(text, "\n\nTeam B");

    if (ModeData[Team_B][0] != EOS)
    {
        new teamBString[15];
        format(teamBString, sizeof(teamBString), " (%s):\n", ModeData[Team_B]);
        strcat(text, teamBString);

        for (new i, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 2 && Player[i][ModeID] == this)
            {
                new playerName[MAX_PLAYER_NAME + 1];
                format(playerName, sizeof(playerName), "%s ", Player[i][Name]);
                strcat(text, playerName);
            }
        }
    }
    else
        strcat(text, ":\n"#EMB_COL_LIGHTRED"Not yet set up.{FFFFFF}");

    ShowPlayerDialog(playerid, DIALOG_NO_RESPONSE, DIALOG_STYLE_MSGBOX, "Clanwar Information", text, "OK", "");

    return true;
}

Hook:CW_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (Player[playerid][ModeID] == this)
    {
        switch (dialogid)
        {
            case DIALOG_CW_MAIN_VIEW:
            {
                if (response)
                {
                    switch (listitem)
                    {
                        case 0: // "Start map" or "End map"
                        {
                            if (ModeData[ModeState] == CW_STATE_SETUP)
                            {
                                PC_EmulateCommand(playerid, "/cw");
                                SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You first need to start the clanwar before starting a map.");
                            }
                            else if (ModeData[ModeState] == CW_STATE_IDLE)
                            {
                                if (ModeData[MapRoundsLeft]) return PC_EmulateCommand(playerid, "/cw");

                                if (CountTeamPlayers(1) < 1 || CountTeamPlayers(2) < 1)
                                {
                                    SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Every team must have at least 1 player assigned.");
                                    return PC_EmulateCommand(playerid, "/cw");
                                }

                                ShowPlayerDialog(playerid, DIALOG_CW_START_MAP, DIALOG_STYLE_INPUT, "Clanwar >> Start map", "(Part of) Mapname / author(s):", "Set", "Abort");
                            }
                            else if (ModeData[ModeState] == CW_STATE_RUNNING)
                            {
                                if (ModeData[RoundState] == ROUND_STATE_ONGOING)
                                {
                                    SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}The map has been stopped by an administrator.");
                                    ModeData[MapRoundsLeft] = 0;
                                    FadeMode(this, true);
                                    SetTimerEx("EndRound", 4500, false, "i", this);
                                }
                            }
                        }
                        case 2: // "Edit Team A"
                        {
                            ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A, DIALOG_STYLE_MSGBOX, "Clanwar >> Team A", "Would you like to select a clan or use a custom clan tag?", "Select Clan", "Custom Clan");
                        }
                        case 3: // "Edit Team B"
                        {
                            ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B, DIALOG_STYLE_MSGBOX, "Clanwar >> Team B", "Would you like to select a clan or use a custom clan tag?", "Select Clan", "Custom Clan");
                        }
                        case 5: // "Start Clanwar" or "End Clanwar"
                        {
                            if (ModeData[ModeState] == CW_STATE_SETUP)
                            {
                                ModeData[ModeState] = CW_STATE_IDLE;
                                for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                                {
                                    if (IsPlayerConnected(i) && Player[i][ModeID] == this)
                                    {
                                        TextDrawShowForPlayer(i, SKEW_BANNER);
                                        PlayerTextDrawSetString(i, SKEW_BANNER_TEXT_CB[i], "~g~ Clanwar is live!");
                                        PlayerTextDrawShow(i, SKEW_BANNER_TEXT_CB[i]);
                                    }
                                }

                                UpdateCWInfoTextdrawData();

                                for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
                                    if (i != Text:INVALID_TEXT_DRAW)
                                        TextDrawShowForPlayer(playerid, i);

                                // TODO Broadcast message across the server that a clanwar is ongoing? (maybe when spectating is on?)
                                PC_EmulateCommand(playerid, "/cw");
                            }
                            else
                            {
                                if (ModeData[ModeState] == CW_STATE_RUNNING)
                                    return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The map needs to end first, before you can end a clanwar.");

                                if (ModeData[Team_A_Score] > ModeData[Team_B_Score])
                                {
                                    SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}Final result: %s %i : %i %s. %s has won the clanwar!", ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B], ModeData[Team_A]);
                                }
                                else if (ModeData[Team_B_Score] > ModeData[Team_A_Score])
                                {
                                    SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}Final result: %s %i : %i %s. %s has won the clanwar!", ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B], ModeData[Team_B]);
                                }
                                else if (ModeData[Team_A_Score] == ModeData[Team_B_Score])
                                {
                                    SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}Final result: %s %i : %i %s. The clanwar ended in a tie!", ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B]);
                                }

                                // TODO GIVE CLAN POINTS, BROADCAST IT ACROSS THE WHOLE SERVER?

                                ModeData[ModeState] = CW_STATE_SETUP;
                                format(ModeData[Team_A], sizeof(ModeData[Team_A]), "");
                                format(ModeData[Team_B], sizeof(ModeData[Team_B]), "");
                                RemoveAllFromTeam(1);
                                RemoveAllFromTeam(2);
                                ModeData[Team_A_Score] = 0;
                                ModeData[Team_B_Score] = 0;
                                ModeData[Team_A_Related_Clan_ID] = -1;
                                ModeData[Team_B_Related_Clan_ID] = -1;
                                TextDrawSetString(Modes[this][AliveCountTextDraw], "~y~Score~w~~n~0:0");

                                UpdateCWInfoTextdrawData();

                                for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                                {
                                    if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && Player[i][ModeID] == this)
                                    {
                                        TextDrawShowForPlayer(i, SKEW_BANNER);
                                        PlayerTextDrawSetString(i, SKEW_BANNER_TEXT_CB[i], "~y~no active clanwar");
                                        PlayerTextDrawShow(i, SKEW_BANNER_TEXT_CB[i]);

                                        if (Player[i][MusicType] == 1)
                                        {
                                            StopAudioStreamForPlayer(i);
                                            Audio_Stop(i, GetPVarInt(i, "audio.stream"));
                                            DeletePVar(i, "audio.stream");
                                        }

                                        for (new Text:a = ModeData[CWInfoFirst]; a <= ModeData[CWInfoTeamBPlayers]; a++)
                                            if (a != Text:INVALID_TEXT_DRAW)
                                                TextDrawHideForPlayer(playerid, a);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // SETUP A
            case DIALOG_CW_SETUP_A:
            {
                if (response) // Select Clan
                {
                    RemoveAllFromTeam(1);

                    new text[256];
                    for (new i; i < MAX_CLANS; i++)
                    {
                        if (Clans[i][Name][0] != EOS && IsSomeoneFromClanConnected(i))
                        {
                            new clanNameString[MAX_CLAN_NAME];
                            format(clanNameString, sizeof(clanNameString), "%s\n", Clans[i][Name]);
                            strcat(text, clanNameString);
                        }
                    }

                    if (text[0] == EOS)
                        SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}There are no clans available to choose from.");
                    else
                        ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_AUTO, DIALOG_STYLE_LIST, "Clanwar >> Team A", text, "Select", "Abort");

                    UpdateCWInfoTextdrawData();
                }
                else // Custom Clan
                {
                    ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_MANUAL, DIALOG_STYLE_INPUT, "Clanwar >> Team A", "Enter the clan tag.", "OK", "Abort");
                }
            }

            case DIALOG_CW_SETUP_A_AUTO:
            {
                if (response)
                {
                    ModeData[Team_A_Related_Clan_ID] = GetClanIDByName(inputtext);
                    format(ModeData[Team_A], MAX_CLAN_NAME, "%s", Clans[ModeData[Team_A_Related_Clan_ID]][Tag]);

                    new text[512];
                    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                    {
                        if (IsPlayerConnected(i) && GetPlayerClanInternalID(Player[i][ClanID]) == ModeData[Team_A_Related_Clan_ID] && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0 && Player[i][ModeID] == this)
                        {
                            new playerName[MAX_PLAYER_NAME + 2];
                            format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
                            strcat(text, playerName);
                        }
                    }

                    if (text[0] == EOS)
                         PC_EmulateCommand(playerid, "/cw");
                    else
                        ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_AUTO_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team A", text, "Assign", "Finish");

                    UpdateCWInfoTextdrawData();
                }
                else
                {
                    PC_EmulateCommand(playerid, "/cw");
                }
            }

            case DIALOG_CW_SETUP_A_AUTO_PLAYER:
            {
                if (response)
                {
                    new commandString[16];
                    format(commandString, sizeof(commandString), "/cwassign %i %i", GetPlayerID(inputtext), 0);
                    PC_EmulateCommand(playerid, commandString);

                    new text[512];
                    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                    {
                        if (IsPlayerConnected(i) && GetPlayerClanInternalID(Player[i][ClanID]) == ModeData[Team_A_Related_Clan_ID] && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
                        {
                            new playerName[MAX_PLAYER_NAME + 2];
                            format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
                            strcat(text, playerName);
                        }
                    }

                    if (text[0] == EOS)
                         PC_EmulateCommand(playerid, "/cw");
                    else
                        ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_AUTO_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team A", text, "Assign", "Finish");

                    UpdateCWInfoTextdrawData();
                }
                else
                {
                    PC_EmulateCommand(playerid, "/cw");
                }
            }

            case DIALOG_CW_SETUP_A_MANUAL:
            {
                if (response)
                {
                    ModeData[Team_A_Related_Clan_ID] = -1;
                    format(ModeData[Team_A], MAX_CLAN_NAME, "%s", inputtext);

                    new text[512];
                    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                    {
                        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
                        {
                            new playerName[MAX_PLAYER_NAME + 2];
                            format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
                            strcat(text, playerName);
                        }
                    }

                    if (text[0] == EOS)
                         PC_EmulateCommand(playerid, "/cw");
                    else
                        ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_MANUAL_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team A", text, "Assign", "Finish");

                    UpdateCWInfoTextdrawData();
                }
                else
                {
                    PC_EmulateCommand(playerid, "/cw");
                }
            }

            case DIALOG_CW_SETUP_A_MANUAL_PLAYER:
            {
                if (response)
                {
                    new commandString[16];
                    format(commandString, sizeof(commandString), "/cwassign %i %i", GetPlayerID(inputtext), 0);
                    PC_EmulateCommand(playerid, commandString);

                    new text[512];
                    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
                    {
                        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
                        {
                            new playerName[MAX_PLAYER_NAME + 2];
                            format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
                            strcat(text, playerName);
                        }
                    }

                    if (text[0] == EOS)
                         PC_EmulateCommand(playerid, "/cw");
                    else
                        ShowPlayerDialog(playerid, DIALOG_CW_SETUP_A_MANUAL_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team A", text, "Assign", "Finish");

                    UpdateCWInfoTextdrawData();
                }
                else
                {
                    PC_EmulateCommand(playerid, "/cw");
                }
            }

            // SETUP B
            case DIALOG_CW_SETUP_B:
            {
            	if (response) // Select Clan
            	{
            	    RemoveAllFromTeam(2);

            		new text[256];
            		for (new i; i < MAX_CLANS; i++)
            		{
            			if (Clans[i][Name][0] != EOS && IsSomeoneFromClanConnected(i))
            			{
            				new clanNameString[MAX_CLAN_NAME];
            				format(clanNameString, sizeof(clanNameString), "%s\n", Clans[i][Name]);
            				strcat(text, clanNameString);
            			}
            		}

            		if (text[0] == EOS)
            			SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}There are no clans available to choose from.");
            		else
            			ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_AUTO, DIALOG_STYLE_LIST, "Clanwar >> Team B", text, "Select", "Abort");

            		UpdateCWInfoTextdrawData();
            	}
            	else // Custom Clan
            	{
            		ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_MANUAL, DIALOG_STYLE_INPUT, "Clanwar >> Team B", "Enter the clan tag.", "OK", "Abort");
            	}
            }

            case DIALOG_CW_SETUP_B_AUTO:
            {
            	if (response)
            	{
            		ModeData[Team_B_Related_Clan_ID] = GetClanIDByName(inputtext);
            		format(ModeData[Team_B], MAX_CLAN_NAME, "%s", Clans[ModeData[Team_B_Related_Clan_ID]][Tag]);

            		new text[512];
            		for (new i, j = GetPlayerPoolSize(); i <= j; i++)
            		{
            			if (IsPlayerConnected(i) && GetPlayerClanInternalID(Player[i][ClanID]) == ModeData[Team_B_Related_Clan_ID] && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0 && Player[i][ModeID] == this)
            			{
            				new playerName[MAX_PLAYER_NAME + 2];
            				format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
            				strcat(text, playerName);
            			}
            		}

            		if (text[0] == EOS)
            			 PC_EmulateCommand(playerid, "/cw");
            		else
            			ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_AUTO_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team B", text, "Assign", "Finish");

            		UpdateCWInfoTextdrawData();
            	}
            	else
            	{
            		PC_EmulateCommand(playerid, "/cw");
            	}
            }

            case DIALOG_CW_SETUP_B_AUTO_PLAYER:
            {
            	if (response)
            	{
            		new commandString[16];
            		format(commandString, sizeof(commandString), "/cwassign %i %i", GetPlayerID(inputtext), 1);
            		PC_EmulateCommand(playerid, commandString);

            		new text[512];
            		for (new i, j = GetPlayerPoolSize(); i <= j; i++)
            		{
            			if (IsPlayerConnected(i) && GetPlayerClanInternalID(Player[i][ClanID]) == ModeData[Team_B_Related_Clan_ID] && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
            			{
            				new playerName[MAX_PLAYER_NAME + 2];
            				format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
            				strcat(text, playerName);
            			}
            		}

            		if (text[0] == EOS)
            			 PC_EmulateCommand(playerid, "/cw");
            		else
            			ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_AUTO_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team B", text, "Assign", "Finish");

            		UpdateCWInfoTextdrawData();
            	}
            	else
            	{
            		PC_EmulateCommand(playerid, "/cw");
            	}
            }

            case DIALOG_CW_SETUP_B_MANUAL:
            {
            	if (response)
            	{
            		ModeData[Team_B_Related_Clan_ID] = -1;
            		format(ModeData[Team_B], MAX_CLAN_NAME, "%s", inputtext);

            		new text[512];
            		for (new i, j = GetPlayerPoolSize(); i <= j; i++)
            		{
            			if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
            			{
            				new playerName[MAX_PLAYER_NAME + 2];
            				format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
            				strcat(text, playerName);
            			}
            		}

            		if (text[0] == EOS)
            			 PC_EmulateCommand(playerid, "/cw");
            		else
            			ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_MANUAL_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team B", text, "Assign", "Finish");

            		UpdateCWInfoTextdrawData();
            	}
            	else
            	{
            		PC_EmulateCommand(playerid, "/cw");
            	}
            }

            case DIALOG_CW_SETUP_B_MANUAL_PLAYER:
            {
            	if (response)
            	{
            		new commandString[16];
            		format(commandString, sizeof(commandString), "/cwassign %i %i", GetPlayerID(inputtext), 1);
            		PC_EmulateCommand(playerid, commandString);

            		new text[512];
            		for (new i, j = GetPlayerPoolSize(); i <= j; i++)
            		{
            			if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 0  && Player[i][ModeID] == this)
            			{
            				new playerName[MAX_PLAYER_NAME + 2];
            				format(playerName, sizeof(playerName), "%s\n", Player[i][Name]);
            				strcat(text, playerName);
            			}
            		}

            		if (text[0] == EOS)
            			 PC_EmulateCommand(playerid, "/cw");
            		else
            			ShowPlayerDialog(playerid, DIALOG_CW_SETUP_B_MANUAL_PLAYER, DIALOG_STYLE_LIST, "Clanwar >> Team B", text, "Assign", "Finish");

            		UpdateCWInfoTextdrawData();
            	}
            	else
            	{
            		PC_EmulateCommand(playerid, "/cw");
            	}
            }

            case DIALOG_CW_START_MAP:
            {
                if (response)
                {
                    if (inputtext[0] != EOS)
                    {
                        new cwsetmapCommand[128];
                        format(cwsetmapCommand, sizeof(cwsetmapCommand), "/cwsetmap %i %s", 3, inputtext);
                        PC_EmulateCommand(playerid, cwsetmapCommand);
                    }
                    else
                    {
                        PC_EmulateCommand(playerid, "/cw");
                    }
                }
                else
                {
                    PC_EmulateCommand(playerid, "/cw");
                }
            }

            case DIALOG_CW_START_MAP_SELECT:
            {
                if (response)
                {
                    new query[128], inputval = strval(inputtext);
                    mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE uid = '%d'", inputval);
                    mysql_pquery(g_Sql, query, "OnCWMapSearch", "i", playerid);
                }
            }
        }
    }
    return true;
}

Hook:CW_LoadMap(gamemodeid)
{
	if (gamemodeid == this)
	{
		if (cache_num_rows())
		{
		    ModeData[ModeState] = CW_STATE_RUNNING;

			cache_get_value_name_int(0, "uid", ModeData[MapID]);
			cache_get_value_name(0, "strFilePointer", ModeData[Map], 256);

			for (new a; a < sizeof(Deathlist); a++)
				for (new b; b < sizeof(Deathlist[]); b++)
				{
					TextDrawHideForAll(Deathlist[a][b]);
					TextDrawSetString(Deathlist[a][b], " ");
				}

            for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
                for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
                    if (i != Text:INVALID_TEXT_DRAW)
                        TextDrawShowForPlayer(playerid, i);

			new author[64], name[128], string[255];
			cache_get_value(0, "strMapName", name);
			cache_get_value(0, "strMapAuthor", author);
			format(string, sizeof(string), "~w~~>~ %s - %s", author, name);
			TextDrawSetString(ModeData[MainMap], string);
		}
		else ModeData[RoundState] = ROUND_STATE_COUNTDOWN;
        // TODO ? ^

		UpdateCWInfoTextdrawData();
	}
	return true;
}

Hook:CW_CreateModeSpawnpoint(modelid,Float:X,Float:Y,Float:Z,Float:rZ,gamemodeid)
{
	if (gamemodeid == this)
		ModeData[Spawns]++;
	return true;
}

Hook:CW_InitiatePlayerSpawns(gamemodeid)
{
	if (gamemodeid == this)
	{
		RevertFade(this);
        ModeData[VW_Counter] = 0;

		TextDrawSetString(ModeData[MainTime], "~w~00:00");
		ModeData[RoundState] = ROUND_STATE_SPAWNED;
		for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
		{
			if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != this)
				continue;

            TextDrawHideForPlayer(playerid, SKEW_BANNER);
		    PlayerTextDrawHide(playerid, SKEW_BANNER_TEXT_CB[playerid]);

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

		    if (Player[playerid][ModeID] == this && PlayerModeData[playerid][Team] == 0)
		    {
		        PlayerModeData[playerid][IsAlive] = false;
		        SetCameraBehindPlayer(playerid);
                Player[playerid][Spectating] = true;
                TogglePlayerSpectating(playerid, true);

                continue;
		    }

			Player[playerid][Spectating] = false;
			TogglePlayerSpectating(playerid, false);
			TogglePlayerControllable(playerid, true);
			SetPlayerSpawn(playerid);
		}
	}
	return true;
}

Hook:CW_OnCountDownStateChange(gamemodeid,cdstate)
{
	if (gamemodeid == this)
	{
		switch (cdstate)
		{
			case 0:
			{
				ModeData[RoundState] = ROUND_STATE_ONGOING;
				ModeData[StartTick] = GetTickCount();
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
				ModeData[RoundState] = ROUND_STATE_COUNTDOWN;
			}
		}
	}
	return true;
}

Hook:CW_EndRound(gamemodeid)
{
	if(gamemodeid == this)
	{
        ModeData[ModeState] = CW_STATE_IDLE;
        ModeData[RoundState] = ROUND_STATE_LOADING;
        ModeData[Spawns] = 0;
        ModeData[TotalAlive] = 0;
        ModeData[Alive] = 0;

        UnloadMap(this);
        if (ModeData[Map][0] != EOS)
			SendRconCommandf("unloadfs ../maps/%s", ModeData[Map]);

		for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
        {
            if (IsPlayerConnected(playerid) && Player[playerid][IsLoggedIn] && Player[playerid][ModeID] == this && Player[playerid][MusicType] == 1)
            {
                StopAudioStreamForPlayer(playerid);
                Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
                DeletePVar(playerid, "audio.stream");
            }
        }

		if (--ModeData[MapRoundsLeft] > 0)
		{
            new query[128];
            mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE uid = '%d'", ModeData[MapID]);
            mysql_pquery(g_Sql, query, "LoadMap", "i", this);
		}
		else
		{
		    ModeData[MapRoundsLeft] = 0; // Just to be sure

            for (new Text:i = ModeData[MainFirst]; i <= ModeData[MainLast]; i++)
                if (i != Text:INVALID_TEXT_DRAW)
                    TextDrawHideForAll(i);
		}

		UpdateCWInfoTextdrawData();
	}
	return true;
}

Hook:CW_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (Player[playerid][ModeID] == this)
	{
		if (newkeys & 16 && PlayerModeData[playerid][IsAlive])
			AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);

		if (newkeys & KEY_SUBMISSION)
        {
            if (IsTextDrawVisibleForPlayer(playerid, ModeData[CWInfoFirst]))
            {
                for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
                    TextDrawHideForPlayer(playerid, i);
            }

            else
            {
                for (new Text:i = ModeData[CWInfoFirst]; i <= ModeData[CWInfoTeamBPlayers]; i++)
                    TextDrawShowForPlayer(playerid, i);
            }
        }
        if ((ModeData[RoundState] == ROUND_STATE_SPAWNED || ModeData[RoundState] == ROUND_STATE_COUNTDOWN) && IsPlayerInAnyVehicle(playerid))
		{
			if (newkeys & KEY_ANALOG_RIGHT)
			{
				for (new areaid = GetPVarInt(playerid, "currentSpawnID") + 1, k = Streamer_GetUpperBound(STREAMER_TYPE_AREA); areaid <= k; areaid++)
				{
					if (!IsValidDynamicArea(areaid) || Streamer_GetIntData(STREAMER_TYPE_AREA,areaid,E_STREAMER_TYPE) != STREAMER_AREA_TYPE_SPHERE)
						continue;
					new ArrayData[5];
					Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
					if (ArrayData[0] != AREA_TYPE_SPAWNPOINT || ArrayData[1] != this)
						continue;
					new Float:X,Float:Y,Float:Z,Float:rZ = Float:ArrayData[3];
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_X, X);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Y, Y);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Z, Z);
					SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
					SetVehicleZAngle(GetPlayerVehicleID(playerid), rZ);
                    SetVehicleSpawnInfo(GetPlayerVehicleID(playerid), GetVehicleModel(GetPlayerVehicleID(playerid)), X, Y, Z, rZ, Player[playerid][CarColor1], Player[playerid][CarColor2]);
					SetCameraBehindPlayer(playerid);
					SetPVarInt(playerid, "currentSpawnID", areaid);
					break;
				}
			}
			if (newkeys & KEY_ANALOG_LEFT)
			{
				for (new areaid = GetPVarInt(playerid, "currentSpawnID") - 1; areaid >= 0; areaid--)
				{
					if (!IsValidDynamicArea(areaid) || Streamer_GetIntData(STREAMER_TYPE_AREA,areaid,E_STREAMER_TYPE) != STREAMER_AREA_TYPE_SPHERE)
						continue;
					new ArrayData[5];
					Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, ArrayData);
					if (ArrayData[0] != AREA_TYPE_SPAWNPOINT || ArrayData[1] != this)
						continue;
					new Float:X,Float:Y,Float:Z,Float:rZ = Float:ArrayData[3];
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_X, X);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Y, Y);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_Z, Z);
					SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
					SetVehicleZAngle(GetPlayerVehicleID(playerid), rZ);
                    SetVehicleSpawnInfo(GetPlayerVehicleID(playerid), GetVehicleModel(GetPlayerVehicleID(playerid)), X, Y, Z, rZ, Player[playerid][CarColor1], Player[playerid][CarColor2]);
					SetCameraBehindPlayer(playerid);
					SetPVarInt(playerid, "currentSpawnID", areaid);
					break;
				}
			}
		}
	}
	return true;
}

RemoveAllFromTeam(teamID)
{
    if (teamID != 1 && teamID != 2)
        return true;

    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (PlayerModeData[i][Team] == teamID)
            PlayerModeData[i][Team] = 0;
    }

    UpdateCWInfoTextdrawData();

    return true;
}

GiveTeamVictory(teamID)
{
    if (teamID != 1 && teamID != 2)
        return true;

    if (teamID == 1)
    {
        ModeData[Team_A_Score]++;
        SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s received 1 point. Current score: %s %i : %i %s", ModeData[Team_A], ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B]);
    }
    else
    {
        ModeData[Team_B_Score]++;
        SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s received 1 point. Current score: %s %i : %i %s", ModeData[Team_B], ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B]);
    }

    new string[25];
    format(string, sizeof(string), "~y~Score~w~~n~%i:%i", ModeData[Team_A_Score], ModeData[Team_B_Score]);
    TextDrawSetString(Modes[this][AliveCountTextDraw], string);
    UpdateCWInfoTextdrawData();

    return true;
}

RemoveTeamVictory(teamID)
{
    if (teamID != 1 && teamID != 2)
        return true;

    if (teamID == 1)
    {
        ModeData[Team_A_Score]--;
        SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s has got 1 point deducted. Current score: %s %i : %i %s", ModeData[Team_A], ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B]);
    }
    else
    {
        ModeData[Team_B_Score]--;
        SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}%s has got 1 point deducted. Current score: %s %i : %i %s", ModeData[Team_B], ModeData[Team_A], ModeData[Team_A_Score], ModeData[Team_B_Score], ModeData[Team_B]);
    }

    new string[25];
    format(string, sizeof(string), "~y~Score~w~~n~%i:%i", ModeData[Team_A_Score], ModeData[Team_B_Score]);
    TextDrawSetString(Modes[this][AliveCountTextDraw], string);
    UpdateCWInfoTextdrawData();

    return true;
}

UpdateCWInfoTextdrawData()
{
    new string[64];
    format(string, sizeof(string), "~y~%s", ModeData[Team_A]);
    TextDrawSetString(ModeData[CWInfoTeamA], string);
    format(string, sizeof(string), "~y~%s", ModeData[Team_B]);
    TextDrawSetString(ModeData[CWInfoTeamB], string);
    format(string, sizeof(string), "~w~%i", ModeData[Team_A_Score]);
    TextDrawSetString(ModeData[CWInfoTeamAScore], string);
    format(string, sizeof(string), "~w~%i", ModeData[Team_B_Score]);
    TextDrawSetString(ModeData[CWInfoTeamBScore], string);

    new teamAPlayers[550];
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 1 && Player[i][ModeID] == this)
        {
            new playerName[MAX_PLAYER_NAME + 7];

            if (PlayerModeData[i][IsAlive])
                format(playerName, sizeof(playerName), "~w~%s~n~", Player[i][Name]);
            else
                format(playerName, sizeof(playerName), "~r~%s~n~", Player[i][Name]);

            strcat(teamAPlayers, playerName);
        }
    }
    TextDrawSetString(ModeData[CWInfoTeamAPlayers], teamAPlayers);

    new teamBPlayers[550];
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == 2 && Player[i][ModeID] == this)
        {
            new playerName[MAX_PLAYER_NAME + 7];

            if (PlayerModeData[i][IsAlive])
                format(playerName, sizeof(playerName), "~w~%s~n~", Player[i][Name]);
            else
                format(playerName, sizeof(playerName), "~r~%s~n~", Player[i][Name]);

            strcat(teamBPlayers, playerName);
        }
    }
    TextDrawSetString(ModeData[CWInfoTeamBPlayers], teamBPlayers);

    format(string, sizeof(string), "~w~Rounds left: ~y~%i", ModeData[MapRoundsLeft]);
    TextDrawSetString(ModeData[CWInfoRoundsLeft], string);

    return true;
}

CountTeamPlayers(teamID)
{
    if (teamID != 1 && teamID != 2)
        return true;

    new count;

    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
        if (IsPlayerConnected(i) && Player[i][IsLoggedIn] && PlayerModeData[i][Team] == teamID && Player[i][ModeID] == this)
            count++;

    return count;
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
			SetPlayerVirtualWorld(playerid,VirtualWorlds[this][ModeData[VW_Counter]]);
			SetVehicleVirtualWorld(vehicleid,VirtualWorlds[this][ModeData[VW_Counter]]);
			PutPlayerInVehicle(playerid, vehicleid, 0);
			SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
            SetPVarInt(playerid, "currentSpawnID", areaid);
            ModeData[VW_Counter]++;
            if (ModeData[VW_Counter] == sizeof(VirtualWorlds[]) - 1)
                ModeData[VW_Counter] = 0;
			break;
		}
		c++;
	}
	ModeData[Alive]++;
	ModeData[TotalAlive]++;
	PlayerModeData[playerid][IsAlive] = true;

	UpdateCWInfoTextdrawData();
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

	if (ModeData[Alive] == 1)
	{
		ModeData[LastDead] = playerid;
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

	ModeData[Alive]--;
	PlayerModeData[playerid][IsAlive] = false;

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

	UpdateCWInfoTextdrawData();
	return true;
}

forward DelayedKillAll();
public DelayedKillAll()
{
    for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
    {
        if (IsPlayerConnected(playerid) && Player[playerid][ModeID] == this && PlayerModeData[playerid][IsAlive])
            AddPlayerToDeathlist(playerid, GetTickCount() - ModeData[StartTick]);
    }

    for (new a; a < sizeof(Deathlist); a++)
        for (new b; b < sizeof(Deathlist[]); b++)
        {
            TextDrawHideForAll(Deathlist[a][b]);
            TextDrawSetString(Deathlist[a][b], " ");
        }

    return true;
}

forward OnCWMapSearch(playerid);
public OnCWMapSearch(playerid)
{
	new rows = cache_num_rows();

    if (!rows)
        return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Could not find any map.");

    new mID[16], strName[128], strAuthor[128], strFilePointer[256], strMode[MAX_MODE_NAME], rounds;

    for (new rowid; rowid < rows; rowid++)
    {
        cache_get_value_name_int(rowid, "uid", mID[rowid]);

        if (rowid == 14)
            break;
    }

    if (rows == 1)
    {
        cache_get_value_name(0, "strMapName", strName);
        cache_get_value_name(0, "strMapAuthor", strAuthor);
        cache_get_value_name(0, "strFilePointer", strFilePointer);
        rounds = GetPVarInt(playerid, "cwsetmap_rounds");
        DeletePVar(playerid, "cwsetmap_rounds");

        SendModeMessagef(this, COL_INFORMATION, "[CLANWAR] {FFFFFF}Map "#EMB_COL_INFORMATION"%s - %s {FFFFFF}was set for %i rounds.", strAuthor, strName, rounds);

        ModeData[MapRoundsLeft] = rounds;
        Modes[this][Gamemode] = GAMEMODE_RACE; // TODO Make it HG compatible

        new query[128];
        mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_maps WHERE uid = '%d'", mID[0]);
        mysql_pquery(g_Sql, query, "LoadMap", "i", this);
    }
    else if (rows > 1)
    {
        new string[1024];
        format(string, sizeof(string), "#\tAuthor\tName\tMode\n");
        for (new rowid; rowid < rows; rowid++)
        {
            cache_get_value_name(rowid, "strMapName", strName);
            cache_get_value_name(rowid, "strMapAuthor", strAuthor);
            cache_get_value_name(rowid, "strFilePointer", strFilePointer);
            cache_get_value_name(rowid, "strMode", strMode);

            format(string, sizeof(string), "%s%d\t%s\t%s\t%s\n", string, mID[rowid], strAuthor, strName, strMode);

            if (rowid == 14)
                break;
        }

        ShowPlayerDialog(playerid, DIALOG_CW_START_MAP_SELECT, DIALOG_STYLE_TABLIST_HEADERS, "Clanwar >> Start map", string, "Set", "Cancel");
    }
	return true;
}
