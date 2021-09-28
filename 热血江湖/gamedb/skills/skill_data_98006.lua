----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98006] = {
		[1] = {cool = 5000, events = {{triTime = 100, hitEffID = 30489, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 533, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
