#define MAX_CHANNELS 20
enum E_CHANNEL
{
    Name[32],
    QueueCount,
    CurrentSongEnd,
    CurrentSong[32 + 1],
    CurrentSongTitle[128],
    CurrentSongSetBy[MAX_PLAYER_NAME],
    OwnerID,
    bool:IsIdle,
    bool:IsLoading
}
static ModuleData[MAX_CHANNELS][E_CHANNEL];

enum E_CHANNEL_PLAYER
{
    OwnsChannel,
    InChannel
}
static PlayerModuleData[MAX_PLAYERS][E_CHANNEL_PLAYER];

static Text:First, Text:Close, Text:Last, Text:CurrentTD[MAX_CHANNELS], Text:QueueTD[MAX_CHANNELS], Text:ChannelTD[MAX_CHANNELS];

Hook:MUSIC_OnGameModeInit()
{
    First = TextDrawCreate(228.050170, 147.483230, "background");
    TextDrawLetterSize(First, 0.000000, 19.664579);
    TextDrawTextSize(First, 416.199218, 0.000000);
    TextDrawColor(First, -1);
    TextDrawUseBox(First, 1);
    TextDrawBoxColor(First, 128);
    TextDrawBackgroundColor(First, 255);

    new Text:Text = TextDrawCreate(228.034957, 144.966491, "topline");
    TextDrawLetterSize(Text, 0.000000, -0.213759);
    TextDrawTextSize(Text, 416.599792, 0.000000);
    TextDrawColor(Text, -1);
    TextDrawUseBox(Text, 1);
    TextDrawBoxColor(Text, 674910207);
    TextDrawBackgroundColor(Text, 255);

    Text = TextDrawCreate(230.497863, 170.750091, "tableline");
    TextDrawLetterSize(Text, 0.000000, -0.429019);
    TextDrawTextSize(Text, 412.211181, 0.000000);
    TextDrawColor(Text, -1);
    TextDrawUseBox(Text, 1);
    TextDrawBoxColor(Text, -128);
    TextDrawBackgroundColor(Text, 255);

    Text = TextDrawCreate(409.479187, 145.533187, "crossbg");
    TextDrawLetterSize(Text, 0.000000, 0.695136);
    TextDrawTextSize(Text, 416.000000, 0.000000);
    TextDrawColor(Text, -1);
    TextDrawUseBox(Text, 1);
    TextDrawBoxColor(Text, 674910207);
    TextDrawBackgroundColor(Text, 255);

    Close = TextDrawCreate(412.999328, 143.233566, "~y~X");
    TextDrawLetterSize(Close, 0.305119, 1.137498);
    TextDrawTextSize(Close, 7.000000, 7.000000);
    TextDrawAlignment(Close, 2);
    TextDrawColor(Close, -1);
    TextDrawSetShadow(Close, 0);
    TextDrawSetOutline(Close, 0);
    TextDrawBackgroundColor(Close, 255);
    TextDrawFont(Close, 1);
    TextDrawSetProportional(Close, 1);
    TextDrawSetShadow(Close, 0);
    TextDrawSetSelectable(Close, true);

    Text = TextDrawCreate(228.704483, 171.858779, "~y~Queue:");
    TextDrawLetterSize(Text, 0.164801, 0.934997);
    TextDrawAlignment(Text, 1);
    TextDrawColor(Text, -1);
    TextDrawSetShadow(Text, 0);
    TextDrawSetOutline(Text, 0);
    TextDrawBackgroundColor(Text, 255);
    TextDrawFont(Text, 1);
    TextDrawSetProportional(Text, 1);
    TextDrawSetShadow(Text, 0);

    Text = TextDrawCreate(230.497863, 306.658386, "tableline");
    TextDrawLetterSize(Text, 0.000000, -0.429019);
    TextDrawTextSize(Text, 412.211181, 0.000000);
    TextDrawColor(Text, -1);
    TextDrawUseBox(Text, 1);
    TextDrawBoxColor(Text, -128);
    TextDrawBackgroundColor(Text, 255);

    Last = TextDrawCreate(301.214660, 305.083374, "~y~Search");
    TextDrawLetterSize(Last, 0.265534, 1.325832);
    TextDrawAlignment(Last, 1);
    TextDrawColor(Last, -1);
    TextDrawSetShadow(Last, 0);
    TextDrawSetOutline(Last, 0);
    TextDrawBackgroundColor(Last, 255);
    TextDrawFont(Last, 1);
    TextDrawSetProportional(Last, 1);
    TextDrawSetShadow(Last, 0);
    TextDrawSetSelectable(Last, true);

    format(ModuleData[0][Name], 32, "Global");
    for (new i; i < MAX_CHANNELS; i++)
    {
        ModuleData[i][OwnerID] = INVALID_PLAYER_ID;
        ModuleData[i][IsIdle] = true;

        CurrentTD[i] = TextDrawCreate(228.704483, 148.257339, "~y~Currently playing: ~w~None");
        TextDrawLetterSize(CurrentTD[i], 0.164801, 0.934997);
        TextDrawTextSize(CurrentTD[i], 405.699981, 0.000000);
        TextDrawAlignment(CurrentTD[i], 1);
        TextDrawColor(CurrentTD[i], -1);
        TextDrawSetShadow(CurrentTD[i], 0);
        TextDrawSetOutline(CurrentTD[i], 0);
        TextDrawBackgroundColor(CurrentTD[i], 255);
        TextDrawFont(CurrentTD[i], 1);
        TextDrawSetProportional(CurrentTD[i], 1);
        TextDrawSetShadow(CurrentTD[i], 0);

        QueueTD[i] = TextDrawCreate(228.704483, 182.459426, "~w~Empty");
        TextDrawLetterSize(QueueTD[i], 0.164801, 0.934997);
        TextDrawTextSize(QueueTD[i], 416.779785, 0.000000);
        TextDrawAlignment(QueueTD[i], 1);
        TextDrawColor(QueueTD[i], -1);
        TextDrawSetShadow(QueueTD[i], 0);
        TextDrawSetOutline(QueueTD[i], 0);
        TextDrawBackgroundColor(QueueTD[i], 255);
        TextDrawFont(QueueTD[i], 1);
        TextDrawSetProportional(QueueTD[i], 1);
        TextDrawSetShadow(QueueTD[i], 0);

        ChannelTD[i] = TextDrawCreate(315.292083, 317.125366, "~w~Channel: Global");
        TextDrawLetterSize(ChannelTD[i], 0.164801, 0.934997);
        TextDrawAlignment(ChannelTD[i], 2);
        TextDrawColor(ChannelTD[i], -1);
        TextDrawSetShadow(ChannelTD[i], 0);
        TextDrawSetOutline(ChannelTD[i], 0);
        TextDrawBackgroundColor(ChannelTD[i], 255);
        TextDrawFont(ChannelTD[i], 1);
        TextDrawSetProportional(ChannelTD[i], 1);
        TextDrawSetShadow(ChannelTD[i], 0);
    }

    return true;
}

