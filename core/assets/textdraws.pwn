new Text:TD_Lobby[4],
	Text:SKEW_BANNER,
	PlayerText:SKEW_BANNER_TEXT_CB[MAX_PLAYERS],

	Text:MoneyTD_First, Text:MoneyTD_Last,
	Text:MoneyTD_Health_First, Text:MoneyTD_Health_Last,
	PlayerText:MoneyTD_Value[MAX_PLAYERS],
	PlayerText:MoneyTD_Health_Value[MAX_PLAYERS],
	PlayerText:MoneyTD_Health_Background[MAX_PLAYERS];

forward CreateRaceGUI();

Hook:TD_OnGameModeInit()
{
	new Text:TD;

	// ========== Start Lobby ==========
	TD_Lobby[0] = TextDrawCreate(320 - (LOBBY_LENGTH/2), 100.0, "LD_SPAC:white");
	TextDrawLetterSize(TD_Lobby[0], 0.000000, 0.000000);
	TextDrawTextSize(TD_Lobby[0], LOBBY_LENGTH, 3.000000);
	TextDrawAlignment(TD_Lobby[0], 1);
	TextDrawColor(TD_Lobby[0], 674910207);
	TextDrawSetShadow(TD_Lobby[0], 0);
	TextDrawSetOutline(TD_Lobby[0], 0);
	TextDrawBackgroundColor(TD_Lobby[0], 255);
	TextDrawFont(TD_Lobby[0], 4);
	TextDrawSetProportional(TD_Lobby[0], 0);
	TextDrawSetShadow(TD_Lobby[0], 0);

	TD_Lobby[1] = TextDrawCreate(320 - (LOBBY_LENGTH/2), 102.99, "LD_SPAC:white");
	TextDrawLetterSize(TD_Lobby[1], 0.000000, 0.000000);
	TextDrawTextSize(TD_Lobby[1], LOBBY_LENGTH, 22.000000);
	TextDrawAlignment(TD_Lobby[1], 1);
	TextDrawColor(TD_Lobby[1], 128);
	TextDrawSetShadow(TD_Lobby[1], 0);
	TextDrawSetOutline(TD_Lobby[1], 0);
	TextDrawBackgroundColor(TD_Lobby[1], 255);
	TextDrawFont(TD_Lobby[1], 4);
	TextDrawSetProportional(TD_Lobby[1], 0);
	TextDrawSetShadow(TD_Lobby[1], 0);

	TD_Lobby[2] = TextDrawCreate(320 - (LOBBY_LENGTH/2) + 5.0, 105.583312, "~w~NEW_DAWN");
	TextDrawLetterSize(TD_Lobby[2], 0.185883, 1.028329);
	TextDrawAlignment(TD_Lobby[2], 1);
	TextDrawColor(TD_Lobby[2], -1);
	TextDrawSetShadow(TD_Lobby[2], 0);
	TextDrawSetOutline(TD_Lobby[2], 0);
	TextDrawBackgroundColor(TD_Lobby[2], 255);
	TextDrawFont(TD_Lobby[2], 2);
	TextDrawSetProportional(TD_Lobby[2], 1);
	TextDrawSetShadow(TD_Lobby[2], 0);

	TD_Lobby[3] = TextDrawCreate(320 - (LOBBY_LENGTH/2) + 5.0, 114.500015, "~y~Version_3.0");
	TextDrawLetterSize(TD_Lobby[3], 0.167144, 0.952497);
	TextDrawAlignment(TD_Lobby[3], 1);
	TextDrawColor(TD_Lobby[3], -1);
	TextDrawSetShadow(TD_Lobby[3], 0);
	TextDrawSetOutline(TD_Lobby[3], 0);
	TextDrawBackgroundColor(TD_Lobby[3], 255);
	TextDrawFont(TD_Lobby[3], 1);
	TextDrawSetProportional(TD_Lobby[3], 1);
	TextDrawSetShadow(TD_Lobby[3], 0);
	// ========== End Lobby ==========

	SKEW_BANNER = TextDrawCreate(-17.666658, 105.300109, "");
	TextDrawLetterSize(SKEW_BANNER, 0.000000, 0.000000);
	TextDrawTextSize(SKEW_BANNER, 668.000061, 86.266624);
	TextDrawAlignment(SKEW_BANNER, 1);
	TextDrawColor(SKEW_BANNER, 88);
	TextDrawBackgroundColor(SKEW_BANNER, 0);
	TextDrawFont(SKEW_BANNER, 5);
	TextDrawSetPreviewModel(SKEW_BANNER, 19454);
	TextDrawSetPreviewRot(SKEW_BANNER, 0.000000, 0.000000, 70.000000, 0.375391);

	// ========== Start Money ==========
	MoneyTD_Health_First = TextDrawCreate(544.768005, 67.683692, "box");
	TextDrawLetterSize(MoneyTD_Health_First, 0.000000, 1.083961);
	TextDrawTextSize(MoneyTD_Health_First, 616.793090, 0.000000);
	TextDrawAlignment(MoneyTD_Health_First, 1);
	TextDrawColor(MoneyTD_Health_First, -1);
	TextDrawUseBox(MoneyTD_Health_First, 1);
	TextDrawBoxColor(MoneyTD_Health_First, 674910207);
	TextDrawBackgroundColor(MoneyTD_Health_First, 255);
	TextDrawFont(MoneyTD_Health_First, 1);

	TD = TextDrawCreate(544.812377, 67.566841, "");
	TextDrawLetterSize(TD, 0.000000, 0.000000);
	TextDrawTextSize(TD, 72.189826, 8.629965);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 5);
	TextDrawSetProportional(TD, 0);
	TextDrawSetShadow(TD, 0);
	TextDrawSetPreviewModel(TD, 899);
	TextDrawSetPreviewRot(TD, 0.000000, 0.000000, 0.000000, -0.007331);

	MoneyTD_Health_Last = TextDrawCreate(546.150329, 69.283332, "box");
	TextDrawLetterSize(MoneyTD_Health_Last, 0.000000, 0.583166);
	TextDrawTextSize(MoneyTD_Health_Last, 615.684082, 0.000000);
	TextDrawAlignment(MoneyTD_Health_Last, 1);
	TextDrawColor(MoneyTD_Health_Last, -1);
	TextDrawUseBox(MoneyTD_Health_Last, 1);
	TextDrawBoxColor(MoneyTD_Health_Last, 220);
	TextDrawBackgroundColor(MoneyTD_Health_Last, 255);
	TextDrawFont(MoneyTD_Health_Last, 1);


	MoneyTD_First = TextDrawCreate(489.996032, 78.900016, "box");
	TextDrawLetterSize(MoneyTD_First, 0.000000, 2.277832);
	TextDrawTextSize(MoneyTD_First, 616.980468, 0.000000);
	TextDrawAlignment(MoneyTD_First, 1);
	TextDrawColor(MoneyTD_First, -1);
	TextDrawUseBox(MoneyTD_First, 1);
	TextDrawBoxColor(MoneyTD_First, 674910207);
	TextDrawBackgroundColor(MoneyTD_First, 255);
	TextDrawFont(MoneyTD_First, 1);

	TD = TextDrawCreate(489.769866, 78.250091, "");
	TextDrawLetterSize(TD, 0.000000, 0.000000);
	TextDrawTextSize(TD, 127.632118, 21.749971);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 5);
	TextDrawSetProportional(TD, 0);
	TextDrawSetShadow(TD, 0);
	TextDrawSetPreviewModel(TD, 899);
	TextDrawSetPreviewRot(TD, 0.000000, 0.000000, 0.000000, -0.007331);

	MoneyTD_Last = TextDrawCreate(491.096099, 80.000000, "box");
	TextDrawLetterSize(MoneyTD_Last, 0.000000, 2.035140);
	TextDrawTextSize(MoneyTD_Last, 616.099975, 0.000000);
	TextDrawAlignment(MoneyTD_Last, 1);
	TextDrawColor(MoneyTD_Last, -1);
	TextDrawUseBox(MoneyTD_Last, 1);
	TextDrawBoxColor(MoneyTD_Last, 220);
	TextDrawBackgroundColor(MoneyTD_Last, 255);
	TextDrawFont(MoneyTD_Last, 1);
	// ========== End Money ==========
	return true;
}

