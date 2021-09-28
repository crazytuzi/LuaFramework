----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94314] = {
		[1] = {cool = 8000, events = {{triTime = 875, hitEffID = 30777, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 18000, buffID = 573, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