Hook:MUSIC_OnSQLConnection()
{
    mysql_pquery(g_Sql, "DELETE FROM module_musicqueue");
    return true;
}

Hook:MUSIC_OnPlayerLogin(playerid, bool:fromRegistration)
{
    SetPlayerChannel(playerid, 0);
    return true;
}

forward MUSIC_OnPlayerDisconnect(playerid, reason);
public MUSIC_OnPlayerDisconnect(playerid, reason)
{
    if (PlayerModuleData[playerid][OwnsChannel])
    {
        new channelid = PlayerModuleData[playerid][OwnsChannel];
        for (new target, j = GetPlayerPoolSize(); playerid <= j; playerid++)
        {
            if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || target == playerid || Player[target][MusicType] != 2 || PlayerModuleData[target][InChannel] != channelid )
                continue;
            StopAudioStreamForPlayer(target);
            if (Audio_IsClientConnected(target))
                Audio_Stop(target, GetPVarInt(target, "audio.stream"));
            SendClientMessagef(target, COL_INFORMATION, "[MUSIC] Channel %s has been deleted (Owner left)", ModuleData[channelid][Name]);
            SetPlayerChannel(target, 0);
        }
        new query[64];
        mysql_format(g_Sql, query, sizeof(query), "DELETE FROM module_musicqueue WHERE intChannel = '%d'", channelid);
        mysql_pquery(g_Sql, query);
        strdel(ModuleData[channelid][Name], 0, strlen(ModuleData[channelid][Name]));
        strdel(ModuleData[channelid][CurrentSong], 0, strlen(ModuleData[channelid][CurrentSong]));
        ModuleData[channelid][OwnerID] = INVALID_PLAYER_ID;
        PlayerModuleData[playerid][OwnsChannel] = 0;
    }
    PlayerModuleData[playerid][InChannel] = 0;
    return true;
}

