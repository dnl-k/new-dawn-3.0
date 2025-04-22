#define VEHICLE_GROUP_UNDEFINED		0
#define VEHICLE_GROUP_CAR			1
#define VEHICLE_GROUP_BIKE			2
#define VEHICLE_GROUP_TRUCK			3
#define VEHICLE_GROUP_PLANE			4
#define VEHICLE_GROUP_HELICOPTER	5
#define VEHICLE_GROUP_BICYCLE		6
#define VEHICLE_GROUP_BOAT			7
#define VEHICLE_GROUP_UNIQUE		8

stock GetVehicleModelGroup(modelid)
{
	switch(modelid)
	{
		// CAR
		case 400 .. 402,404,405,409 .. 413,415,416,418 .. 424,426,429,434,436,438 .. 440,442,445,451,458,459,466,467,474,475,477 .. 480,
			482,483,489 .. 492,494 .. 496,500,502 .. 508,516 .. 518,526,527,529,533 .. 536,540 .. 543,545 .. 547,549,552,554,555,
			558 .. 562,565 .. 568,575,576,579,580,582,585,587,589,596 .. 600,602 .. 605: return VEHICLE_GROUP_CAR;

		// BIKE
		case 448,461 .. 463,468,471,521 .. 523,581,586: return VEHICLE_GROUP_BIKE;

		// TRUCK
		case 403,407,408,414,427,428,431,433,437,443,444,455,456,470,498,499,514,515,524,544,556,557,573,578,601,609: return VEHICLE_GROUP_TRUCK;

		// PLANE
		case 460,476,511 .. 513,519,520,553,577,592,593: return VEHICLE_GROUP_PLANE;

		// HELICOPTER
		case 417,425,447,469,487,488,497,548,563: return VEHICLE_GROUP_HELICOPTER;

		//BICYCLE
		case 481,509,510: return VEHICLE_GROUP_BICYCLE;

		// BOAT
		case 430,446,452 .. 454,472,473,484,493,595: return VEHICLE_GROUP_BOAT;

		// UNIQUE
		case 406,432,449,457,485,486,525,528,530,531,532,537,538,539,571,572,574,583,588: return VEHICLE_GROUP_UNIQUE;

		// UNDEFINED
		default: return VEHICLE_GROUP_UNDEFINED;
	}
	return VEHICLE_GROUP_UNDEFINED;
}

stock SendClientBlankLines(playerid, amount)
{
	for (new i = 0; i <= amount; i++)
		SendClientMessage(playerid, -1, " ");
}

Tick(tick, bool:ms = true)
{
	new string[16],
		c = tick;
	new minutes = c / 60000;
	c -= minutes * 60000;
	new seconds = c / 1000;
	c -= seconds * 1000;
	new milliseconds = c;
	if (ms)
		format(string, sizeof(string), "%02d:%02d.%03d", minutes, seconds, milliseconds);
	else
		format(string, sizeof(string), "%02d:%02d", minutes, seconds, milliseconds);
	return string;
}

stock GetPlayerID(pName[])
{
	new playerid = INVALID_PLAYER_ID;
	sscanf(pName,"u",playerid);
	return playerid;
}

stock urlencode(string[]) {
    new ret[64];
    ret[0] = 0;
    new i = 0;
    new p = 0;
    new s = 0;
    while (string[i] != 0) {
        if  (
                (string[i] >= 'A' && string[i] <= 'Z')
                || (string[i] >= 'a' && string[i] <= 'z')
                || (string[i] >= '0' && string[i] <= '9')
                || (string[i] == '-')
                || (string[i] == '_')
                || (string[i] == '.')
            ) {
                ret[p] = string[i];
            } else {
                //
                ret[p] = '%';
                p++;
                s = (string[i] % 16); //
                ret[p+1] = (s>9) ? (55+s) : (48+s); // 64 - 9 = 55
                s = floatround((string[i] - s)/16);
                ret[p] = (s>9) ? (55+s) : (48+s); // 64 - 9 = 55
                p++;
            }
        p++;
        i++;
    }
    return ret;
}

