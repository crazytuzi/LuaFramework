----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94316] = {
		[1] = {cool = 12000, events = {{triTime = 1700, hitEffID = 30778, damage = {odds = 10000, atrType = 1, acrType = 1, arg1 = 3.6, }, status = {{odds = 18000, buffID = 1280, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
