----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93002] = {
		[1] = {cool = 10000, events = {{triTime = 750, damage = {odds = 10000, atrType = 1, arg1 = 1.1, }, status = {{odds = 3000, buffID = 1401, }, }, }, {triTime = 1200, damage = {odds = 10000, atrType = 1, arg1 = 1.1, }, }, {triTime = 1575, damage = {odds = 10000, atrType = 1, arg1 = 1.1, }, }, },},
	},

};
function get_db_table()
	return level;
end
