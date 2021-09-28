----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92042] = {
		[1] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[2] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[3] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[4] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[5] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[6] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[7] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[8] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[9] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[10] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[11] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[12] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[13] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[14] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[15] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[16] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[17] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[18] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[19] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[20] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[21] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[22] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[23] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[24] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[25] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[26] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[27] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[28] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[29] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
		[30] = {events = {{triTime = 2650, damage = {odds = 10000, arg1 = 5.0, }, }, {triTime = 3250, damage = {odds = 10000, arg1 = 5.5, }, }, {triTime = 5275, damage = {odds = 10000, atrType = 1, arg1 = 7.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
