----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94114] = {
		[1] = {cool = 8000, events = {{triTime = 550, hitEffID = 30861, damage = {odds = 10000, arg1 = 2.06, }, status = {{odds = 18000, buffID = 1272, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
