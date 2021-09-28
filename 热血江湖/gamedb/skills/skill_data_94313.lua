----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94313] = {
		[1] = {cool = 6000, events = {{triTime = 925, hitEffID = 30776, damage = {odds = 10000, arg1 = 2.7, }, status = {{odds = 18000, buffID = 1278, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
