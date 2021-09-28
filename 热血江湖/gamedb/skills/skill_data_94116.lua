----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94116] = {
		[1] = {cool = 12000, events = {{hitEffID = 30860, damage = {odds = 10000, atrType = 1, arg1 = 0.63, }, status = {{odds = 18000, buffID = 1274, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