/*
Short API Documentation:
GET | /:auth/search/:query | Returns 15 results (- livestreams) (Internal request)
GET | /:auth/audio/:videoId | Converts the video to a mp3 file in ./music/ which is deleted after quitting the application (Internal request)
GET | /:audioHash | mp3 stream (Public request)
auth key: 3CA17A2B44619483F9DA9FED969ED (don't share it)
*/

Hook:MUSIC_OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (IsPlayerPremium(playerid) && clickedid == Last)
    {
        if (GetPVarInt(playerid, "music.inprogress")) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You have a pending request, please wait.");
        if (PlayerModuleData[playerid][InChannel] && PlayerModuleData[playerid][OwnsChannel] != PlayerModuleData[playerid][InChannel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't set songs in this channel.");
        if (ModuleData[PlayerModuleData[playerid][InChannel]][IsLoading]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't set a song right now.");
        if (ModuleData[PlayerModuleData[playerid][InChannel]][QueueCount] >= 5) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The queue is full.");
        PC_EmulateCommand(playerid, "/music");
        ShowPlayerDialog(playerid, 32700, DIALOG_STYLE_INPUT, "Music Player >> Search", " ", "Search", "Close");
    }
    else if (clickedid == Close)
        PC_EmulateCommand(playerid, "/music");
    return true;
}

Hook:MUSIC_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (IsPlayerPremium(playerid))
    {
        switch(dialogid)
        {
            case 32700:
            {
                if (response)
                {
                    if (ModuleData[PlayerModuleData[playerid][InChannel]][IsLoading]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't set a song right now.");
                    if (ModuleData[PlayerModuleData[playerid][InChannel]][QueueCount] >= 5) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The queue is full.");
                    if (strlen(inputtext))
                    {
                        SetPVarInt(playerid, "music.inprogress", 1);
                        new request[256];
                        format(request, sizeof(request), "server.dawn-tdm.com/proxy.php?search=%s", urlencode(inputtext));
                        HTTP(playerid, HTTP_GET, request, "", "APISearchResultReturned");
                    }
                    else ShowPlayerDialog(playerid, 32700, DIALOG_STYLE_INPUT, "Music Player >> Search", " ", "Search", "Close");
                }
            }
            case 32701:
            {
                if (response)
                {
                    if (ModuleData[PlayerModuleData[playerid][InChannel]][IsLoading]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't set a song right now.");
                    if (ModuleData[PlayerModuleData[playerid][InChannel]][QueueCount] >= 5) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The queue is full.");
                    new request[256], varString[16], id[16], title[128];
                    format(varString, sizeof(varString), "music.item-%d.id", listitem);
                    GetPVarString(playerid, varString, id, sizeof(id));

                    format(varString, sizeof(varString), "music.item-%d.title", listitem);
                    GetPVarString(playerid, varString, title, sizeof(title));
                    SetPVarString(playerid, "music.selected.title", title);

                    format(varString, sizeof(varString), "music.item-%d.length", listitem);
                    SetPVarInt(playerid, "music.selected.length", GetPVarInt(playerid, varString));

                    for (new i; i < 15; i++)
                    {
                        format(varString, sizeof(varString), "music.item-%d.id", i);
                        DeletePVar(playerid, varString);

                        format(varString, sizeof(varString), "music.item-%d.length", i);
                        DeletePVar(playerid, varString);

                        format(varString, sizeof(varString), "music.item-%d.title", i);
                        DeletePVar(playerid, varString);
                    }

                    format(request, sizeof(request), "ndmusic.pkfln.io/music/3CA17A2B44619483F9DA9FED969ED/audio/%s", id);
                    HTTP(playerid, HTTP_GET, request, "", "APIDownloadCompleted");
                }
                else
                    DeletePVar(playerid, "music.inprogress");
                PC_EmulateCommand(playerid, "/music");
            }
            case 32702:
            {
                if (response)
                {
                    for (new channelid; channelid < MAX_CHANNELS; channelid++)
                    {
                        if (ModuleData[channelid][Name][0] == EOS)
                            continue;
                        if (!strcmp(inputtext, ModuleData[channelid][Name]) && PlayerModuleData[playerid][InChannel] != channelid)
                        {
                            SendClientMessagef(playerid, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}You are now in Channel '%s'.", ModuleData[channelid][Name], ModuleData[channelid][Name]);
                            SetPlayerChannel(playerid, channelid);
                            break;
                        }
                    }
                }
            }
        }
    }
    return true;
}

forward APIDownloadCompleted(index, response_code, data[]);
public APIDownloadCompleted(index, response_code, data[])
{
    if (!IsPlayerConnected(index)) return false;
    if (response_code == 200)
    {
        if (ModuleData[PlayerModuleData[index][InChannel]][IsLoading]) return false;
        DeletePVar(index, "music.inprogress");
        new JSONNode:node = json_parse_string(data),
            musicLink[128], musicHash[32 + 1], videoTitle[128], length, string[128],
            channelid = PlayerModuleData[index][InChannel];

        GetPVarString(index, "music.selected.title", videoTitle, sizeof(videoTitle));
        length = GetPVarInt(index, "music.selected.length");
        json_get_string(node, musicLink, sizeof(musicLink), "link");

        strmid(musicHash, musicLink, strlen("http://server.dawn-tdm.com:6006/music/"), strlen(musicLink));

        if (ModuleData[channelid][IsIdle])
        {
            ModuleData[channelid][CurrentSong] = musicHash;
            ModuleData[channelid][CurrentSongTitle] = videoTitle;
            ModuleData[channelid][CurrentSongSetBy] = Player[index][Name];
            format(string, sizeof(string), "http://server.dawn-tdm.com:6006/music/%s", musicHash);
            for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
            {
                if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][MusicType] != 2 || PlayerModuleData[playerid][InChannel] != channelid)
                    continue;
                if (Audio_IsClientConnected(playerid))
                    SetPVarInt(playerid, "audio.stream", Audio_PlayStreamed(playerid, string, false, false, false));
                else
                    PlayAudioStreamForPlayer(playerid, string);

                SendClientMessagef(playerid, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}Now playing '%s'.", ModuleData[channelid][Name], videoTitle);
            }

            ModuleData[channelid][CurrentSongEnd] = gettime() + length;

            new diff = ModuleData[channelid][CurrentSongEnd] - gettime(),
                minutes = floatround(diff / 60);
            diff = diff % 60;
            format(string, sizeof(string), "~y~Currently playing: ~w~%s (%02d:%02d)", videoTitle, minutes, diff);
            TextDrawSetString(CurrentTD[channelid], string);

            ModuleData[channelid][IsIdle] = false;
        }
        else
        {
            if (ModuleData[PlayerModuleData[index][InChannel]][QueueCount] >= 5) return SendClientMessage(index, COL_ERROR, "[ERROR] {FFFFFF}The queue is full.");
            new query[1024];
            mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_musicqueue (strMusicHash, strVideoTitle, intVideoLength, strSetBy, intChannel) VALUES ('%e', '%e', '%d', '%e', '%d')", musicHash, videoTitle, length, Player[index][Name], PlayerModuleData[index][InChannel]);
            mysql_pquery(g_Sql, query);

            ModuleData[channelid][QueueCount]++;

            TextDrawGetString(QueueTD[channelid], query);
            if (!strcmp(query, "~w~Empty", true))
                format(query, sizeof(query), "~w~%s~n~~n~", videoTitle);
            else
                format(query, sizeof(query), "%s~w~%s~n~~n~", query, videoTitle);
            TextDrawSetString(QueueTD[channelid], query);

            SendClientMessagef(index, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}Added '%s' to the queue.", ModuleData[channelid][Name], videoTitle);
        }
        json_close(node);
    }
    else
    {
        DeletePVar(index, "music.inprogress");
        SendClientMessage(index, COL_ERROR, "[ERROR] {FFFFFF}API Error.");
    }
    return true;
}

forward APISearchResultReturned(index, response_code, data[]);
public APISearchResultReturned(index, response_code, data[])
{
    if (!IsPlayerConnected(index)) return false;
    if (response_code == 200)
    {
        new JSONNode:node = json_parse_string(data),
            title[128], channel[32], duration, views, id[16], string[2048],
            minutes, varString[16], seconds;

        format(string, sizeof(string), "Channel\tTitle\tViews\tLength\n");

        new JSONArray:array = json_get_array(node);

        for (new i, j = json_array_count(array); i < j; i++)
        {
            new JSONNode:array_node = json_array_at(array, i);
            json_get_string(array_node, title, sizeof(title), "title");
            json_get_string(array_node, channel, sizeof(channel), "channel");
            duration = json_get_int(array_node, "duration");
            views = json_get_int(array_node, "viewCount");

            seconds = duration;
            minutes = floatround(seconds / 60);
            seconds = seconds % 60;

            format(string, sizeof(string), "%s"#EMB_COL_LIGHTGREY"%s\t%s\t"#EMB_COL_LIGHTGREY"%d\t"#EMB_COL_LIGHTGREY"%02d:%02d\n", string, channel, title, views, minutes, seconds);
            json_get_string(array_node, id, sizeof(id), "videoId");

            format(varString, sizeof(varString), "music.item-%d.id", i);
            SetPVarString(index, varString, id);

            format(varString, sizeof(varString), "music.item-%d.length", i);
            SetPVarInt(index, varString, duration);

            format(varString, sizeof(varString), "music.item-%d.title", i);
            SetPVarString(index, varString, title);
            json_close(array_node);
        }
        ShowPlayerDialog(index, 32701, DIALOG_STYLE_TABLIST_HEADERS, "Music Player >> Search Results", string, "Play", "Cancel");
        json_close(node);
    }
    else
    {
        DeletePVar(index, "music.inprogress");
        SendClientMessagef(index, COL_ERROR, "[ERROR] {FFFFFF}API Error.", response_code);
    }
    return true;
}

task Music[1000]()
{
    new string[128];
    for (new channelid; channelid < MAX_CHANNELS; channelid++)
    {
        if (ModuleData[channelid][Name][0] == EOS)
            continue;
        if (!ModuleData[channelid][IsIdle] && !ModuleData[channelid][IsLoading])
        {
            new diff = ModuleData[channelid][CurrentSongEnd] - gettime(),
                minutes = floatround(diff / 60);
            diff = diff % 60;
            format(string, sizeof(string), "~y~Currently playing: ~w~%s (%02d:%02d)", ModuleData[channelid][CurrentSongTitle], minutes, diff);
            TextDrawSetString(CurrentTD[channelid], string);
            if (gettime() >= ModuleData[channelid][CurrentSongEnd])
            {
                ModuleData[channelid][IsLoading] = true;
                ModuleData[channelid][CurrentSongTitle][0] = EOS;
                TextDrawSetString(CurrentTD[channelid], "~y~Currently playing: ~w~None");
                for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
                {
                    if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][MusicType] != 2 || PlayerModuleData[playerid][InChannel] != channelid)
                        continue;
                    StopAudioStreamForPlayer(playerid);
                    if (Audio_IsClientConnected(playerid))
                        Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
                }
                TextDrawSetString(CurrentTD[channelid], "~y~Currently playing: ~w~None");
                new query[128];
                mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_musicqueue WHERE intChannel = '%d' ORDER BY uid ASC", channelid);
                mysql_pquery(g_Sql, query, "OnMusicPlayerStart", "d", channelid);
            }
        }
    }
    return true;
}

