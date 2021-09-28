----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91015] = {
		[1] = {cool = 1000, events = {{triTime = 100, hitEffID = 30897, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 20000, buffID = 670, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
