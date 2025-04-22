static  LastCommandTick[MAX_PLAYERS],
        CommandSpamWarnings[MAX_PLAYERS],
        NoCommandUntil[MAX_PLAYERS];

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if (!Player[playerid][IsLoggedIn])
        return false;
    if (((flags & CMD_TRIAL_MODERATOR) && Player[playerid][AdminLevel] < 1 ) || ( (flags & CMD_MODERATOR) && Player[playerid][AdminLevel] < 2 ) || ( (flags & CMD_SENIOR_MODERATOR) && Player[playerid][AdminLevel] < 3 ) || ((flags & CMD_LEAD_MODERATOR) && Player[playerid][AdminLevel] < 4 ) || ((flags & CMD_ADMINISTRATOR) && Player[playerid][AdminLevel] < 5 ))
		return false;

    if (PC_CommandExists(cmd))
    {
        if (!Player[playerid][AdminLevel])
    	{
            if (GetTickCount() < NoCommandUntil[playerid] && !(flags & SPAM_PENALTY_EXCEPTION))
            {
                SendClientMessagef(playerid, COL_PUNISHMENT, "[ERROR] {FFFFFF}You are currently unable to execute any command (%d seconds).", ((NoCommandUntil[playerid] - GetTickCount()) % 60000) / 1000);
                return false;
            }
    		if (GetTickCount() - LastCommandTick[playerid] <= 2000)
    		{
    			CommandSpamWarnings[playerid]++;
    			switch(CommandSpamWarnings[playerid])
    			{
    				case 3:
    				{
    					SendClientMessageToAll(COL_PUNISHMENT, "Please refrain from spamming commands (1/4).");
    					NoCommandUntil[playerid] = GetTickCount() + 10000;
    					return false;
    				}
    				case 6:
    				{
    					SendClientMessageToAll(COL_PUNISHMENT, "Please refrain from spamming commands (2/4).");
    					NoCommandUntil[playerid] = GetTickCount() + 30000;
    					return false;
    				}
    				case 9:
    				{
    					SendClientMessageToAll(COL_PUNISHMENT, "Please refrain from spamming commands (3/4).");
    					NoCommandUntil[playerid] = GetTickCount() + 60000;
    					return false;
    				}
    				case 12:
    				{
                        Log("SOFIA", playerid, -1, "kick", "command spam");
    					SendClientMessageToAllf(COL_PUNISHMENT, "Sofia has kicked %s for 'Continuous/Excessive Command Spam'.", Player[playerid][Name]);
    					Kick(playerid);
    					return false;
    				}
    			}
    		}
    		else
    		{
    			switch(CommandSpamWarnings[playerid])
    			{
    				case 1, 2: CommandSpamWarnings[playerid] = 0;
    				case 4, 5: CommandSpamWarnings[playerid] = 3;
    				case 7, 8: CommandSpamWarnings[playerid] = 6;
    				case 10, 11: CommandSpamWarnings[playerid] = 9;
    			}
    		}
        }
        LastCommandTick[playerid] = GetTickCount();

        new target = INVALID_PLAYER_ID, buf[128];
        if (strlen(params) && flags & HAS_TARGET)
        {
            sscanf(params, "us[128]", target, buf);
            if (IsPlayerConnected(target))
                format(buf, sizeof(buf), "%s [%s]", cmd, Player[target][Name]);
            else
                format(buf, sizeof(buf), "%s [no target]", cmd);
        }
        else
            format(buf, sizeof(buf), "%s [no target]", cmd);
        Log("COMMAND", playerid, target, buf, (strlen(params) ? params : "no parameter"));
    }
    else
    {
        SendClientMessage(playerid, COL_SAMP_MSG, "SERVER: Unknown command.");
        return false;
    }
    return true;
}


/** ------------- **/
/** P R E M I U M **/
/** ------------- **/


IsPlayerPremium(playerid)
{
    if (!Player[playerid][IsLoggedIn]) return false;
    if (Player[playerid][Premium] > gettime() || Player[playerid][AdminLevel])
        return true;
    return false;
}

