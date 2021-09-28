----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91014] = {
		[1] = {cool = 1000, events = {{triTime = 100, hitEffID = 30220, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 20000, buffID = 669, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
