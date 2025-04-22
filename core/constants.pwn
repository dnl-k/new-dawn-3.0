#define STREAM_URL                      "http://server.dawn-tdm.com/music/"

#define MAX_MODES                       9
#define MAX_MODE_NAME                   24
#define LOBBY_LENGTH                    320.0
#define LOBBY_PADDING                   5.0
#define LOBBY_ROWS                      3

#define MAX_CLANS                       32
#define MAX_CLAN_NAME                   24

#define GAMEMODE_RACE                   1
#define GAMEMODE_PLAY                   2

#define COL_LIGHTGREY                   0xB9C9BFFF
#define COL_LIGHTRED                    0xFF6347FF
#define COL_LIGHTBLUE_PURPLE			0x6688FFFF
#define COL_GREEN						0x66C776FF
#define COL_LIMEGREEN                   0x66CC00FF
#define COL_PALLIDGREEN                 0xA4C391FF
#define COL_ORANGE						0xFF8C13FF
#define COL_SAMP_MSG                    0xA9C4E4FF
#define COL_LIGHTPINK                   0xFBE8E8FF
#define COL_SMOOTHPINK                  0xF19C9CFF
#define COL_RPRED						0xE43333FF

#define EMB_COL_LIGHTGREY               "{B9C9BF}"
#define EMB_COL_LIGHTRED                "{FF6347}"
#define EMB_COL_LIGHTBLUE_PURPLE        "{6688FF}"
#define EMB_COL_GREEN					"{66C776}"
#define EMB_COL_LIMEGREEN               "{66CC00}"
#define EMB_COL_PALLIDGREEN             "{A4C391}"
#define EMB_COL_ORANGE					"{FF8C13}"
#define EMB_COL_SAMP_MSG                "{A9C4E4}"

#define NUM_FERRIS_CAGES                10
#define FERRIS_WHEEL_ID                 18877
#define FERRIS_CAGE_ID                  18879
#define FERRIS_BASE_ID                  18878
#define FERRIS_DRAW_DISTANCE            300.0
#define FERRIS_WHEEL_SPEED              0.01
#define FERRIS_WHEEL_Z_ANGLE            -90.0

#define MAX_LOGIN_ATTEMPTS              3

#define AREA_TYPE_HITBOX                1
#define AREA_TYPE_SPAWNPOINT            2
#define AREA_TYPE_RACE_PICKUP           3
#define AREA_TYPE_MARKER                4

#define INVALID_ACCESS                  0
#define INVALID_TARGET                  "Invalid Target"

#define COL_SYNTAX_REMINDER             COL_LIGHTRED
#define COL_ERROR                       COL_LIGHTRED
#define COL_PUNISHMENT                  COL_LIGHTRED
#define COL_INFORMATION                 COL_LIGHTBLUE_PURPLE
#define EMB_COL_INFORMATION             EMB_COL_LIGHTBLUE_PURPLE
#define EMB_COL_PUNISHMENT              EMB_COL_LIGHTRED

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

new stock VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo",
    "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto",
	"Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier",
	"Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks",
	"Hotknife", "Trailer 1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
	"RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
	"Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
	"Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio",
	"Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
	"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350",
	"Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
	"Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood",
	"Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxvillde",
	"Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger",
	"Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle",
	"Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer",
	"Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
	"Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine",
	"Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
	"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob",
	"Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster",
	"Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger",
	"Flash", "Tahoma", "Savanna", "Bandito", "Freight Flat", "Streak Carriage", "Kart",
	"Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley",
	"Stafford", "BF-400", "News Van", "Tug", "Trailer 3", "Emperor", "Wayfarer", "Euros",
	"Hotdog", "Club", "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch",
	"LSPD Car", "SFPD Car", "LVPD Car", "Police Ranger", "Picador", "S.W.A.T Tank", "Alpha",
	"Phoenix", "Glendale", "Sadler", "Luggage Trailer 1", "Luggage Trailer 2", "Stairs Trailer",
	"Boxville", "Utility Trailer 1", "Utility Trailer 2"
};
