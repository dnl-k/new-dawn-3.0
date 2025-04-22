#define MAX_COUNTRY_NAME    (40)
#define MAX_ZIP_LENGTH      (15)

forward HTTP_OnLookupResponse(index, response, data[]);

enum e_LookupData
{
    e_LookupCountry[MAX_COUNTRY_NAME char],
    e_LookupRegion[MAX_COUNTRY_NAME char],
    e_LookupCity[MAX_COUNTRY_NAME char],
    e_LookupISP[MAX_COUNTRY_NAME char],
    e_LookupTimezone[MAX_COUNTRY_NAME char],
    e_LookupZipcode[MAX_ZIP_LENGTH char]
};

new g_asLookupData[MAX_PLAYERS][e_LookupData];

#if defined OnLookupComplete
    forward OnLookupComplete(playerid);
#endif

public HTTP_OnLookupResponse(index, response, data[])
{
    new pos = -1;

    if (!IsPlayerConnected(index)) return 0;
    else if (response == 200)
    {
        if (strfind(data, "Reserved", true) != -1 || strlen(data) < 15)
        {
            return false;
        }
        else
        {
            new country[MAX_COUNTRY_NAME],region[MAX_COUNTRY_NAME],city[MAX_COUNTRY_NAME],isp[MAX_COUNTRY_NAME], timezone[MAX_COUNTRY_NAME], zip[10];

            if ((pos = strfind(data, "\"country\":")) != -1)
            {
                pos = pos + 11;

                strmid(country, data, pos, strfind(data, "\"", true, pos), MAX_COUNTRY_NAME);
            }
            if ((pos = strfind(data, "\"regionName\":")) != -1)
            {
                pos = pos + 14;

                strmid(region, data, pos, strfind(data, "\"", true, pos), MAX_COUNTRY_NAME);

            }
            if ((pos = strfind(data, "\"city\":")) != -1)
            {
                pos = pos + 8;

                strmid(city, data, pos, strfind(data, "\"", true, pos), MAX_COUNTRY_NAME);
            }

            if ((pos = strfind(data, "\"isp\":")) != -1)
            {
                pos = pos + 7;

                strmid(isp, data, pos, strfind(data, "\"", true, pos), MAX_COUNTRY_NAME);
            }

            if ((pos = strfind(data, "\"timezone\":")) != -1)
            {
                pos = pos + 12;

                strmid(timezone, data, pos, strfind(data, "\"", true, pos), MAX_COUNTRY_NAME);
            }

            if ((pos = strfind(data, "\"zip\":")) != -1)
            {
                pos = pos + 7;

                strmid(zip, data, pos, strfind(data, "\"", true, pos), 10);
            }

            if (pos != -1)
            {
                strpack(g_asLookupData[index][e_LookupCountry], country, MAX_COUNTRY_NAME char);
                strpack(g_asLookupData[index][e_LookupRegion], region, MAX_COUNTRY_NAME char);
                strpack(g_asLookupData[index][e_LookupCity], city, MAX_COUNTRY_NAME char);
                strpack(g_asLookupData[index][e_LookupISP], isp, MAX_COUNTRY_NAME char);
                strpack(g_asLookupData[index][e_LookupTimezone], timezone, MAX_COUNTRY_NAME char);
                strpack(g_asLookupData[index][e_LookupZipcode], zip, MAX_ZIP_LENGTH char);

                #if defined OnLookupComplete
                CallLocalFunction("OnLookupComplete", "d", index);
                #endif
            }
        }
    }
    return false;
}

Hook:IP_OnPlayerConnect(playerid)
{
    new ipstr[64];

    GetPlayerIp(playerid, ipstr, 64);

    strpack(g_asLookupData[playerid][e_LookupCountry], "Unknown", MAX_COUNTRY_NAME char);
    strpack(g_asLookupData[playerid][e_LookupRegion], "Unknown", MAX_COUNTRY_NAME char);
    strpack(g_asLookupData[playerid][e_LookupCity], "Unknown", MAX_COUNTRY_NAME char);
    strpack(g_asLookupData[playerid][e_LookupISP], "Unknown", MAX_COUNTRY_NAME char);
    strpack(g_asLookupData[playerid][e_LookupTimezone], "Unknown", MAX_COUNTRY_NAME char);
    strpack(g_asLookupData[playerid][e_LookupZipcode], "Unknown", MAX_COUNTRY_NAME char);

    strins(ipstr, "ip-api.com/json/", 0);
    HTTP(playerid, HTTP_GET, ipstr, "", "HTTP_OnLookupResponse");
    return true;
}

stock GetPlayerCountry(playerid, country[], size = sizeof(country))
{
    if (IsPlayerConnected(playerid))
        return strunpack(country, g_asLookupData[playerid][e_LookupCountry], size);

    else
        strunpack(country, !"Unknown", size);

    return false;
}

stock GetPlayerRegion(playerid, region[], size = sizeof(region))
{
    if (IsPlayerConnected(playerid))
        return strunpack(region, g_asLookupData[playerid][e_LookupRegion], size);

    else
        strunpack(region, !"Unknown", size);

    return false;
}

stock GetPlayerCity(playerid, city[], size = sizeof(city))
{
    if (IsPlayerConnected(playerid))
        return strunpack(city, g_asLookupData[playerid][e_LookupCity], size);

    else
        strunpack(city, !"Unknown", size);

    return false;
}

stock GetPlayerISP(playerid, isp[], size = sizeof(isp))
{
    if (IsPlayerConnected(playerid))
        return strunpack(isp, g_asLookupData[playerid][e_LookupISP], size);

    else
        strunpack(isp, !"Unknown", size);

    return false;
}

stock GetPlayerTimezone(playerid, timezone[], size = sizeof(timezone))
{
    if (IsPlayerConnected(playerid))
        return strunpack(timezone, g_asLookupData[playerid][e_LookupTimezone], size);

    else
        strunpack(timezone, !"Unknown", size);

    return false;
}

stock GetPlayerZipcode(playerid, zipcode[], size = sizeof(zipcode)) // Returns as a string for now, read note in the callback above.
{
    if (IsPlayerConnected(playerid))
        return strunpack(zipcode, g_asLookupData[playerid][e_LookupZipcode], size);

    else
        strunpack(zipcode, !"Unknown", size);

    return false;
}