CMD:sound(playerid, params[])
{
    if (!IsPlayerPremium(playerid)) return false;
    new sound[32];
    if (sscanf(params, "s[32]", sound))
    {
        SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[Usage] {FFFFFF}/sound [name]");
        SendClientMessage(playerid, COL_SYNTAX_REMINDER, "Available sounds: {FFFFFF}cheer, lose, pay attention, jackpot, what would mother think, real interesting");
        SendClientMessage(playerid, 0xFFFFFFFF, "learn moves, time to recover, win for sir, where my bitches, punk crack bitches, five orgasms, going down");
        SendClientMessage(playerid, 0xFFFFFFFF, "stfu, they bitch, the show, diemfwhores, cry, my balls, battle, sister, little bishop, train, deeper");
        SendClientMessage(playerid, 0xFFFFFFFF, "not enough cash, set to bounce, fatman, the end, fancy moves, gear stick, get some muscles, cursed asshole");
        SendClientMessage(playerid, 0xFFFFFFFF, "in love, no love, love cars, mother lover, liquor, relax, hey, crazy idiot, more men, naughty girl, punish");
        SendClientMessage(playerid, 0xFFFFFFFF, "shut up, you got it, dont worry, ok boss, no comment, fire in the hole, good luck, you too, no ty, busy, snor");
        SendClientMessage(playerid, 0xFFFFFFFF, "my car, fall, cant ride, who are you, dangerous, fuck noo, holy fuck, dont fuck, strawberries, shut up motherfucker");
        SendClientMessage(playerid, 0xFFFFFFFF, "fucking amazing, fucked up, just saying, lets finish this, fuck no, celeb, hurry up, talking about, prize hog");
        return SendClientMessage(playerid, 0xFFFFFFFF, "red bumpies, talkinbout, wassup, tyvm");
    }
    new soundid = -1, soundtext[64];

    if (!strcmp(sound, "cheer", true))
    {
        soundid = 36205;
        strins(soundtext, "*Cheering*", 0);
    }
    else if (!strcmp(sound, "lose", true))
    {
        soundid = 31202;
        strins(soundtext, "*Lose*", 0);
    }
    else if (!strcmp(sound, "pay attention", true))
    {
        soundid = 4804;
        strins(soundtext, "Yo' pay attention and you might learn something.", 0);
    }
    else if (!strcmp(sound, "jackpot", true))
    {
        soundid = 5461;
        strins(soundtext, "Jackpot!", 0);
    }
    else if (!strcmp(sound, "what would mother think", true))
    {
        soundid = 39000;
        strins(soundtext, "What would your mother think?", 0);
    }
    else if (!strcmp(sound, "real interesting", true))
    {
        soundid = 39076;
        strins(soundtext, "Aha, real interesting..", 0);
    }
    else if (!strcmp(sound, "learn moves", true))
    {
        soundid = 4800;
        strins(soundtext, "Yo', you wanna learn some new moves?", 0);
    }
    else if (!strcmp(sound, "time to recover", true))
    {
        soundid = 4807;
        strins(soundtext, "Never give your opponent time to recover.", 0);
    }
    else if (!strcmp(sound, "win for sir", true))
    {
        soundid = 5462;
        strins(soundtext, "Another win for sir!", 0);
    }
    else if (!strcmp(sound, "where my bitches", true))
    {
        soundid = 14028;
        strins(soundtext, "Where are all my bitches..? My bitches!", 0);
    }
    else if (!strcmp(sound, "punk crack bitches", true))
    {
        soundid = 24211;
        strins(soundtext, "Punk crack bitches!", 0);
    }
    else if (!strcmp(sound, "five orgasms", true))
    {
        soundid = 5005;
        strins(soundtext, "Five orgasms in as many minutes!", 0);
    }
    else if (!strcmp(sound, "going down", true))
    {
        soundid = 24215;
        strins(soundtext, "You're all going down, motherfuckers!", 0);
    }
    else if (!strcmp(sound, "stfu", true))
    {
        soundid = 24816;
        strins(soundtext, "Shut the fuck up, bitch!", 0);
    }
    else if (!strcmp(sound, "they bitch", true))
    {
        soundid = 26406;
        strins(soundtext, "Go fuck yourself, you just they bitch!", 0);
    }
    else if (!strcmp(sound, "the show", true))
    {
        soundid = 12404;
        strins(soundtext, "The show must go on!", 0);
    }
    else if (!strcmp(sound, "diemfwhores", true))
    {
        soundid = 43861;
        strins(soundtext, "Die you motherfucking sons of whores!", 0);
    }
    else if (!strcmp(sound, "cry", true))
    {
        soundid = 7063;
        strins(soundtext, "*Cries*", 0);
    }
    else if (!strcmp(sound, "my balls", true))
    {
        soundid = 7051;
        strins(soundtext, "Shit! My balls! My balls!", 0);
    }
    else if (!strcmp(sound, "battle", true))
    {
        soundid = 45005;
        strins(soundtext, "Let battle commence!", 0);
    }
    else if (!strcmp(sound, "sister", true))
    {
        soundid = 42405;
        strins(soundtext, "So how's your sister?", 0);
    }
    else if (!strcmp(sound, "little bishop", true))
    {
        soundid = 39057;
        strins(soundtext, "Argh! Careful with the little bishop, whore!", 0);
    }
    else if (!strcmp(sound, "train", true))
    {
        soundid = 35451;
        strins(soundtext, "All we had to do, was follow the damn train, CJ!", 0);
    }
    else if (!strcmp(sound, "deeper", true))
    {
        soundid = 25044;
        strins(soundtext, "Yes Claude! Faster! Harder! DEEPER!", 0);
    }
    else if (!strcmp(sound, "not enough cash", true))
    {
        soundid = 22806;
        strins(soundtext, "You don't have enough cash to play, ese.", 0);
    }
    else if (!strcmp(sound, "set to bounce", true))
    {
        soundid = 22801;
        strins(soundtext, "Man, your car gotta be set to bounce, homie!", 0);
    }
    else if (!strcmp(sound, "fatman", true))
    {
        soundid = 20049;
        strins(soundtext, "C'mon CJ? You can't keep up with the fatman?", 0);
    }
    else if (!strcmp(sound, "the end", true))
    {
        soundid = 14029;
        strins(soundtext, "It's the end! Oh, you non-driving asshole... Uurruuggh!", 0);
    }
    else if (!strcmp(sound, "fancy moves", true))
    {
        soundid = 11453;
        strins(soundtext, "Some fancy moves for a city boy.", 0);
    }
    else if (!strcmp(sound, "gear stick", true))
    {
        soundid = 5003;
        strins(soundtext, "Oh Claude! It's bigger than the gear stick!", 0);
    }
    else if (!strcmp(sound, "get some muscles", true))
    {
        soundid = 4802;
        strins(soundtext, "Man, you're an embarrassment! Get yourself some muscles first.", 0);
    }
    else if (!strcmp(sound, "cursed asshole", true))
    {
        soundid = 43870;
        strins(soundtext, "Cursed asshole!", 0);
    }
    else if (!strcmp(sound, "in love", true))
    {
        soundid = 8681;
        strins(soundtext, "I'm in love, Carl.", 0);
    }
    else if (!strcmp(sound, "no love", true))
    {
        soundid = 9897;
        strins(soundtext, "I don't love you no more!", 0);
    }
    else if (!strcmp(sound, "love cars", true))
    {
        soundid = 20004;
        strins(soundtext, "Always love cars, man.", 0);
    }
    else if (!strcmp(sound, "mother lover", true))
    {
        soundid = 41229;
        strins(soundtext, "And secondly, I never made love to my mother. She wouldn't..", 0);
    }
    else if (!strcmp(sound, "liquor", true))
    {
        soundid = 14005;
        strins(soundtext, "Give me some liquor!", 0);
    }
    else if (!strcmp(sound, "hey", true))
    {
        soundid = 14014;
        strins(soundtext, "Hey! HEY!", 0);
    }
    else if (!strcmp(sound, "relax", true))
    {
        soundid = 11607;
        strins(soundtext, "Damn baby, relax, you too stiff.", 0);
    }
    else if (!strcmp(sound, "crazy idiot", true))
    {
        soundid = 18008;
        strins(soundtext, "You some crazy idiot or something?", 0);
    }
    else if (!strcmp(sound, "more men", true))
    {
        soundid = 18205;
        strins(soundtext, "We need more men in here!", 0);
    }
    else if (!strcmp(sound, "naughty girl", true))
    {
        soundid = 18414;
        strins(soundtext, "You've been a naughty girl!", 0);
    }
    else if (!strcmp(sound, "punish", true))
    {
        soundid = 18426;
        strins(soundtext, "Hey, if you good I'll punish you more.", 0);
    }
    else if (!strcmp(sound, "shut up", true))
    {
        soundid = 19013;
        strins(soundtext, "Shut up.", 0);
    }
    else if (!strcmp(sound, "you got it", true))
    {
        soundid = 19023;
        strins(soundtext, "You got it.", 0);
    }
    else if (!strcmp(sound, "dont worry", true))
    {
        soundid = 19026;
        strins(soundtext, "Yeah, well, don't worry about it.", 0);
    }
    else if (!strcmp(sound, "ok boss", true))
    {
        soundid = 19057;
        strins(soundtext, "Ok boss!", 0);
    }
    else if (!strcmp(sound, "no comment", true))
    {
        soundid = 19082;
        strins(soundtext, "No comment!", 0);
    }
    else if (!strcmp(sound, "fire in the hole", true))
    {
        soundid = 19084;
        strins(soundtext, "Fire in the hole!", 0);
    }
    else if (!strcmp(sound, "good luck", true))
    {
        soundid = 19109;
        strins(soundtext, "Good luck!", 0);
    }
    else if (!strcmp(sound, "you too", true))
    {
        soundid = 19110;
        strins(soundtext, "You too!", 0);
    }
    else if (!strcmp(sound, "no ty", true))
    {
        soundid = 19201;
        strins(soundtext, "No thank you.", 0);
    }
    else if (!strcmp(sound, "busy", true))
    {
        soundid = 19213;
        strins(soundtext, "I'm rather busy sir.", 0);
    }
    else if (!strcmp(sound, "snor", true))
    {
        soundid = 19602;
        strins(soundtext, "*snoring*", 0);
    }
    else if (!strcmp(sound, "my car", true))
    {
        soundid = 20009;
        strins(soundtext, "Aww motherfucker, my car!", 0);
    }
    else if (!strcmp(sound, "fall", true))
    {
        soundid = 20037;
        strins(soundtext, "Haha! This fool took a fall!", 0);
    }
    else if (!strcmp(sound, "cant ride", true))
    {
        soundid = 20038;
        strins(soundtext, "He can't even ride a bike!", 0);
    }
    else if (!strcmp(sound, "who are you", true))
    {
        soundid = 22008;
        strins(soundtext, "Who the fuck are you?", 0);
    }
    else if (!strcmp(sound, "dangerous", true))
    {
        soundid = 22019;
        strins(soundtext, "Dangerous motherfuckers!", 0);
    }
    else if (!strcmp(sound, "fuck noo", true))
    {
        soundid = 22024;
        strins(soundtext, "Fuck NOOOOOOOOOOOOOO!", 0);
    }
    else if (!strcmp(sound, "hoyl fuck", true))
    {
        soundid = 22025;
        strins(soundtext, "Holy FUUUUUUUCK!", 0);
    }
    else if (!strcmp(sound, "dont fuck", true))
    {
        soundid = 23805;
        strins(soundtext, "You don't know who you're fucking with, do you?", 0);
    }
    else if (!strcmp(sound, "strawberries", true))
    {
        soundid = 24217;
        strins(soundtext, "Strawberries!", 0);
    }
    else if (!strcmp(sound, "shut up motherfucker", true))
    {
        soundid = 27411;
        strins(soundtext, "Ah shut up. Motherfucker.", 0);
    }
    else if (!strcmp(sound, "fucking amazing", true))
    {
        soundid = 28418;
        strins(soundtext, "Fucking great! Fucking amazing!", 0);
    }
    else if (!strcmp(sound, "fucked up", true))
    {
        soundid = 30046;
        strins(soundtext, "Well, we was all hanging out and shit got fucked up.", 0);
    }
    else if (!strcmp(sound, "just saying", true))
    {
        soundid = 30065;
        strins(soundtext, "That's all I'm sayin'.", 0);
    }
    else if (!strcmp(sound, "lets finish this", true))
    {
        soundid = 33073;
        strins(soundtext, "Let's fucking finish this!", 0);
    }
    else if (!strcmp(sound, "fuck no", true))
    {
        soundid = 33243;
        strins(soundtext, "Fuck no!", 0);
    }
    else if (!strcmp(sound, "celeb", true))
    {
        soundid = 33300;
        strins(soundtext, "I'm a mother fucking celebrity!", 0);
    }
    else if (!strcmp(sound, "hurry up", true))
    {
        soundid = 9014;
        strins(soundtext, "Stop playing with your balls and hurry up!", 0);
    }
    else if (!strcmp(sound, "talking about", true))
    {
        soundid = 7828;
        strins(soundtext, "What are you talking about?", 0);
    }
    else if (!strcmp(sound, "prize hog", true))
    {
        soundid = 7830;
        strins(soundtext, "That there city boy has gone and been with my prize hog!", 0);
    }
    else if (!strcmp(sound, "red bumpies", true))
    {
        soundid = 7834;
        strins(soundtext, "I'm gonna slap you silly for giving me and my fella the red bumpies!", 0);
    }
    else if (!strcmp(sound, "talkinbout", true))
    {
        soundid = 29027;
        strins(soundtext, "What you talking about?", 0);
    }
    else if (!strcmp(sound, "wassup", true))
    {
        soundid = 29034;
        strins(soundtext, "Wassup?", 0);
    }
    else if (!strcmp(sound, "tyvm", true))
    {
        soundid = 12407;
        strins(soundtext, "Thank you very much!", 0);
    }
    else
        strins(soundtext, "Undefined!", 0);

    if (soundid != -1)
    {
        for (new target, j = GetPlayerPoolSize(); target <= j; target++)
        {
            if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || Player[target][ModeID] != Player[playerid][ModeID])
                continue;
            PlayerPlaySound(target, soundid, 0.0, 0.0, 0.0);
            SendClientMessagef(target, COL_LIGHTBLUE_PURPLE, "[SOUND] %s: {FFFFFF}%s", Player[playerid][Name], soundtext);
        }
    }
    return true;
}