forward OnMusicPlayerStart(channelid);
public OnMusicPlayerStart(channelid)
{
    new rows = cache_num_rows(),
        string[1024], uid, musicHash[32 + 1], videoTitle[128], videoLength, setBy[MAX_PLAYER_NAME];
    if (rows)
    {
        ModuleData[channelid][QueueCount] = rows - 1;
        for (new rowid; rowid < rows; rowid++)
        {
            cache_get_value_name_int(rowid, "uid", uid);
            cache_get_value_name(rowid, "strMusicHash", musicHash);
            cache_get_value_name(rowid, "strVideoTitle", videoTitle);
            cache_get_value_name_int(rowid, "intVideoLength", videoLength);
            cache_get_value_name(rowid, "strSetBy", setBy);
            if (rowid == 0)
            {
                ModuleData[channelid][CurrentSong] = musicHash;
                ModuleData[channelid][CurrentSongTitle] = videoTitle;
                ModuleData[channelid][CurrentSongSetBy] = setBy;
                format(string, sizeof(string), "http://server.dawn-tdm.com:6006/music/%s", musicHash);
                for (new playerid, j = GetPlayerPoolSize(); playerid <= j; playerid++)
                {
                    if (!IsPlayerConnected(playerid) || !Player[playerid][IsLoggedIn] || Player[playerid][MusicType] != 2 || PlayerModuleData[playerid][InChannel] != channelid)
                        continue;
                    if (Audio_IsClientConnected(playerid))
                        SetPVarInt(playerid, "audio.stream", Audio_PlayStreamed(playerid, string, false, false, false));
                    else
                        PlayAudioStreamForPlayer(playerid, string);

                    SendClientMessagef(playerid, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}Now playing '%s'.", ModuleData[channelid][Name], videoTitle);
                }

                ModuleData[channelid][CurrentSongEnd] = gettime() + videoLength;

                new diff = ModuleData[channelid][CurrentSongEnd] - gettime(),
                    minutes = floatround(diff / 60);
                diff = diff % 60;
                format(string, sizeof(string), "~y~Currently playing: ~w~%s (%02d:%02d)", videoTitle, minutes, diff);
                TextDrawSetString(CurrentTD[channelid], string);

                ModuleData[channelid][IsIdle] = false;

                mysql_format(g_Sql, string, sizeof(string), "DELETE FROM module_musicqueue WHERE uid = '%d'", uid);
                mysql_pquery(g_Sql, string);

                string[0] = EOS;
            }
            else
                format(string, sizeof(string), "%s~w~%s~n~~n~", string, videoTitle);
        }
        if (string[0] == EOS)
            TextDrawSetString(QueueTD[channelid], "~w~Empty");
        else
            TextDrawSetString(QueueTD[channelid], string);
    }
    else
    {
        ModuleData[channelid][QueueCount] = 0;
        ModuleData[channelid][IsIdle] = true;
    }
    ModuleData[channelid][IsLoading] = false;
    return true;
}

