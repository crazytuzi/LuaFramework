----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92031] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 930, }, {odds = 10000, buffID = 940, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 931, }, {odds = 10000, buffID = 941, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 932, }, {odds = 10000, buffID = 942, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 933, }, {odds = 10000, buffID = 943, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 934, }, {odds = 10000, buffID = 944, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 935, }, {odds = 10000, buffID = 945, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 936, }, {odds = 10000, buffID = 946, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 937, }, {odds = 10000, buffID = 947, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 938, }, {odds = 10000, buffID = 948, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 939, }, {odds = 10000, buffID = 949, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
