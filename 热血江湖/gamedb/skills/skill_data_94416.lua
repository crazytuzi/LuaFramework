----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94416] = {
		[1] = {cool = 10000, events = {{triTime = 625, hitEffID = 30778, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 18000, buffID = 573, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