CMD:music(playerid, params[])
{
    if (IsTextDrawVisibleForPlayer(playerid, First))
    {
        for (new Text:i = First; i <= Last; i++)
        {
            if (IsValidTextDraw(i))
                TextDrawHideForPlayer(playerid, i);
        }
        TextDrawHideForPlayer(playerid, CurrentTD[PlayerModuleData[playerid][InChannel]]);
        TextDrawHideForPlayer(playerid, QueueTD[PlayerModuleData[playerid][InChannel]]);
        TextDrawHideForPlayer(playerid, ChannelTD[PlayerModuleData[playerid][InChannel]]);
        CancelSelectTextDraw(playerid);
    }
    else
    {
        for (new Text:i = First; i <= Last; i++)
        {
            if (IsValidTextDraw(i))
                TextDrawShowForPlayer(playerid, i);
        }
        TextDrawShowForPlayer(playerid, CurrentTD[PlayerModuleData[playerid][InChannel]]);
        TextDrawShowForPlayer(playerid, QueueTD[PlayerModuleData[playerid][InChannel]]);
        TextDrawShowForPlayer(playerid, ChannelTD[PlayerModuleData[playerid][InChannel]]);
        SelectTextDraw(playerid, 0xFFFFFFFF);
    }
    return true;
}