stock IsVehicleBodyInDynamicArea(vehicleid, areaid)
{
	new Float:x, Float:y, Float:z, Float:angle, Float:sX, Float:sY, Float:sZ, result;
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleModelInfo(vehicleid, VEHICLE_MODEL_INFO_SIZE , sX, sY, sZ);
	GetVehicleZAngle(vehicleid, angle);
	x += ( (sX / 2.0) * floatsin( -angle, degrees ) );
	y += ( (sY / 2.0) * floatsin( -angle, degrees ) );
	if(IsPointInDynamicArea(areaid, x, y, z))
	{
	    result = 1;
	}
	if(result == 0)
	{
	    GetVehicleModelInfo(vehicleid, VEHICLE_MODEL_INFO_SIZE , sX, sY, sZ);
	    x -= ( (sX / 2.0) * floatsin( -angle, degrees ) );
		y -= ( (sY / 2.0) * floatsin( -angle, degrees ) );
		if(IsPointInDynamicArea(areaid, x, y, z))
		{
		    result = 1;
		}
	}
	return result;
}

stock IsVehicleBodyInAnyDynamicArea(vehicleid)
{
	new Float:x, Float:y, Float:z, Float:angle, Float:sX, Float:sY, Float:sZ, result;
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleModelInfo(vehicleid, VEHICLE_MODEL_INFO_SIZE , sX, sY, sZ);
	GetVehicleZAngle(vehicleid, angle);
	x += ( (sX / 2.0) * floatsin( -angle, degrees ) );
	y += ( (sY / 2.0) * floatsin( -angle, degrees ) );
	if(IsPointInAnyDynamicArea(x, y, z))
	{
	    result = 1;
	}
	if(result == 0)
	{
	    GetVehicleModelInfo(vehicleid, VEHICLE_MODEL_INFO_SIZE , sX, sY, sZ);
	    x -= ( (sX / 2.0) * floatsin( -angle, degrees ) );
		y -= ( (sY / 2.0) * floatsin( -angle, degrees ) );
		if(IsPointInAnyDynamicArea(x, y, z))
		{
		    result = 1;
		}
	}
	return result;
}

stock Ordinal(number)
{
	new
	    ordinal[4][3] = { "st", "nd", "rd", "th" }
	;
	return (((10 < (number % 100) < 14)) ? ordinal[3] : (0 < (number % 10) < 4) ? ordinal[((number % 10) - 1)] : ordinal[3]);
}

stock GetMaterialIterationsForModel(modelid)
{
	switch (modelid)
	{
		case 3437, 6959: return 1;
		case 3095, 8171, 8172: return 2;
		case 3458, 8558, 8838, 8947, 9623: return 3;
		case 7657: return 4;
		case 18450: return 5;
		case 3115: return 6;
		case 1655, 1632: return 8;
		default: return 7;
	}
	return 7;
}

stock GetPlayerPacketloss(playerid,&Float:packetloss)
{
	if(!IsPlayerConnected(playerid)) return 0;

	new nstats[400+1], nstats_loss[20], start, end;
	GetPlayerNetworkStats(playerid, nstats, sizeof(nstats));

	start = strfind(nstats,"packetloss",true);
	end = strfind(nstats,"%",true,start);

	strmid(nstats_loss, nstats, start+12, end, sizeof(nstats_loss));
	packetloss = floatstr(nstats_loss);
	return 1;
}

Log(type[], playerid, target, occasion_1[], occasion_2[])
{
	if (!IsPlayerConnected(target))
		target = -1;
	new query[256];
	mysql_format(g_Sql, query, sizeof(query), "INSERT INTO core_logs (strType, intUID, intTargetUID, strOccasion, dtDate) VALUES ('%e', '%d', '%d', '%e: %e', now())", type, Player[playerid][ID], (target == -1 ? -1 : Player[target][ID]), occasion_1, occasion_2);
	mysql_pquery(g_Sql, query);
	return true;
}
