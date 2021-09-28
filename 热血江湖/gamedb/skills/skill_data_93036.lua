----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93036] = {
		[1] = {cool = 25000, events = {{triTime = 2125, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, }, {triTime = 2375, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, }, {triTime = 2625, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, status = {{odds = 10000, buffID = 1428, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
