----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93007] = {
		[1] = {cool = 15000, events = {{triTime = 1500, damage = {odds = 10000, atrType = 1, arg1 = 2.5, }, status = {{odds = 10000, buffID = 1402, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