/** ------------------- **/
/** M O D E R A T I O N **/
/** ------------------- **/


/** +++++++++++++++++++ **/
/** CMD_TRIAL_MODERATOR **/
/** +++++++++++++++++++ **/

CMD:a(playerid, params[])
{
	new text[128];
	if (sscanf(params, "s[128]", text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/a [text]");
	SendAdminMessagef(COL_ORANGE, "[A] %s (%d): {FFFFFF}%s", Player[playerid][Name], playerid, text);
	new dcc[256];
	format(dcc, sizeof(dcc), "`#A`  %s (ID %d): %s", Player[playerid][Name], playerid, text);
	DCC_SendChannelMessage(g_Moderation, dcc);
	return true;
}
flags:a(CMD_TRIAL_MODERATOR);


CMD:ip(playerid, params[])
{
	new target;
	if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/ip [player]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	new Country[MAX_COUNTRY_NAME], Region[MAX_COUNTRY_NAME], City[MAX_COUNTRY_NAME], ISP[MAX_COUNTRY_NAME], IP[16];
	GetPlayerCountry(target, Country, sizeof(Country));
	GetPlayerRegion(target, Region, sizeof(Region));
	GetPlayerCity(target, City, sizeof(City));
	GetPlayerISP(target, ISP, sizeof(ISP));
	GetPlayerIp(target, IP, sizeof(IP));
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}%s (%d): %s in %s - %s (%s) from %s", Player[target][Name], target, IP, Country, Region, City, ISP);
	return true;
}
flags:ip(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:serial(playerid, params[])
{
	new target;
	if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/serial [player]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	new serial[40 + 1];
	gpci(target, serial, sizeof(serial));
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}%s (%d): %s", Player[target][Name], target, serial);
	return true;
}
flags:serial(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:forcelobby(playerid, params[])
{
	new target, reason[32];
	if (sscanf(params, "uS(No Reason)[32]", target, reason)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/forcelobby [player] [reason]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	if (Player[target][ModeID] > 1)
	{
		SendAdminModeMessagef(Player[target][ModeID], COL_LIGHTGREY, "[%s] "#EMB_COL_PUNISHMENT"%s has been forced to the lobby by %s (Reason: %s).", Modes[Player[target][ModeID]][Alias], Player[target][Name], Player[playerid][Name], reason);
		OnPlayerJoinMode(target, 1, Player[target][ModeID]);
	}
	else return SendClientMessagef(playerid, COL_ERROR, "[ERROR] {FFFFFF}%s (%d) is already in the lobby.", Player[target][Name], target);
	return true;
}
flags:forcelobby(CMD_TRIAL_MODERATOR | HAS_TARGET);
alias:forcelobby("fl");


CMD:slay(playerid, params[])
{
	new target;
	if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/slay [player]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	if (GetPlayerState(target) == PLAYER_STATE_SPECTATING) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not alive.");
	if (Player[target][ModeID] > 1)
	{
		SendAdminModeMessagef(Player[target][ModeID], COL_LIGHTGREY, "[%s] "#EMB_COL_PUNISHMENT"%s has been slain by %s.", Modes[Player[target][ModeID]][Alias], Player[target][Name], Player[playerid][Name]);
		if (IsPlayerInAnyVehicle(target))
			RemovePlayerFromVehicle(target);
		SetPlayerHealth(target, -1.0);
	}
	else return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is in the lobby.");
	return true;
}
flags:slay(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:mute(playerid, params[])
{
    new target, minutes;
    if (sscanf(params, "ui", target, minutes)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/mute [player] [minutes]");
    if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
    minutes = clamp(minutes, 0, 1000);
    if (!minutes)
    {
        Player[target][Muted] = 0;
        SendClientMessageToAllf(COL_PUNISHMENT, "%s has been unmuted by %s.", Player[target][Name], Player[playerid][Name]);
    }
    else
    {
        Player[target][Muted] = minutes * 60;
        SendClientMessageToAllf(COL_PUNISHMENT, "%s has been muted by %s for %d minutes.", Player[target][Name], Player[playerid][Name], minutes);
    }
    return true;
}
flags:mute(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:warn(playerid, params[])
{
	new target, reason[32];
	if (sscanf(params, "us[32]", target, reason)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/warn [player] [reason]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	new query[256];
	mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_warns (uidWarned, uidAdmin, strAdmin, dtWarned, strReason) VALUES ('%d', '%d', '%e', now(), '%e'); SELECT * FROM core_warns WHERE uidWarned = '%d' and boolEnabled = '1'", Player[target][ID], Player[playerid][ID], Player[playerid][Name], reason, Player[target][ID]);
	mysql_pquery(g_Sql, query, "OnPlayerRecieveWarn", "iis", target, playerid, reason);
	return true;
}
flags:warn(CMD_TRIAL_MODERATOR | HAS_TARGET);

forward OnPlayerRecieveWarn(playerid, admin, reason[]);
public OnPlayerRecieveWarn(playerid, admin, reason[])
{
	cache_set_result(1);
	new rows = cache_num_rows();
	SendClientMessageToAllf(COL_PUNISHMENT, "%s has been warned by %s (Reason: %s) (%d/5).", Player[playerid][Name], Player[admin][Name], reason, rows);
	if (rows == 5)
	{
		SendClientMessageToAllf(COL_PUNISHMENT, "%s has been banned for exceeding the warning threshold (1 Week).", Player[playerid][Name]);

		new query[500], Country[MAX_COUNTRY_NAME], ISP[MAX_COUNTRY_NAME], IP[16], Serial[40 + 1];
		GetPlayerCountry(playerid, Country, sizeof(Country));
		GetPlayerISP(playerid, ISP, sizeof(ISP));
		GetPlayerIp(playerid, IP, sizeof(IP));
		gpci(playerid, Serial, sizeof(Serial));

		mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_bans (strType, strValue, strPlayerName, strReason, uidAdmin, strAdmin, utExpires, strSerial, strIP, strISP, strCountry, dtBanned) VALUES ('uid', '%d', '%e', 'Exceeded Warning Threshold', '%d', '%e', '%d', '%e', '%e', '%e', '%e', now());", Player[playerid][ID], Player[playerid][Name], Player[admin][ID], Player[admin][Name], gettime() + 604800, Serial, IP, ISP, Country);
		mysql_format(g_Sql, query, sizeof(query), "%s UPDATE core_warns SET boolEnabled = '0' WHERE uidWarned = '%d'", query, Player[playerid][ID]);
		mysql_pquery(g_Sql, query);

		Kick(playerid);
	}
}


CMD:warns(playerid, params[])
{
	new target;
	if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/warns [player]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	new query[128];
	mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM core_warns WHERE uidWarned = '%d'", Player[target][ID]);
	mysql_pquery(g_Sql, query, "GetPlayerWarns", "ii", playerid, target);
	return true;
}
flags:warns(CMD_TRIAL_MODERATOR | HAS_TARGET);

forward GetPlayerWarns(playerid, target);
public GetPlayerWarns(playerid, target)
{
	new rows = cache_num_rows();
	if (rows)
	{
		new id, reason[32], admin[MAX_PLAYER_NAME], enabled;
		SendClientMessage(playerid, -1, " ");
		SendClientMessagef(playerid, COL_LIGHTRED, "[ Warnings from %s (ID %d) ]", Player[target][Name], target);
		for (new rowid; rowid < rows; rowid++)
		{
			cache_get_value_name_int(rowid, "uid", id);
			cache_get_value_name(rowid, "strReason", reason);
			cache_get_value_name(rowid, "strAdmin", admin);
			cache_get_value_name_int(rowid, "boolEnabled", enabled);
			SendClientMessagef(playerid, 0xFFFFFFFF, "» "#EMB_COL_INFORMATION"#%d {FFFFFF}given by %s for %s [ %s {FFFFFF}]", id, admin, reason, (enabled == 1 ? (""#EMB_COL_PALLIDGREEN"Active") : (""#EMB_COL_LIGHTRED"Disabled")));
		}
	}
	else
		SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}This user has no active warnings.");
}


CMD:delwarn(playerid, params[])
{
	new target, id;
	if (sscanf(params, "ui", target, id)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/delwarn [player] [warn id ( /warns )]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	new query[128];
	mysql_format(g_Sql, query, sizeof(query), "UPDATE core_warns SET boolEnabled = '0' WHERE uidWarned = '%d' AND uid = '%d' AND boolEnabled = '1'", Player[target][ID], id);
	mysql_pquery(g_Sql, query, "RemovePlayerWarn", "iii", target, playerid, id);
	return true;
}
flags:delwarn(CMD_TRIAL_MODERATOR | HAS_TARGET);

forward RemovePlayerWarn(playerid, admin, id);
public RemovePlayerWarn(playerid, admin, id)
{
	new rows = cache_affected_rows();
	if (rows)
	{
		SendClientMessagef(playerid, COL_PUNISHMENT, "[INFO] {FFFFFF}Your warning #%d has been deleted.", id);
		SendClientMessagef(admin, COL_PUNISHMENT, "[INFO] {FFFFFF}You have removed the warning #%d from %s", id, Player[playerid][Name]);
	}
	else
		SendClientMessage(admin, COL_ERROR, "[ERROR] {FFFFFF}Invalid warning id.");
}


CMD:kick(playerid, params[])
{
	new target, reason[32];
	if (sscanf(params, "us[32]", target, reason)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/kick [player] [reason]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	SendClientMessageToAllf(COL_PUNISHMENT, "%s has been kicked by %s (Reason: %s)", Player[target][Name], Player[playerid][Name], reason);
	Kick(target);
	return true;
}
flags:kick(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:ban(playerid, params[])
{
	new target, reason[32], time, type[2];
	if (sscanf(params, "up<#>s[32]I(-1)C(n)", target, reason, time, type)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/ban [player] [reason]#[time] [type (h,d,w)]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
    if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");

    new expires;

    if (time == -1)
    {
        expires = -1;
        SendClientMessageToAllf(COL_PUNISHMENT, "%s has banned %s for '%s' (Permanent).", Player[playerid][Name], Player[target][Name], reason);
    }
    else if (time > 0)
    {
        expires = gettime();
        if (!strcmp(type, "h", true)) expires += time * 3600;
        else if (!strcmp(type, "d", true)) expires += time * 86400;
        else if (!strcmp(type, "w", true)) expires += time * 604800;
        else return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Invalid type.");
        SendClientMessageToAllf(COL_PUNISHMENT, "%s has banned %s for '%s' (%d%s).", Player[playerid][Name], Player[target][Name], reason, time, type);
    }
    else return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF} Invalid time.");

    new query[500], Country[MAX_COUNTRY_NAME], ISP[MAX_COUNTRY_NAME], IP[16], Serial[40 + 1];
    GetPlayerCountry(target, Country, sizeof(Country));
    GetPlayerISP(target, ISP, sizeof(ISP));
    GetPlayerIp(target, IP, sizeof(IP));
    gpci(target, Serial, sizeof(Serial));

    mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_bans (strType, strValue, strPlayerName, strReason, uidAdmin, strAdmin, utExpires, strSerial, strIP, strISP, strCountry, dtBanned) VALUES ('uid', '%d', '%e', '%s', '%d', '%e', '%d', '%e', '%e', '%e', '%e', now())", Player[target][ID], Player[target][Name], reason, Player[playerid][ID], Player[playerid][Name], expires, Serial, IP, ISP, Country);
    mysql_pquery(g_Sql, query);

    Kick(target);
	return true;
}
flags:ban(CMD_TRIAL_MODERATOR | HAS_TARGET);


CMD:ann(playerid, params[])
{
    new message[128];
    if (sscanf(params, "s[128]", message))
    {
        SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/ann [message]");
        return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "Available presets: eng (local), engg (global)");
    }
    if (!strcmp(message, "eng", true)) SendModeMessage(Player[playerid][ModeID], COL_PUNISHMENT, "[REMINDER] Please speak english the main and global chat!");
    else if (!strcmp(message, "engg", true)) SendClientMessageToAll(COL_PUNISHMENT, "[REMINDER] Please speak english the main and global chat!");
    else
    {
        if (Player[playerid][AdminLevel] < 4) return false;
        SendClientMessageToAllf(COL_PUNISHMENT, "[ANNOUNCEMENT] %s", message);
    }
    return true;
}


CMD:specmode(playerid, params[])
{
	if (Player[playerid][ModeID] == 0)
		OnPlayerJoinMode(playerid, 1, Player[playerid][ModeID]);
	else
	{
		OnPlayerJoinMode(playerid, 0, Player[playerid][ModeID]);
		Player[playerid][Spectating] = true;
		if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
			TogglePlayerSpectating(playerid, false);
		TogglePlayerSpectating(playerid, true);
	}
	return true;
}
flags:specmode(CMD_TRIAL_MODERATOR);


/** ++++++++++++++++++++ **/
/** CMD_SENIOR_MODERATOR **/
/** ++++++++++++++++++++ **/

CMD:emptymode(playerid, params[])
{
	new target[8], reason[32];
	if (sscanf(params, "s[8]s[32]", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/emptymode [mode] [reason]");
	for (new modeid; modeid < MAX_MODES; modeid++)
	{
	    if (strcmp(Modes[modeid][Alias], target, true) == 0)
		{
			if (modeid <= 1)
			{
				SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Invalid mode.");
				break;
			}
			SendAdminModeMessagef(modeid, COL_LIGHTGREY, "[%s] "#EMB_COL_PUNISHMENT"%s has forced all players to the lobby (Reason: %s).", Modes[modeid][Alias], Player[playerid][Name], reason);
			for (new targetp, j = GetPlayerPoolSize(); targetp <= j; targetp++)
			{
				if (!IsPlayerConnected(targetp) || !Player[targetp][IsLoggedIn] || Player[targetp][ModeID] != modeid)
					continue;
				OnPlayerJoinMode(targetp, 1, modeid);
			}
			break;
	    }
	}
	return true;
}
flags:emptymode(CMD_SENIOR_MODERATOR);


CMD:lockmode(playerid, params[])
{
    new target[8];
    if (sscanf(params, "s[8]", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/lockmode [mode]");
    for (new modeid; modeid < MAX_MODES; modeid++)
    {
        if (strcmp(Modes[modeid][Alias], target, true) == 0)
        {
            if (modeid <= 1)
            {
                SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Invalid mode");
                break;
            }
            Modes[modeid][Locked] = !Modes[modeid][Locked];
            SendAdminModeMessagef(modeid, COL_LIGHTRED, "[%s] "#EMB_COL_PUNISHMENT"%s has %s this mode.", Modes[modeid][Alias], Player[playerid][Name], (Modes[modeid][Locked] == true ? ("locked") : ("unlocked")));
            break;
        }
    }
    return true;
}
flags:lockmode(CMD_SENIOR_MODERATOR);


CMD:setnextmap(playerid, params[])
{
	if (!Modes[Player[playerid][ModeID]][HasQueue]) return false;
	new search[128];
	if (sscanf(params, "s[128]", search)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/setnextmap [(part of) name / author(s)]");
	new query[256];
	mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_mapqueue WHERE strMode = '%e'; SELECT * FROM module_maps WHERE strMode = '%e' AND (strMapAuthor LIKE '%%%e%%' OR strMapName LIKE '%%%e%%')", Modes[Player[playerid][ModeID]][Alias], Modes[Player[playerid][ModeID]][Alias], search, search);
	mysql_pquery(g_Sql, query, "OnPlayerNextmapRequest", "ii", playerid, true);
	return true;
}
flags:setnextmap(CMD_SENIOR_MODERATOR);


CMD:redo(playerid, params[])
{
    if (!Modes[Player[playerid][ModeID]][HasQueue]) return false;
    CallLocalFunction("RequestMapRedo", "ii", playerid, Player[playerid][ModeID]);
    return true;
}
flags:redo(CMD_SENIOR_MODERATOR);


/** ++++++++++++++++++ **/
/** CMD_LEAD_MODERATOR **/
/** ++++++++++++++++++ **/

CMD:setadmin(playerid, params[])
{
	new target, level;
	if (sscanf(params, "ui", target, level)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/setadmin [player] [rank]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	if (level >= sizeof(Ranks)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Invalid rank.");
	if ((playerid == target && Player[playerid][AdminLevel] <= level) || (playerid != target && Player[playerid][AdminLevel] < Player[target][AdminLevel])) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't do that...");

	Player[target][AdminLevel] = level;
	orm_save(Player[target][ORM_ID]);

	SendClientMessagef(playerid, COL_PUNISHMENT, "[INFO] {FFFFFF}You have set the rank from {%06x}%s{FFFFFF} to %s.", GetPlayerColor(target) >>> 8, Player[target][Name], Ranks[level]);
	if (target != playerid)
		SendClientMessagef(target, COL_PUNISHMENT, "[INFO] {%06x}%s{FFFFFF} has set your rank to %s.", GetPlayerColor(playerid) >>> 8, Player[playerid][Name], Ranks[level]);
	return true;
}
flags:setadmin(CMD_LEAD_MODERATOR | HAS_TARGET);


CMD:serialban(playerid, params[])
{
	new serial[40 + 1], reason[32];
	if (sscanf(params, "s[41]s[32]", serial, reason)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/serialban [serial] [reason]");
	new query[320];
	mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_bans (strType, strValue, strPlayerName, strReason, uidAdmin, strAdmin, utExpires, strSerial, strIP, strISP, strCountry, dtBanned) VALUES ('serial', '%e', '*', '%e', '%d', '%e', '-1', 'NULL', 'NULL', 'NULL', 'NULL', now())", serial, reason, Player[playerid][ID], Player[playerid][Name]);
	mysql_pquery(g_Sql, query);
	SendClientMessagef(playerid, COL_PUNISHMENT, "Serial ban for '%s' has been added.", serial);
	return true;
}
flags:serialban(CMD_LEAD_MODERATOR);


CMD:rserialban(playerid, params[])
{
	new serial[40 + 1];
	if (sscanf(params, "s[41]", serial)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/rserialban [serial]");
	new query[256];
	mysql_format(g_Sql, query, sizeof(query), "DELETE FROM core_bans WHERE strType = 'serial' AND strValue = '%e'", serial);
	mysql_pquery(g_Sql, query);
	SendClientMessage(playerid, COL_PUNISHMENT, "Serial ban has been removed (if it existed.. , im too lazy to check if it actually did.)");
	return true;
}
flags:rserialban(CMD_LEAD_MODERATOR);


/** +++++++++++++++++ **/
/** CMD_ADMINISTRATOR **/
/** +++++++++++++++++ **/

CMD:cdebug(playerid, params[])
{
	if (HasPlayerConsoleMessages(playerid))
	{
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You no longer recieve console messages.");
		DisableConsoleMSGsForPlayer(playerid);
	}
	else
	{
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Console messages enabled.");
		EnableConsoleMSGsForPlayer(playerid, COL_LIGHTGREY);
	}
	return true;
}
flags:cdebug(CMD_ADMINISTRATOR);


CMD:findchannels(playerid, params[])
{
	g_Echo = DCC_FindChannelByName("newdawn");
	g_Moderation = DCC_FindChannelById("moderation");
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Found #newdawn <%d> and #moderation <%d>", _:g_Echo, _:g_Moderation);
	return true;
}
flags:findchannels(CMD_ADMINISTRATOR);


/** -------------------------- **/
/** M O D E R A T I O N  E N D **/
/** -------------------------- **/

CMD:menu(playerid, params[])
{
	if (Player[playerid][ModeID] == 1)
		return false;
	OnPlayerJoinMode(playerid, 1, Player[playerid][ModeID]);
	return true;
}
flags:menu(SPAM_PENALTY_EXCEPTION);
alias:menu("lobby");


CMD:nick(playerid, params[])
{
	new newnick[MAX_PLAYER_NAME];
	if (sscanf(params, "s[MAX_PLAYER_NAME]", newnick)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/nick [new name]");
	if (regex_match(newnick, "[A-z0-9@=_[\\].()$#<>!]{3,24}$"))
	{
        new query[128];
        mysql_format(g_Sql, query, sizeof(query), "SELECT uid FROM core_playerinfo WHERE strPlayerName = '%e'", newnick);
        mysql_pquery(g_Sql, query, "CheckPlayerName", "ds", playerid, newnick);
	}
	else return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[ERROR] {FFFFFF}Invalid name! Valid characters: A-z0-9@=_[]()$#<>!");
	return true;
}

forward CheckPlayerName(playerid, newnick[]);
public CheckPlayerName(playerid, newnick[])
{
    new rows = cache_num_rows();
    if (rows)
    {
        SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}This name is already being used.");
    }
    else
    {
        new query[512];
        mysql_format(g_Sql, query, sizeof(query), "UPDATE module_huntertimes SET strPlayerName = '%e' WHERE intUserID = '%d'; INSERT INTO core_namechanges (intUID, strPreviousName, strNewName, dtChanged) VALUES ('%d', '%e', '%e', now())", newnick, Player[playerid][ID], Player[playerid][ID], Player[playerid][Name], newnick);
        if (Player[playerid][AdminLevel])
            mysql_format(g_Sql, query, sizeof(query), "%s; UPDATE core_warns SET strAdmin = '%e' WHERE uidAdmin = '%d'; UPDATE core_bans SET strAdmin = '%e' WHERE uidAdmin = '%d'", query, newnick, Player[playerid][ID], newnick, Player[playerid][ID]);
        mysql_pquery(g_Sql, query);

		SendClientMessageToAllf(COL_LIGHTGREY, "%s is now known as %s.", Player[playerid][Name], newnick);
		SetPlayerName(playerid, newnick);
		GetPlayerName(playerid, Player[playerid][Name], MAX_PLAYER_NAME);
		orm_save(Player[playerid][ORM_ID]);
    }
    return true;
}


CMD:changepassword(playerid, params[])
{
    ShowPlayerDialog(playerid, DIALOG_CHANGEPASSWORD_OLD, DIALOG_STYLE_INPUT, "Password Change", "Please enter your current password:", "Next", "Cancel");
    return true;
}
flags:changepassword(SPAM_PENALTY_EXCEPTION);


CMD:g(playerid, params[])
{
    if (Player[playerid][Muted]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You are muted.");
	new text[128];
	if (sscanf(params,"s[128]",text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/g [text]");
	for (new target, j = GetPlayerPoolSize(); target <= j; target++)
	{
		if (!IsPlayerConnected(target) || !Player[target][IsLoggedIn] || !Player[target][GlobalChat])
			continue;
		SendClientMessagef(target, COL_LIGHTGREY, "[ALL] {%06x}%s (%d): {FFFFFF}%s", GetPlayerColor(playerid)  >>> 8, Player[playerid][Name], playerid, text);
	}
    new dcc[256];
	format(dcc, sizeof(dcc), "`#G`  %s (ID %d): %s", Player[playerid][Name], playerid, text);
	DCC_SendChannelMessage(g_Echo, dcc);
	return true;
}
alias:g("all");


CMD:togglobal(playerid, params[])
{
	Player[playerid][GlobalChat] = !Player[playerid][GlobalChat];
	orm_save(Player[playerid][ORM_ID]);
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}The global chat is now %s for you.", (Player[playerid][GlobalChat] == true ? ("enabled") : ("disabled")));
	return true;
}


CMD:donate(playerid, params[])
{
    new target, amount;
    if (sscanf(params, "ui", target, amount)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/donate [player] [amount]");
    if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
    if (playerid == target) return SendClientMessage(playerid, COL_ERROR, "[0x] {FFFFFF}Nuh'uh");
    if (amount < 100 || amount > Player[playerid][Money]) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[ERROR] {FFFFFF}Invalid amount.");

    Player[playerid][Money] -= amount;
    UpdatePlayerMoneyOverlay(playerid);
    orm_save(Player[playerid][ORM_ID]);

    Player[target][Money] += amount;
    UpdatePlayerMoneyOverlay(target);
    orm_save(Player[target][ORM_ID]);

    SendModeMessagef(Player[playerid][ModeID], 0xFFFFFFFF, "%s has given "#EMB_COL_GREEN"$%d{FFFFFF} to %s", Player[playerid][Name], amount, Player[target][Name]);
    if (Player[target][ModeID] != Player[playerid][ModeID])
        SendModeMessagef(Player[target][ModeID], 0xFFFFFFFF, "%s has given "#EMB_COL_GREEN"$%d{FFFFFF} to %s", Player[playerid][Name], amount, Player[target][Name]);
    return true;
}
flags:donate(HAS_TARGET);
alias:donate("pay");


CMD:togpm(playerid, params[])
{
    Player[playerid][PM] = !Player[playerid][PM];
	orm_save(Player[playerid][ORM_ID]);
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Your private messages are now %s.", (Player[playerid][PM] == true ? ("enabled") : ("disabled")));
    return true;
}

static bool:IsBlocked[MAX_PLAYERS][MAX_PLAYERS];
CMD:blockpm(playerid, params[])
{
    new target;
    if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/blockpm [player]");
    if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
    if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
    if (target == playerid || Player[target][AdminLevel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't do that...");
    IsBlocked[target][playerid] = !IsBlocked[target][playerid];
    SendClientMessagef(playerid, COL_GREEN, "You now %s private messages from %s (%d).", (IsBlocked[target][playerid] == true ? ("block") : ("allow")), Player[target][Name], target);
    return true;
}
flags:blockpm(HAS_TARGET);

static LastPM[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
		LastPMTimestamp[MAX_PLAYERS];
CMD:pm(playerid, params[])
{
	new target, text[128];
	if (sscanf(params, "us[128]", target, text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/pm [player] [text]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	if (playerid == target) return SendClientMessage(playerid, COL_ERROR, "[YOUR MOM] {FFFFFF}Do you want to talk about it ... ?");
    if (!Player[target][PM] && !Player[playerid][AdminLevel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player has disabled his private messages.");
    if (IsBlocked[playerid][target]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player does not want to recieve private messages from you.");

	SendClientMessagef(target, COL_LIGHTGREY, "PM FROM: {DABB3E}%s (%d): %s", Player[playerid][Name], playerid, text);
	SendClientMessagef(playerid, COL_LIGHTGREY, "PM TO: {DABB3E}%s (%d): %s", Player[target][Name], target, text);

	LastPM[target] = playerid;
	LastPM[playerid] = target;
	LastPMTimestamp[target] = gettime();
	LastPMTimestamp[playerid] = gettime();
	return true;
}
flags:pm(HAS_TARGET);

CMD:r(playerid, params[])
{
	if (LastPM[playerid] == INVALID_PLAYER_ID || gettime() - LastPMTimestamp[playerid] >= 20000) return false;

	new target = LastPM[playerid], text[128];
	if (sscanf(params, "s[128]", text)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[ERROR] {FFFFFF}/r [text]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
    if (!Player[target][PM] && !Player[playerid][AdminLevel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player has disabled his private messages.");
    if (IsBlocked[playerid][target]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player does not want to recieve private messages from you.");

	SendClientMessagef(target, COL_LIGHTGREY, "PM FROM: {DABB3E}%s (%d): %s", Player[playerid][Name], playerid, text);
	SendClientMessagef(playerid, COL_LIGHTGREY, "PM TO: {DABB3E}%s (%d): %s", Player[target][Name], target, text);

	LastPM[target] = playerid;
	LastPM[playerid] = target;
	LastPMTimestamp[target] = gettime();
	LastPMTimestamp[playerid] = gettime();
	return true;
}
alias:r("reply");

Hook:LASTPM_OnPlayerDisconnect(playerid, reason[])
{
	if (LastPM[playerid] != INVALID_PLAYER_ID)
	{
		LastPM[playerid] = INVALID_PLAYER_ID;
		LastPMTimestamp[playerid] = 0;
		if (gettime() - LastPMTimestamp[playerid] <= 20000 && LastPM[LastPM[playerid]] == playerid)
		{
			LastPM[LastPM[playerid]] = INVALID_PLAYER_ID;
			LastPMTimestamp[LastPM[playerid]] = 0;
		}
	}
    for (new i; i < MAX_PLAYERS; i++)
    {
        IsBlocked[playerid][i] = false;
        IsBlocked[i][playerid] = false;
    }
	return true;
}


CMD:id(playerid, params[])
{
	new target;
	if (sscanf(params, "u", target)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/id [player]");
	if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
	SendClientMessagef(playerid, 0xFFFFFFFF, "» "#EMB_COL_INFORMATION"%s (%d) {FFFFFF}in %s", Player[target][Name], target, Modes[Player[target][ModeID]][Name]);
	return true;
}
flags:id(HAS_TARGET);


CMD:admins(playerid, params[])
{
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, COL_LIGHTRED, "[ Staff Online ]");
	for (new pid, j = GetPlayerPoolSize(); pid <= j; pid++)
	{
		if (!IsPlayerConnected(pid) || !Player[pid][IsLoggedIn] || !Player[pid][AdminLevel])
			continue;
		SendClientMessagef(playerid, 0xFFFFFFFF, "» "#EMB_COL_INFORMATION"%s (%d) {FFFFFF}in %s (%s)", Player[pid][Name], pid, Modes[Player[pid][ModeID]][Name], Ranks[Player[pid][AdminLevel]]);
	}
	return true;
}
alias:admins("staff");


CMD:report(playerid, params[])
{
    if (Player[playerid][AdminLevel]) return SendClientMessage(playerid, COL_PUNISHMENT, "[INFRA] {FFFFFF}Fuck you.");
    new target, reason[64];
    if (sscanf(params, "us[64]", target, reason)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/report [player] [reason]");
    if (!IsPlayerConnected(target)) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not online.");
	if (!Player[target][IsLoggedIn]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The player is not logged in.");
    if (target == playerid || Player[playerid][AdminLevel]) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You can't do that...");
    SendAdminMessagef(COL_LIGHTRED, "[REPORT] %s (%d) has reported %s (%d) for %s.", Player[playerid][Name], playerid, Player[target][Name], target, reason);
    SendClientMessagef(playerid, COL_GREEN, "You have reported %s (%d) for %s.", Player[target][Name], target, reason);
    return true;
}
flags:report(HAS_TARGET);


CMD:m(playerid, params[])
{
    new string[16];
    if (sscanf(params, "s[16]", string)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/m [Off | Map | Player]");
    if (!strcmp(string, "Off", true))
    {
        Player[playerid][MusicType] = 0;
        StopAudioStreamForPlayer(playerid);
        Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You are no longer listening to music.");
    }
    else if (!strcmp(string, "Map", true))
    {
        StopAudioStreamForPlayer(playerid);
        Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
        Player[playerid][MusicType] = 1;
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You are now listening to the "#EMB_COL_INFORMATION"map music{FFFFFF}.");
    }
    else if (!strcmp(string, "Player", true))
    {
        StopAudioStreamForPlayer(playerid);
        Audio_Stop(playerid, GetPVarInt(playerid, "audio.stream"));
        SetPlayerChannel(playerid, 0);
        Player[playerid][MusicType] = 2;
		SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}You are now listening to the "#EMB_COL_INFORMATION"music player{FFFFFF}.");
    }
	orm_save(Player[playerid][ORM_ID]);
    return true;
}


CMD:skin(playerid, params[])
{
	new skin;
	if (sscanf(params, "i", skin)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/skin [id]");
	if (skin >= 0 && skin <= 311)
	{
		Player[playerid][Skin] = skin;
		orm_save(Player[playerid][ORM_ID]);
		SetPlayerSkin(playerid, skin);
		SetSpawnInfo(playerid, 0, Player[playerid][Skin], 1093.000000,-2036.000000,90.000000, 0.0, 0, 0, 0, 0, 0, 0);
		SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Your skin has been set to %d.", skin);
	}
	else return SendClientMessage(playerid, COL_ERROR, "[ERROR] Invalid skin.");
	return true;
}


CMD:virtualworld(playerid, params[])
{
	new virtualworld;
	if (sscanf(params, "i", virtualworld)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/virtualworld [0-64]");
	if (virtualworld < 0 || virtualworld > 64) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Only worlds 0-64 are available.");
	Player[playerid][VW] = virtualworld;
	orm_save(Player[playerid][ORM_ID]);
	SendClientMessagef(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Your virtual world has been set to %d.", virtualworld);
	CallLocalFunction("RequestVirtualWorld", "i", playerid);
	return true;
}


CMD:nextmap(playerid, params[])
{
	if (!Modes[Player[playerid][ModeID]][HasQueue]) return false;
	new search[128];
	if (sscanf(params, "s[128]", search)) return SendClientMessage(playerid, COL_SYNTAX_REMINDER, "[USAGE] {FFFFFF}/nextmap [(part of) name / author(s)]");
	new query[256];
	mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_mapqueue WHERE strMode = '%e'; SELECT * FROM module_maps WHERE strMode = '%e' AND (strMapAuthor LIKE '%%%e%%' OR strMapName LIKE '%%%e%%')", Modes[Player[playerid][ModeID]][Alias], Modes[Player[playerid][ModeID]][Alias], search, search);
	mysql_pquery(g_Sql, query, "OnPlayerNextmapRequest", "ii", playerid, false);
	return true;
}

public OnPlayerNextmapRequest(playerid, bool:adminset)
{
	cache_set_result(0);
	new qrows = cache_num_rows(),
		QueueMapID[5];

	if (qrows >= 3 && !adminset)
		return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}The map queue is full.");

	if (qrows >= 5 && adminset)
		return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Queue limit has been reached.");

	for (new qrowid; qrowid < qrows; qrowid++)
	{
		cache_get_value_name_int(qrowid, "intMapID", QueueMapID[qrowid]);
	}

	if ((!adminset && (!qrows || qrows < 3)) || adminset)
	{
		cache_set_result(1);
		new mrows = cache_num_rows();
		if (!mrows)
			return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}Could not find any map.");

		new mID[16], lastBought[15], bool:inQueue[15], strName[128], strAuthor[128], strFilePointer[256], query[256];

		for (new rowid; rowid < mrows; rowid++)
		{
			cache_get_value_name_int(rowid, "uid", mID[rowid]);
			cache_get_value_name_int(rowid, "intLastBought", lastBought[rowid]);

			for (new qrowid; qrowid < qrows; qrowid++) { if (QueueMapID[qrowid] == mID[rowid]) { inQueue[rowid] = true; break; } }

			if (rowid == 14)
				break;
		}

		if (mrows == 1)
		{
			if (!adminset)
			{
                if (Player[playerid][Money] < 2000)
                    return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You need atleast $2000 to purchase a map.");
				if (inQueue[0])
					return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}This map is already in the queue.");
				if (gettime() - lastBought[0] < 600)
					return SendClientMessagef(playerid, COL_ERROR, "[ERROR] {FFFFFF}This map has been bought recently, it's available again in %02dm %02ds.", floatround((600 - (gettime() - lastBought[0])) / 60, floatround_floor), floatround((600 - (gettime() - lastBought[0])) % 60, floatround_floor));
                Player[playerid][Money] -= 2000;
                UpdatePlayerMoneyOverlay(playerid);
                orm_save(Player[playerid][ORM_ID]);
            }
			cache_get_value_name(0, "strMapName", strName);
			cache_get_value_name(0, "strMapAuthor", strAuthor);
			cache_get_value_name(0, "strFilePointer", strFilePointer);

			if (!adminset || (adminset && !qrows))
				mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_mapqueue (strMode, strMapName, strMapAuthor, intMapID, intAdminSet) VALUES ('%e', '%e', '%e', '%d', '%d')", Modes[Player[playerid][ModeID]][Alias], strName, strAuthor, mID[0], adminset);
			else if(adminset && qrows)
			{
				cache_set_result(0);
				new lowestID;
				cache_get_value_name_int(0, "uid", lowestID);
				cache_set_result(1);
				mysql_format(g_Sql, query, sizeof(query), "INSERT INTO module_mapqueue (uid, strMode, strMapName, strMapAuthor, intMapID, intAdminSet) VALUES ('%d', '%e', '%e', '%e', '%d', '%d')", lowestID - 1, Modes[Player[playerid][ModeID]][Alias], strName, strAuthor, mID[0], adminset);
			}
			mysql_pquery(g_Sql, query, "OnPlayerSetNextmap", "iissii", playerid, qrows, strName, strAuthor, mID[0], adminset);
		}
		else if (mrows > 1)
		{
			new string[1024];
			format(string, sizeof(string), "#\tAuthor\tName\tStatus\n");
			for (new rowid; rowid < mrows; rowid++)
			{
				cache_get_value_name(rowid, "strMapName", strName);
				cache_get_value_name(rowid, "strMapAuthor", strAuthor);
				cache_get_value_name(rowid, "strFilePointer", strFilePointer);
				if (gettime() - lastBought[rowid] < 600)
					format(string, sizeof(string), "%s%d\t%s\t%s\t"#EMB_COL_LIGHTRED"%02dm %02ds\n", string, mID[rowid], strAuthor, strName, floatround((600 - (gettime() - lastBought[rowid])) / 60, floatround_floor), floatround((600 - (gettime() - lastBought[rowid])) % 60, floatround_floor));
				else if (inQueue[rowid])
					format(string, sizeof(string), "%s%d\t%s\t%s\t"#EMB_COL_ORANGE"In Queue\n", string, mID[rowid], strAuthor, strName);
				else
					format(string, sizeof(string), "%s%d\t%s\t%s\t"#EMB_COL_PALLIDGREEN"Available\n", string, mID[rowid], strAuthor, strName);
				if (rowid == 14)
                {
                    if (mrows > 15)
                        format(string, sizeof(string), "%s \n{B9C9BF}%d more results...", string, mrows - 15);
					break;
                }
			}
			if (!adminset)
				ShowPlayerDialog(playerid, DIALOG_MAP_SEARCH_RESULTS, DIALOG_STYLE_TABLIST_HEADERS, "Search Results", string, "Set ($2000)", "Cancel");
			else
				ShowPlayerDialog(playerid, DIALOG_ADMIN_MAP_SEARCH_RESULTS, DIALOG_STYLE_TABLIST_HEADERS, "Search Results", string, "Set", "Cancel");
		}
	}
	return true;
}

Hook:CMD_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid == DIALOG_MAP_SEARCH_RESULTS || dialogid == DIALOG_ADMIN_MAP_SEARCH_RESULTS)
	{
		if (response && listitem <= 14)
		{
            if (Player[playerid][Money] < 2000 && dialogid == DIALOG_MAP_SEARCH_RESULTS) return SendClientMessage(playerid, COL_ERROR, "[ERROR] {FFFFFF}You need atleast $2000 to purchase a map.");
			new query[128], inputval = strval(inputtext);
			mysql_format(g_Sql, query, sizeof(query), "SELECT * FROM module_mapqueue WHERE strMode = '%e'; SELECT * FROM module_maps WHERE strMode = '%e' AND uid = '%d'", Modes[Player[playerid][ModeID]][Alias], Modes[Player[playerid][ModeID]][Alias], inputval);
			mysql_pquery(g_Sql, query, "OnPlayerNextmapRequest", "ii", playerid, (dialogid == DIALOG_ADMIN_MAP_SEARCH_RESULTS ? true : false));
		}
	}
    else if (dialogid == DIALOG_CHANGEPASSWORD_OLD)
    {
        if (response && strlen(inputtext))
        {
            new query[256], hash[SHA512_LENGTH + 1];
            sha512(inputtext, hash);
            mysql_format(g_Sql, query, sizeof(query), "SELECT uid FROM core_playerinfo WHERE uid = '%d' AND strPassword = '%e'", Player[playerid][ID], hash);
            mysql_pquery(g_Sql, query, "OnPlayerChangePasswordCheck", "i", playerid);
        }
        else if (!strlen(inputtext))
            PC_EmulateCommand(playerid, "/changepassword");
    }
    else if (dialogid == DIALOG_CHANGEPASSWORD_NEW)
    {
        if (response && strlen(inputtext) > 5)
        {
            new query[256], hash[SHA512_LENGTH + 1];
            sha512(inputtext, hash);
            mysql_format(g_Sql, query, sizeof(query), "UPDATE core_playerinfo SET strPassword = '%e' WHERE uid = '%d'", hash, Player[playerid][ID]);
            mysql_pquery(g_Sql, query);
            SendClientMessage(playerid, COL_INFORMATION, "[INFO] {FFFFFF}Your password has been changed.");
        }
        else if (strlen(inputtext) < 5)
            ShowPlayerDialog(playerid, DIALOG_CHANGEPASSWORD_NEW, DIALOG_STYLE_INPUT, "Password Change", "Please enter your new password:", "Change", "Cancel");
    }
	return true;
}

forward OnPlayerChangePasswordCheck(playerid);
public OnPlayerChangePasswordCheck(playerid)
{
    new rows = cache_num_rows();
    if (rows)
        ShowPlayerDialog(playerid, DIALOG_CHANGEPASSWORD_NEW, DIALOG_STYLE_INPUT, "Password Change", "Please enter your new password:", "Change", "Cancel");
    else
        PC_EmulateCommand(playerid, "/changepassword");
}
