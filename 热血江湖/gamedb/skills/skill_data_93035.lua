----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93035] = {
		[1] = {cool = 15000, events = {{triTime = 2000, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, {triTime = 2125, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, {triTime = 2375, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, status = {{odds = 10000, buffID = 1429, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