CMD:channels(playerid, params[])
{
    new string[512];
    format(string, sizeof(string), "Name\tOwner\tCurrently playing\nGlobal\t-\t%s\n", ModuleData[0][CurrentSongTitle]);
    for (new channelid = 1; channelid < MAX_CHANNELS; channelid++)
    {
        if (ModuleData[channelid][Name][0] == EOS)
            continue;
        format(string, sizeof(string), "%s%s\t%s\t%s\n", string, ModuleData[channelid][Name], Player[ModuleData[channelid][OwnerID]][Name], ModuleData[channelid][CurrentSongTitle]);
    }
    ShowPlayerDialog(playerid, 32702, DIALOG_STYLE_TABLIST_HEADERS, "Music Player >> Channels", string, "Join", "Abort");
    return true;
}

CMD:skipsong(playerid, params[])
{
    if (Player[playerid][AdminLevel] || (PlayerModuleData[playerid][OwnsChannel] && PlayerModuleData[playerid][InChannel] == PlayerModuleData[playerid][OwnsChannel]))
    {
        ModuleData[PlayerModuleData[playerid][InChannel]][CurrentSongEnd] = gettime();
        for (new target, j = GetPlayerPoolSize(); target <= j; target++)
        {
            if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || Player[target][MusicType] != 2 || PlayerModuleData[target][InChannel] != PlayerModuleData[playerid][InChannel])
                continue;
            SendClientMessagef(target, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}The song has been skipped.", ModuleData[PlayerModuleData[playerid][InChannel]][Name]);
        }
    }
    return true;
}

