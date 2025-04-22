static  Text:Textdraw[MAX_MODES],
        fadeStatus[MAX_MODES],
        fadeType[MAX_MODES],
        fadeTimer[MAX_MODES];

Hook:FADE_OnGameModeInit()
{
    for (new modeid; modeid < MAX_MODES; modeid++)
    {
        Textdraw[modeid] = TextDrawCreate(0.0, 0.0,"_");
    	TextDrawTextSize(Textdraw[modeid], 640.0, 480.0);
    	TextDrawLetterSize(Textdraw[modeid], 0.0, 50.0);
    	TextDrawUseBox(Textdraw[modeid], true);
        TextDrawBoxColor(Textdraw[modeid], 0x00000000);
    }
    return true;
}

forward OnFadeUpdate(gamemodeid, bool:fademusic);
public OnFadeUpdate(gamemodeid, bool:fademusic)
{
    if (fadeType[gamemodeid] == 1)
    {
        fadeStatus[gamemodeid] += 3;
        TextDrawBoxColor(Textdraw[gamemodeid], ((0x000000FF & ~0xFF) | clamp(fadeStatus[gamemodeid], 0x00, 0xFF)));

        for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
        {
            if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
                continue;
            TextDrawShowForPlayer(playerid, Textdraw[gamemodeid]);
            if (Audio_IsClientConnected(playerid) && Player[playerid][MusicType] == 1 && fademusic && fadeStatus[gamemodeid] <= 103)
            {
                Audio_SetVolume(playerid, GetPVarInt(playerid, "audio.stream"), (fadeStatus[gamemodeid] > 100 ? 0 : (100 - fadeStatus[gamemodeid])));
                if (fadeStatus[gamemodeid] > 100)
                {
                    Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
                    SetPVarInt(playerid, "audio.stream", -1);
                }
            }
        }

        if (fadeStatus[gamemodeid] >= 255)
        {
            KillTimer(fadeTimer[gamemodeid]);
        }
    }
    else
    {
        fadeStatus[gamemodeid] -= 3;
        TextDrawBoxColor(Textdraw[gamemodeid], ((0x000000FF & ~0xFF) | clamp(fadeStatus[gamemodeid], 0x00, 0xFF)));

        for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
        {
            if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
                continue;
            TextDrawShowForPlayer(playerid, Textdraw[gamemodeid]);
        }

        if (fadeStatus[gamemodeid] <= 0)
        {
            KillTimer(fadeTimer[gamemodeid]);
            TextDrawHideForAll(Textdraw[gamemodeid]);
        }
    }
    return true;
}

FadeMode(gamemodeid, bool:fademusic = false)
{
    TextDrawBoxColor(Textdraw[gamemodeid], 0x00000000);
    for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
    {
        if (!IsPlayerConnected(playerid) || Player[playerid][ModeID] != gamemodeid)
            continue;
        TextDrawShowForPlayer(playerid, Textdraw[gamemodeid]);
    }
    fadeType[gamemodeid] = 1;
    fadeStatus[gamemodeid] = 0;
    fadeTimer[gamemodeid] = SetTimerEx("OnFadeUpdate", 30, true, "ii", gamemodeid, fademusic);
    return true;
}

RevertFade(gamemodeid)
{
    KillTimer(fadeTimer[gamemodeid]);
    fadeType[gamemodeid] = 0;
    fadeTimer[gamemodeid] = SetTimerEx("OnFadeUpdate", 30, true, "i", gamemodeid);
}

SetFadeStateBlack(gamemodeid)
    TextDrawBoxColor(Textdraw[gamemodeid], 0x000000FF);

HideFadeTextdrawForPlayer(playerid, gamemodeid)
    return TextDrawHideForPlayer(playerid, Textdraw[gamemodeid]);

ShowFadeTextdrawForPlayer(playerid, gamemodeid)
    return TextDrawShowForPlayer(playerid, Textdraw[gamemodeid]);
