----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93013] = {
		[1] = {cool = 8000, events = {{triTime = 850, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, status = {{odds = 10000, buffID = 1410, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
