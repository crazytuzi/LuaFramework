----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94216] = {
		[1] = {cool = 12000, events = {{triTime = 825, hitEffID = 30792, damage = {odds = 10000, atrType = 1, arg1 = 2.65, }, status = {{odds = 18000, buffID = 1277, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
