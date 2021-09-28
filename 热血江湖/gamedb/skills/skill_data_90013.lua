----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90013] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 305, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72010, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72011, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72012, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72013, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72014, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72081, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72082, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