Hook:TD_OnPlayerConnect(playerid)
{
	SKEW_BANNER_TEXT_CB[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 130.000000, "3");
	PlayerTextDrawLetterSize(playerid, SKEW_BANNER_TEXT_CB[playerid], 0.730997, 3.043555);
	PlayerTextDrawAlignment(playerid, SKEW_BANNER_TEXT_CB[playerid], 2);
	PlayerTextDrawColor(playerid, SKEW_BANNER_TEXT_CB[playerid], -76);
	PlayerTextDrawSetShadow(playerid, SKEW_BANNER_TEXT_CB[playerid], 0);
	PlayerTextDrawSetOutline(playerid, SKEW_BANNER_TEXT_CB[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, SKEW_BANNER_TEXT_CB[playerid], 255);
	PlayerTextDrawFont(playerid, SKEW_BANNER_TEXT_CB[playerid], 3);
	PlayerTextDrawSetProportional(playerid, SKEW_BANNER_TEXT_CB[playerid], 1);
	PlayerTextDrawSetShadow(playerid, SKEW_BANNER_TEXT_CB[playerid], 0);


	MoneyTD_Value[playerid] = CreatePlayerTextDraw(playerid, 492.050384, 79.450050, "~g~$~w~0");
	PlayerTextDrawLetterSize(playerid, MoneyTD_Value[playerid], 0.315609, 1.901664);
	PlayerTextDrawAlignment(playerid, MoneyTD_Value[playerid], 1);
	PlayerTextDrawColor(playerid, MoneyTD_Value[playerid], -1);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Value[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MoneyTD_Value[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MoneyTD_Value[playerid], 255);
	PlayerTextDrawFont(playerid, MoneyTD_Value[playerid], 3);
	PlayerTextDrawSetProportional(playerid, MoneyTD_Value[playerid], 1);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Value[playerid], 0);

	MoneyTD_Health_Background[playerid] = CreatePlayerTextDraw(playerid, 546.150329, 69.283332, "display"); // min 543.55 | max 615.60
	PlayerTextDrawLetterSize(playerid, MoneyTD_Health_Background[playerid], 0.000000, 0.583166);
	PlayerTextDrawTextSize(playerid, MoneyTD_Health_Background[playerid], 543.556884, 0.000000);
	PlayerTextDrawAlignment(playerid, MoneyTD_Health_Background[playerid], 1);
	PlayerTextDrawColor(playerid, MoneyTD_Health_Background[playerid], -1);
	PlayerTextDrawUseBox(playerid, MoneyTD_Health_Background[playerid], 1);
	PlayerTextDrawBoxColor(playerid, MoneyTD_Health_Background[playerid], -10270848);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Health_Background[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MoneyTD_Health_Background[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MoneyTD_Health_Background[playerid], 255);
	PlayerTextDrawFont(playerid, MoneyTD_Health_Background[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MoneyTD_Health_Background[playerid], 1);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Health_Background[playerid], 0);

	MoneyTD_Health_Value[playerid] = CreatePlayerTextDraw(playerid, 580.308959, 67.433265, "~w~0%");
	PlayerTextDrawLetterSize(playerid, MoneyTD_Health_Value[playerid], 0.164801, 0.934997);
	PlayerTextDrawAlignment(playerid, MoneyTD_Health_Value[playerid], 2);
	PlayerTextDrawColor(playerid, MoneyTD_Health_Value[playerid], -1);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Health_Value[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MoneyTD_Health_Value[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MoneyTD_Health_Value[playerid], 255);
	PlayerTextDrawFont(playerid, MoneyTD_Health_Value[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MoneyTD_Health_Value[playerid], 1);
	PlayerTextDrawSetShadow(playerid, MoneyTD_Health_Value[playerid], 0);
	return true;
}

Hook:TD_OnPlayerDisconnect(playerid,reason[])
{
	if (SKEW_BANNER_TEXT_CB[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, SKEW_BANNER_TEXT_CB[playerid]);
	return true;
}

CreateMainUI(&Text:mtdFirst,&Text:mtdMap,&Text:mtdNextMap,&Text:mtdTime,&Text:mtdLast)
{
	new Text:TD;

	mtdFirst = TextDrawCreate(-37.964832, 437.333251, "bttmbg");
	TextDrawLetterSize(mtdFirst, 0.000000, 3.956077);
	TextDrawTextSize(mtdFirst, 677.000000, 0.000000);
	TextDrawAlignment(mtdFirst, 1);
	TextDrawColor(mtdFirst, -1);
	TextDrawUseBox(mtdFirst, 1);
	TextDrawBoxColor(mtdFirst, 128);
	TextDrawBackgroundColor(mtdFirst, 255);

	TD = TextDrawCreate(-33.748142, 426.249938, "bttmnxtmpbg");
	TextDrawLetterSize(TD, 0.000000, 0.770129);
	TextDrawTextSize(TD, 186.000000, 0.000000);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawUseBox(TD, 1);
	TextDrawBoxColor(TD, 128);
	TextDrawBackgroundColor(TD, 255);

	TD = TextDrawCreate(-42.650043, 436.166717, "bbtmlinetop");
	TextDrawLetterSize(TD, 0.000000, -0.213759);
	TextDrawTextSize(TD, 956.000000, 0.000000);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawUseBox(TD, 1);
	TextDrawBoxColor(TD, 674910207);
	TextDrawBackgroundColor(TD, 255);

	mtdMap = TextDrawCreate(2.327970, 436.166656, "~w~~>~ There is nothing to see here!");
	TextDrawLetterSize(mtdMap, 0.154963, 1.057497);
	TextDrawAlignment(mtdMap, 1);
	TextDrawColor(mtdMap, -1);
	TextDrawSetShadow(mtdMap, 0);
	TextDrawSetOutline(mtdMap, 0);
	TextDrawBackgroundColor(mtdMap, 255);
	TextDrawFont(mtdMap, 1);
	TextDrawSetProportional(mtdMap, 1);
	TextDrawSetShadow(mtdMap, 0);

	mtdNextMap = TextDrawCreate(3.733530, 423.816589, "~y~Next ~w~Random");
	TextDrawLetterSize(mtdNextMap, 0.154963, 1.057497);
	TextDrawAlignment(mtdNextMap, 1);
	TextDrawColor(mtdNextMap, -1);
	TextDrawSetShadow(mtdNextMap, 0);
	TextDrawSetOutline(mtdNextMap, 0);
	TextDrawBackgroundColor(mtdNextMap, 255);
	TextDrawFont(mtdNextMap, 1);
	TextDrawSetProportional(mtdNextMap, 1);
	TextDrawSetShadow(mtdNextMap, 0);

	mtdLast = mtdTime = TextDrawCreate(590.426330, 436.750122, "~w~00:00");
	TextDrawLetterSize(mtdLast, 0.223831, 1.220828);
	TextDrawAlignment(mtdLast, 1);
	TextDrawColor(mtdLast, -1);
	TextDrawSetShadow(mtdLast, 0);
	TextDrawSetOutline(mtdLast, 0);
	TextDrawBackgroundColor(mtdLast, 255);
	TextDrawFont(mtdLast, 1);
	TextDrawSetProportional(mtdLast, 1);
	TextDrawSetShadow(mtdLast, 0);
}

CreateTableTextdraws(&Text:first,Text:thead[],Text:Field1[],Text:Field2[],&Text:last)
{
	new Text:TD;

	first = TextDrawCreate(490.996093, 162.583267, "ttbg");
	TextDrawLetterSize(first, 0.000000, 8.500732);
	TextDrawTextSize(first, 616.000000, 0.000000);
	TextDrawAlignment(first, 1);
	TextDrawColor(first, -1);
	TextDrawUseBox(first, 1);
	TextDrawBoxColor(first, 128);
	TextDrawBackgroundColor(first, 255);

	TD = TextDrawCreate(490.996093, 160.833374, "ttlinetop");
	TextDrawLetterSize(TD, 0.000000, -0.213759);
	TextDrawTextSize(TD, 616.000000, 0.000000);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawUseBox(TD, 1);
	TextDrawBoxColor(TD, 674910207);
	TextDrawBackgroundColor(TD, 255);

	//TD = TextDrawCreate(553.777282, 231.999954, "~w~Press ~b~~h~~h~'2' / 'MMB'~w~ to hide/show this box.");
	TD = TextDrawCreate(553.777282, 231.999954, "~w~Press ~b~~h~~h~'2' ~w~(SPEC: ~b~~h~~h~'MMB'~w~) to toggle.");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 2);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

	thead[0] = TextDrawCreate(493.337738, 161.999984, "~y~#");
	TextDrawLetterSize(thead[0], 0.164801, 0.934997);
	TextDrawAlignment(thead[0], 1);
	TextDrawColor(thead[0], -1);
	TextDrawSetShadow(thead[0], 0);
	TextDrawSetOutline(thead[0], 0);
	TextDrawBackgroundColor(thead[0], 255);
	TextDrawFont(thead[0], 1);
	TextDrawSetProportional(thead[0], 1);
	TextDrawSetShadow(thead[0], 0);

	thead[1] = TextDrawCreate(506.925079, 161.999984, "~y~Name");
	TextDrawLetterSize(thead[1], 0.164801, 0.934997);
	TextDrawAlignment(thead[1], 1);
	TextDrawColor(thead[1], -1);
	TextDrawSetShadow(thead[1], 0);
	TextDrawSetOutline(thead[1], 0);
	TextDrawBackgroundColor(thead[1], 255);
	TextDrawFont(thead[1], 1);
	TextDrawSetProportional(thead[1], 1);
	TextDrawSetShadow(thead[1], 0);

	thead[2] = TextDrawCreate(610.936523, 161.999984, "~y~Time");
	TextDrawLetterSize(thead[2], 0.164801, 0.934997);
	TextDrawAlignment(thead[2], 3);
	TextDrawColor(thead[2], -1);
	TextDrawSetShadow(thead[2], 0);
	TextDrawSetOutline(thead[2], 0);
	TextDrawBackgroundColor(thead[2], 255);
	TextDrawFont(thead[2], 1);
	TextDrawSetProportional(thead[2], 1);
	TextDrawSetShadow(thead[2], 0);

	TD = TextDrawCreate(495.212585, 173.666671, "tableline");
	TextDrawLetterSize(TD, 0.000000, -0.448020);
	TextDrawTextSize(TD, 609.000000, 0.000000);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawUseBox(TD, 1);
	TextDrawBoxColor(TD, -128);
	TextDrawBackgroundColor(TD, 255);

	TD = TextDrawCreate(493.337738, 173.666580, "~w~1st");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

	Field1[0] = TextDrawCreate(506.925079, 173.666580, "~w~ftw.Infra");
	TextDrawLetterSize(Field1[0], 0.164801, 0.934997);
	TextDrawAlignment(Field1[0], 1);
	TextDrawColor(Field1[0], -1);
	TextDrawSetShadow(Field1[0], 0);
	TextDrawSetOutline(Field1[0], 0);
	TextDrawBackgroundColor(Field1[0], 255);
	TextDrawFont(Field1[0], 1);
	TextDrawSetProportional(Field1[0], 1);
	TextDrawSetShadow(Field1[0], 0);

	Field2[0] = TextDrawCreate(610.936523, 173.666580, "~w~01:32.264");
	TextDrawLetterSize(Field2[0], 0.164801, 0.934997);
	TextDrawAlignment(Field2[0], 3);
	TextDrawColor(Field2[0], -1);
	TextDrawSetShadow(Field2[0], 0);
	TextDrawSetOutline(Field2[0], 0);
	TextDrawBackgroundColor(Field2[0], 255);
	TextDrawFont(Field2[0], 1);
	TextDrawSetProportional(Field2[0], 1);
	TextDrawSetShadow(Field2[0], 0);

	TD = TextDrawCreate(493.806274, 182.416549, "~w~2nd");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

	Field1[1] = TextDrawCreate(506.925079, 182.416549, "~w~Potato");
	TextDrawLetterSize(Field1[1], 0.164801, 0.934997);
	TextDrawAlignment(Field1[1], 1);
	TextDrawColor(Field1[1], -1);
	TextDrawSetShadow(Field1[1], 0);
	TextDrawSetOutline(Field1[1], 0);
	TextDrawBackgroundColor(Field1[1], 255);
	TextDrawFont(Field1[1], 1);
	TextDrawSetProportional(Field1[1], 1);
	TextDrawSetShadow(Field1[1], 0);

	Field2[1] = TextDrawCreate(610.936523, 182.416549, "~w~01:32.265");
	TextDrawLetterSize(Field2[1], 0.164801, 0.934997);
	TextDrawAlignment(Field2[1], 3);
	TextDrawColor(Field2[1], -1);
	TextDrawSetShadow(Field2[1], 0);
	TextDrawSetOutline(Field2[1], 0);
	TextDrawBackgroundColor(Field2[1], 255);
	TextDrawFont(Field2[1], 1);
	TextDrawSetProportional(Field2[1], 1);
	TextDrawSetShadow(Field2[1], 0);

	TD = TextDrawCreate(493.806274, 191.166519, "~w~3rd");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

	Field1[2] = TextDrawCreate(506.925079, 191.166519, "~w~ftw.definitelynotinfra");
	TextDrawLetterSize(Field1[2], 0.164801, 0.934997);
	TextDrawAlignment(Field1[2], 1);
	TextDrawColor(Field1[2], -1);
	TextDrawSetShadow(Field1[2], 0);
	TextDrawSetOutline(Field1[2], 0);
	TextDrawBackgroundColor(Field1[2], 255);
	TextDrawFont(Field1[2], 1);
	TextDrawSetProportional(Field1[2], 1);
	TextDrawSetShadow(Field1[2], 0);

	Field2[2] = TextDrawCreate(610.936523, 191.166519, "~w~01:32.342");
	TextDrawLetterSize(Field2[2], 0.164801, 0.934997);
	TextDrawAlignment(Field2[2], 3);
	TextDrawColor(Field2[2], -1);
	TextDrawSetShadow(Field2[2], 0);
	TextDrawSetOutline(Field2[2], 0);
	TextDrawBackgroundColor(Field2[2], 255);
	TextDrawFont(Field2[2], 1);
	TextDrawSetProportional(Field2[2], 1);
	TextDrawSetShadow(Field2[2], 0);

	TD = TextDrawCreate(493.806274, 199.916488, "~w~4th");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

 	Field1[3] = TextDrawCreate(506.925079, 199.916488, "~w~ftw.F4K3");
	TextDrawLetterSize(Field1[3], 0.164801, 0.934997);
	TextDrawAlignment(Field1[3], 1);
	TextDrawColor(Field1[3], -1);
	TextDrawSetShadow(Field1[3], 0);
	TextDrawSetOutline(Field1[3], 0);
	TextDrawBackgroundColor(Field1[3], 255);
	TextDrawFont(Field1[3], 1);
	TextDrawSetProportional(Field1[3], 1);
	TextDrawSetShadow(Field1[3], 0);

	Field2[3] = TextDrawCreate(610.936523, 199.916488, "~w~01:47.761");
	TextDrawLetterSize(Field2[3], 0.164801, 0.934997);
	TextDrawAlignment(Field2[3], 3);
	TextDrawColor(Field2[3], -1);
	TextDrawSetShadow(Field2[3], 0);
	TextDrawSetOutline(Field2[3], 0);
	TextDrawBackgroundColor(Field2[3], 255);
	TextDrawFont(Field2[3], 1);
	TextDrawSetProportional(Field2[3], 1);
	TextDrawSetShadow(Field2[3], 0);

	TD = TextDrawCreate(493.806274, 208.666458, "~w~5th");
	TextDrawLetterSize(TD, 0.164801, 0.934997);
	TextDrawAlignment(TD, 1);
	TextDrawColor(TD, -1);
	TextDrawSetShadow(TD, 0);
	TextDrawSetOutline(TD, 0);
	TextDrawBackgroundColor(TD, 255);
	TextDrawFont(TD, 1);
	TextDrawSetProportional(TD, 1);
	TextDrawSetShadow(TD, 0);

	Field1[4] = TextDrawCreate(506.925079, 208.666458, "~w~[dWa]Fruity");
	TextDrawLetterSize(Field1[4], 0.164801, 0.934997);
	TextDrawAlignment(Field1[4], 1);
	TextDrawColor(Field1[4], -1);
	TextDrawSetShadow(Field1[4], 0);
	TextDrawSetOutline(Field1[4], 0);
	TextDrawBackgroundColor(Field1[4], 255);
	TextDrawFont(Field1[4], 1);
	TextDrawSetProportional(Field1[4], 1);
	TextDrawSetShadow(Field1[4], 0);

	Field2[4] = TextDrawCreate(610.936523, 208.666458, "~w~02:14.876");
	TextDrawLetterSize(Field2[4], 0.164801, 0.934997);
	TextDrawAlignment(Field2[4], 3);
	TextDrawColor(Field2[4], -1);
	TextDrawSetShadow(Field2[4], 0);
	TextDrawSetOutline(Field2[4], 0);
	TextDrawBackgroundColor(Field2[4], 255);
	TextDrawFont(Field2[4], 1);
	TextDrawSetProportional(Field2[4], 1);
	TextDrawSetShadow(Field2[4], 0);

	last = TextDrawCreate(495.212585, 221.199966, "tableline");
	TextDrawLetterSize(last, 0.000000, -0.448020);
	TextDrawTextSize(last, 609.000000, 0.000000);
	TextDrawAlignment(last, 1);
	TextDrawColor(last, -1);
	TextDrawUseBox(last, 1);
	TextDrawBoxColor(last, -128);
	TextDrawBackgroundColor(last, 255);
}


CreateDeathlist(Text:pos4[],Text:pos3[],Text:pos2[],Text:pos1[])
{
	pos4[0] = TextDrawCreate(36.060928, 325.333160, " ");
	TextDrawLetterSize(pos4[0], 0.164801, 0.934997);
	TextDrawTextSize(pos4[0], 148.000000, 0.000000);
	TextDrawAlignment(pos4[0], 1);
	TextDrawColor(pos4[0], -859651329);
	TextDrawUseBox(pos4[0], 1);
	TextDrawBoxColor(pos4[0], 44);
	TextDrawSetShadow(pos4[0], 0);
	TextDrawSetOutline(pos4[0], 0);
	TextDrawBackgroundColor(pos4[0], 255);
	TextDrawFont(pos4[0], 1);
	TextDrawSetProportional(pos4[0], 1);
	TextDrawSetShadow(pos4[0], 0);

	pos4[1] = TextDrawCreate(51.648010, 325.333160, " ");
	TextDrawLetterSize(pos4[1], 0.164801, 0.934997);
	TextDrawAlignment(pos4[1], 1);
	TextDrawColor(pos4[1], -1);
	TextDrawSetShadow(pos4[1], 0);
	TextDrawSetOutline(pos4[1], 0);
	TextDrawBackgroundColor(pos4[1], 255);
	TextDrawFont(pos4[1], 1);
	TextDrawSetProportional(pos4[1], 1);
	TextDrawSetShadow(pos4[1], 0);

	pos4[2] = TextDrawCreate(147.568954, 325.333160, " ");
	TextDrawLetterSize(pos4[2], 0.164801, 0.934997);
	TextDrawAlignment(pos4[2], 3);
	TextDrawColor(pos4[2], -1);
	TextDrawSetShadow(pos4[2], 0);
	TextDrawSetOutline(pos4[2], 0);
	TextDrawBackgroundColor(pos4[2], 255);
	TextDrawFont(pos4[2], 1);
	TextDrawSetProportional(pos4[2], 1);
	TextDrawSetShadow(pos4[2], 0);

	pos3[0] = TextDrawCreate(36.060928, 309.582977, " ");
	TextDrawLetterSize(pos3[0], 0.164801, 0.934997);
	TextDrawTextSize(pos3[0], 148.000000, 0.000000);
	TextDrawAlignment(pos3[0], 1);
	TextDrawColor(pos3[0], -1772472065);
	TextDrawUseBox(pos3[0], 1);
	TextDrawBoxColor(pos3[0], 72);
	TextDrawSetShadow(pos3[0], 0);
	TextDrawSetOutline(pos3[0], 0);
	TextDrawBackgroundColor(pos3[0], 255);
	TextDrawFont(pos3[0], 1);
	TextDrawSetProportional(pos3[0], 1);
	TextDrawSetShadow(pos3[0], 0);

	pos3[1] = TextDrawCreate(51.648010, 309.582977, " ");
	TextDrawLetterSize(pos3[1], 0.164801, 0.934997);
	TextDrawAlignment(pos3[1], 1);
	TextDrawColor(pos3[1], -1);
	TextDrawSetShadow(pos3[1], 0);
	TextDrawSetOutline(pos3[1], 0);
	TextDrawBackgroundColor(pos3[1], 255);
	TextDrawFont(pos3[1], 1);
	TextDrawSetProportional(pos3[1], 1);
	TextDrawSetShadow(pos3[1], 0);

	pos3[2] = TextDrawCreate(147.568954, 309.582977, " ");
	TextDrawLetterSize(pos3[2], 0.164801, 0.934997);
	TextDrawAlignment(pos3[2], 3);
	TextDrawColor(pos3[2], -1);
	TextDrawSetShadow(pos3[2], 0);
	TextDrawSetOutline(pos3[2], 0);
	TextDrawBackgroundColor(pos3[2], 255);
	TextDrawFont(pos3[2], 1);
	TextDrawSetProportional(pos3[2], 1);
	TextDrawSetShadow(pos3[2], 0);

	pos2[0] = TextDrawCreate(36.060928, 293.832794, " ");
	TextDrawLetterSize(pos2[0], 0.164801, 0.934997);
	TextDrawTextSize(pos2[0], 148.000000, 0.000000);
	TextDrawAlignment(pos2[0], 1);
	TextDrawColor(pos2[0], -1465341697);
	TextDrawUseBox(pos2[0], 1);
	TextDrawBoxColor(pos2[0], 100);
	TextDrawSetShadow(pos2[0], 0);
	TextDrawSetOutline(pos2[0], 0);
	TextDrawBackgroundColor(pos2[0], 255);
	TextDrawFont(pos2[0], 1);
	TextDrawSetProportional(pos2[0], 1);
	TextDrawSetShadow(pos2[0], 0);

	pos2[1] = TextDrawCreate(51.648010, 293.832794, " ");
	TextDrawLetterSize(pos2[1], 0.164801, 0.934997);
	TextDrawAlignment(pos2[1], 1);
	TextDrawColor(pos2[1], -1);
	TextDrawSetShadow(pos2[1], 0);
	TextDrawSetOutline(pos2[1], 0);
	TextDrawBackgroundColor(pos2[1], 255);
	TextDrawFont(pos2[1], 1);
	TextDrawSetProportional(pos2[1], 1);
	TextDrawSetShadow(pos2[1], 0);

	pos2[2] = TextDrawCreate(147.568954, 293.832794, " ");
	TextDrawLetterSize(pos2[2], 0.164801, 0.934997);
	TextDrawAlignment(pos2[2], 3);
	TextDrawColor(pos2[2], -1);
	TextDrawSetShadow(pos2[2], 0);
	TextDrawSetOutline(pos2[2], 0);
	TextDrawBackgroundColor(pos2[2], 255);
	TextDrawFont(pos2[2], 1);
	TextDrawSetProportional(pos2[2], 1);
	TextDrawSetShadow(pos2[2], 0);

	pos1[0] = TextDrawCreate(36.060928, 278.082611, " ");
	TextDrawLetterSize(pos1[0], 0.164801, 0.934997);
	TextDrawTextSize(pos1[0], 148.000000, 0.000000);
	TextDrawAlignment(pos1[0], 1);
	TextDrawColor(pos1[0], -913764097);
	TextDrawUseBox(pos1[0], 1);
	TextDrawBoxColor(pos1[0], 128);
	TextDrawSetShadow(pos1[0], 0);
	TextDrawSetOutline(pos1[0], 0);
	TextDrawBackgroundColor(pos1[0], 255);
	TextDrawFont(pos1[0], 1);
	TextDrawSetProportional(pos1[0], 1);
	TextDrawSetShadow(pos1[0], 0);

	pos1[1] = TextDrawCreate(51.648010, 278.082611, " ");
	TextDrawLetterSize(pos1[1], 0.164801, 0.934997);
	TextDrawAlignment(pos1[1], 1);
	TextDrawColor(pos1[1], -1);
	TextDrawSetShadow(pos1[1], 0);
	TextDrawSetOutline(pos1[1], 0);
	TextDrawBackgroundColor(pos1[1], 255);
	TextDrawFont(pos1[1], 1);
	TextDrawSetProportional(pos1[1], 1);
	TextDrawSetShadow(pos1[1], 0);

	pos1[2] = TextDrawCreate(147.568954, 278.082611, " ");
	TextDrawLetterSize(pos1[2], 0.164801, 0.934997);
	TextDrawAlignment(pos1[2], 3);
	TextDrawColor(pos1[2], -1);
	TextDrawSetShadow(pos1[2], 0);
	TextDrawSetOutline(pos1[2], 0);
	TextDrawBackgroundColor(pos1[2], 255);
	TextDrawFont(pos1[2], 1);
	TextDrawSetProportional(pos1[2], 1);
	TextDrawSetShadow(pos1[2], 0);
}


CreateCWInfo(&Text:CWInfoFirst, &Text:CWInfoLineTop, &Text:CWInfoRoundsLeft, &Text:CWInfoTeamA, &Text:CWInfoVersus, &Text:CWInfoTeamB, &Text:CWInfoLine, &Text:CWInfoTeamAPlayers, &Text:CWInfoTeamAScore, &Text:CWInfoScoreDash, &Text:CWInfoTeamBScore, &Text:CWInfoLine2, &Text:CWInfoTeamBPlayers)
{
    CWInfoFirst = TextDrawCreate(490.996093, 162.583267, "ttbg");
    TextDrawLetterSize(CWInfoFirst, 0.000000, 14.104849);
    TextDrawTextSize(CWInfoFirst, 616.000000, 0.000000);
    TextDrawAlignment(CWInfoFirst, 1);
    TextDrawColor(CWInfoFirst, -1);
    TextDrawUseBox(CWInfoFirst, 1);
    TextDrawBoxColor(CWInfoFirst, 128);
    TextDrawSetShadow(CWInfoFirst, 0);
    TextDrawSetOutline(CWInfoFirst, 0);
    TextDrawBackgroundColor(CWInfoFirst, 255);
    TextDrawFont(CWInfoFirst, 1);
    TextDrawSetProportional(CWInfoFirst, 1);
    TextDrawSetShadow(CWInfoFirst, 0);

    CWInfoLineTop = TextDrawCreate(490.996093, 160.833374, "ttlinetop");
    TextDrawLetterSize(CWInfoLineTop, 0.000000, -0.213759);
    TextDrawTextSize(CWInfoLineTop, 616.000000, 0.000000);
    TextDrawAlignment(CWInfoLineTop, 1);
    TextDrawColor(CWInfoLineTop, -1);
    TextDrawUseBox(CWInfoLineTop, 1);
    TextDrawBoxColor(CWInfoLineTop, 674910207);
    TextDrawSetShadow(CWInfoLineTop, 0);
    TextDrawSetOutline(CWInfoLineTop, 0);
    TextDrawBackgroundColor(CWInfoLineTop, 255);
    TextDrawFont(CWInfoLineTop, 1);
    TextDrawSetProportional(CWInfoLineTop, 1);
    TextDrawSetShadow(CWInfoLineTop, 0);

    CWInfoRoundsLeft = TextDrawCreate(551.815673, 282.807342, "~w~Rounds left: ~y~3");
    TextDrawLetterSize(CWInfoRoundsLeft, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoRoundsLeft, 2);
    TextDrawColor(CWInfoRoundsLeft, -1);
    TextDrawSetShadow(CWInfoRoundsLeft, 0);
    TextDrawSetOutline(CWInfoRoundsLeft, 0);
    TextDrawBackgroundColor(CWInfoRoundsLeft, 255);
    TextDrawFont(CWInfoRoundsLeft, 1);
    TextDrawSetProportional(CWInfoRoundsLeft, 1);
    TextDrawSetShadow(CWInfoRoundsLeft, 0);

    CWInfoTeamA = TextDrawCreate(493.337738, 161.999984, "~y~Team A");
    TextDrawLetterSize(CWInfoTeamA, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoTeamA, 1);
    TextDrawColor(CWInfoTeamA, -1);
    TextDrawSetShadow(CWInfoTeamA, 0);
    TextDrawSetOutline(CWInfoTeamA, 0);
    TextDrawBackgroundColor(CWInfoTeamA, 255);
    TextDrawFont(CWInfoTeamA, 1);
    TextDrawSetProportional(CWInfoTeamA, 1);
    TextDrawSetShadow(CWInfoTeamA, 0);

    CWInfoVersus = TextDrawCreate(550.915893, 161.999984, "~w~VERSUS");
    TextDrawLetterSize(CWInfoVersus, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoVersus, 2);
    TextDrawColor(CWInfoVersus, -1);
    TextDrawSetShadow(CWInfoVersus, 0);
    TextDrawSetOutline(CWInfoVersus, 0);
    TextDrawBackgroundColor(CWInfoVersus, 255);
    TextDrawFont(CWInfoVersus, 1);
    TextDrawSetProportional(CWInfoVersus, 1);
    TextDrawSetShadow(CWInfoVersus, 0);

    CWInfoTeamB = TextDrawCreate(610.936523, 161.999984, "~y~Team B");
    TextDrawLetterSize(CWInfoTeamB, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoTeamB, 3);
    TextDrawColor(CWInfoTeamB, -1);
    TextDrawSetShadow(CWInfoTeamB, 0);
    TextDrawSetOutline(CWInfoTeamB, 0);
    TextDrawBackgroundColor(CWInfoTeamB, 255);
    TextDrawFont(CWInfoTeamB, 1);
    TextDrawSetProportional(CWInfoTeamB, 1);
    TextDrawSetShadow(CWInfoTeamB, 0);

    CWInfoLine = TextDrawCreate(495.212585, 173.666671, "tableline");
    TextDrawLetterSize(CWInfoLine, 0.000000, -0.448020);
    TextDrawTextSize(CWInfoLine, 609.000000, 0.000000);
    TextDrawAlignment(CWInfoLine, 1);
    TextDrawColor(CWInfoLine, -1);
    TextDrawUseBox(CWInfoLine, 1);
    TextDrawBoxColor(CWInfoLine, -128);
    TextDrawSetShadow(CWInfoLine, 0);
    TextDrawSetOutline(CWInfoLine, 0);
    TextDrawBackgroundColor(CWInfoLine, 255);
    TextDrawFont(CWInfoLine, 1);
    TextDrawSetProportional(CWInfoLine, 1);
    TextDrawSetShadow(CWInfoLine, 0);

    CWInfoTeamAPlayers = TextDrawCreate(491.915100, 199.333511, "~w~ftw.Infra~n~~r~[US]pkfln.io~n~~w~[dWa]Fruity~n~~w~Someone~n~~w~Someone~n~~w~S~n~~w~S~n~~w~S~n~~w~S~n~~w~S");
    TextDrawLetterSize(CWInfoTeamAPlayers, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoTeamAPlayers, 1);
    TextDrawColor(CWInfoTeamAPlayers, -1);
    TextDrawSetShadow(CWInfoTeamAPlayers, 0);
    TextDrawSetOutline(CWInfoTeamAPlayers, 0);
    TextDrawBackgroundColor(CWInfoTeamAPlayers, 255);
    TextDrawFont(CWInfoTeamAPlayers, 1);
    TextDrawSetProportional(CWInfoTeamAPlayers, 1);
    TextDrawSetShadow(CWInfoTeamAPlayers, 0);

    CWInfoTeamAScore = TextDrawCreate(493.006835, 170.266662, "~w~3");
    TextDrawLetterSize(CWInfoTeamAScore, 0.557626, 2.719165);
    TextDrawAlignment(CWInfoTeamAScore, 1);
    TextDrawColor(CWInfoTeamAScore, -1);
    TextDrawSetShadow(CWInfoTeamAScore, 0);
    TextDrawSetOutline(CWInfoTeamAScore, 0);
    TextDrawBackgroundColor(CWInfoTeamAScore, 255);
    TextDrawFont(CWInfoTeamAScore, 3);
    TextDrawSetProportional(CWInfoTeamAScore, 1);
    TextDrawSetShadow(CWInfoTeamAScore, 0);

    CWInfoScoreDash = TextDrawCreate(551.798278, 170.266662, "~w~-");
    TextDrawLetterSize(CWInfoScoreDash, 0.557626, 2.719165);
    TextDrawAlignment(CWInfoScoreDash, 2);
    TextDrawColor(CWInfoScoreDash, -1);
    TextDrawSetShadow(CWInfoScoreDash, 0);
    TextDrawSetOutline(CWInfoScoreDash, 0);
    TextDrawBackgroundColor(CWInfoScoreDash, 255);
    TextDrawFont(CWInfoScoreDash, 3);
    TextDrawSetProportional(CWInfoScoreDash, 1);
    TextDrawSetShadow(CWInfoScoreDash, 0);

    CWInfoTeamBScore = TextDrawCreate(610.583923, 170.266662, "~w~2");
    TextDrawLetterSize(CWInfoTeamBScore, 0.557626, 2.719165);
    TextDrawAlignment(CWInfoTeamBScore, 3);
    TextDrawColor(CWInfoTeamBScore, -1);
    TextDrawSetShadow(CWInfoTeamBScore, 0);
    TextDrawSetOutline(CWInfoTeamBScore, 0);
    TextDrawBackgroundColor(CWInfoTeamBScore, 255);
    TextDrawFont(CWInfoTeamBScore, 3);
    TextDrawSetProportional(CWInfoTeamBScore, 1);
    TextDrawSetShadow(CWInfoTeamBScore, 0);

    CWInfoLine2 = TextDrawCreate(495.212585, 198.168167, "tableline");
    TextDrawLetterSize(CWInfoLine2, 0.000000, -0.448020);
    TextDrawTextSize(CWInfoLine2, 609.000000, 0.000000);
    TextDrawAlignment(CWInfoLine2, 1);
    TextDrawColor(CWInfoLine2, -1);
    TextDrawUseBox(CWInfoLine2, 1);
    TextDrawBoxColor(CWInfoLine2, -128);
    TextDrawSetShadow(CWInfoLine2, 0);
    TextDrawSetOutline(CWInfoLine2, 0);
    TextDrawBackgroundColor(CWInfoLine2, 255);
    TextDrawFont(CWInfoLine2, 1);
    TextDrawSetProportional(CWInfoLine2, 1);
    TextDrawSetShadow(CWInfoLine2, 0);

    CWInfoTeamBPlayers = TextDrawCreate(608.692687, 199.333511, "~w~ftw.Infra~n~~r~[US]pkfln.io~n~~w~[dWa]Fruity~n~~w~Someone~n~~w~Someone~n~~w~S~n~~w~S~n~~w~S~n~~w~S~n~~w~S~n~");
    TextDrawLetterSize(CWInfoTeamBPlayers, 0.164801, 0.934997);
    TextDrawAlignment(CWInfoTeamBPlayers, 3);
    TextDrawColor(CWInfoTeamBPlayers, -1);
    TextDrawSetShadow(CWInfoTeamBPlayers, 0);
    TextDrawSetOutline(CWInfoTeamBPlayers, 0);
    TextDrawBackgroundColor(CWInfoTeamBPlayers, 255);
    TextDrawFont(CWInfoTeamBPlayers, 1);
    TextDrawSetProportional(CWInfoTeamBPlayers, 1);
    TextDrawSetShadow(CWInfoTeamBPlayers, 0);
}
