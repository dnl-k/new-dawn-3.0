static this;
Hook:STBL_InitStunt()
{
	this = NewStuntMap();
	new name[32] = "Blank"; // Stunt Area Name
	Stunts[this][Name] = name; // -- Ignore this --
	new alias[16] = "blank"; // Alias for /tele command, max 15 chars
	Stunts[this][Alias] = alias; // -- Ignore this --
	//
	Stunts[this][Spawn][0] = 0; // Spawn X
	Stunts[this][Spawn][1] = 0; // Spawn Y
	Stunts[this][Spawn][2] = 4; // Spawn Z
	//
	Stunts[this][BoundaryX][0] = -500.0; // First Boundary X
	Stunts[this][BoundaryY][0] = -500.0; // First Boundary Y
	Stunts[this][BoundaryX][1] = 500.0; // Last Boundary X
	Stunts[this][BoundaryY][1] = 500.0; // Last Boundary Y
	//
	Stunts[this][AllowVehicles] = true; // Vehicle Spawn Enabled
	Stunts[this][AllowWeapons] = false; // Weapon Spawn Enabled
}