CMD:createchannel(playerid, params[])
{
    if (!IsPlayerPremium(playerid)) return false;
    if (PlayerModuleData[playerid][OwnsChannel]) return false;
    new name[32];
    if (sscanf(params, "s[32]", name)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/createchannel [name]");
    if (strfind(name, " ") != -1) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}No spaces in the name allowed.");
    for (new channelid; channelid < MAX_CHANNELS; channelid++)
    {
        if (ModuleData[channelid][Name][0] != EOS)
        {
            if (!strcmp(ModuleData[channelid][Name], name))
                return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Channel with this name already exists.");
            if (channelid == MAX_CHANNELS - 1)
                return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Channel limit has been reached.");
            continue;
        }
        StopAudioStreamForPlayer(playerid);
        if (Audio_IsClientConnected(playerid))
            Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));

        new string[64];
        format(string, sizeof(string), "~w~Channel: %s", name);
        TextDrawSetString(ChannelTD[channelid], string);
        TextDrawSetString(CurrentTD[channelid], "~y~Currently playing: ~w~None");
        TextDrawSetString(QueueTD[channelid], "~w~Empty");

        ModuleData[channelid][Name] = name;
        ModuleData[channelid][IsIdle] = true;
        ModuleData[channelid][IsLoading] = false;
        ModuleData[channelid][OwnerID] = playerid;
        PlayerModuleData[playerid][OwnsChannel] = channelid;
        PlayerModuleData[playerid][InChannel] = channelid;
        SendClientMessagef(playerid, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}Successfully created channel.", name);
        break;
    }
    return true;
}

CMD:deletechannel(playerid, params[])
{
    if (PlayerModuleData[playerid][OwnsChannel])
    {
        new channelid = PlayerModuleData[playerid][OwnsChannel];

        for (new target, j = GetPlayerPoolSize(); target <= j; target++)
        {
            if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || Player[target][MusicType] != 2 || PlayerModuleData[target][InChannel] != channelid)
                continue;
            SendClientMessagef(target, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}The channel has been deleted, you have joined #Global.", ModuleData[channelid][Name]);
            SetPlayerChannel(target, 0);
        }

        ModuleData[channelid][Name][0] = EOS;
        ModuleData[channelid][IsIdle] = false;
        ModuleData[channelid][IsLoading] = false;
        PlayerModuleData[playerid][OwnsChannel] = 0;

        new query[32];
        mysql_format(g_Sql, query, sizeof(query), "DELETE FROM module_musicqueue WHERE intChannel = '%d'", channelid);
        mysql_pquery(g_Sql, query);
    }
    return true;
}


SetPlayerChannel(playerid, channelid)
{
    PlayerModuleData[playerid][InChannel] = channelid;
    StopAudioStreamForPlayer(playerid);
    if (Audio_IsClientConnected(playerid))
        Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
    if (!ModuleData[channelid][IsIdle] && !ModuleData[channelid][IsLoading])
    {
        new string[128];
        format(string, sizeof(string), "http://server.dawn-tdm.com:6006/music/%s", ModuleData[channelid][CurrentSong]);
        StopAudioStreamForPlayer(playerid);
        if (Audio_IsClientConnected(playerid))
            SetPVarInt(playerid, "audio.stream", Audio_PlayStreamed(playerid, string, false, true, false));
        else
            PlayAudioStreamForPlayer(playerid, string);

        SendClientMessagef(playerid, COL_INFORMATION, "[MUSIC #%s] {FFFFFF}Now playing '%s'.", ModuleData[channelid][Name], ModuleData[channelid][CurrentSongTitle]);
    }
    return true;
}
