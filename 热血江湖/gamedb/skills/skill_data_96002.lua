----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[96002] = {
		[1] = {events = {{triTime = 100, hitEffID = 30489, damage = {odds = 10000, atrType = 1, arg1 = 5.0, }, status = {{odds = 10000, buffID = 560, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
