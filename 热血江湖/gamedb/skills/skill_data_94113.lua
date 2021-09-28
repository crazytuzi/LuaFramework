----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94113] = {
		[1] = {cool = 6000, events = {{triTime = 400, hitEffID = 30860, damage = {odds = 10000, arg1 = 1.83, }, status = {{odds = 18000, buffID = 1271, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
