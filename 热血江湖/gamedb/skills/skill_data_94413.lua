----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94413] = {
		[1] = {cool = 6000, events = {{triTime = 1125, hitEffID = 30776, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 18000, buffID = 1296, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
