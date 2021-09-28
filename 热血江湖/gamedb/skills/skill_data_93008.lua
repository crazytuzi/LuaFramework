----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93008] = {
		[1] = {cool = 12000, events = {{damage = {odds = 10000, atrType = 1, arg1 = 0.3, }, status = {{buffID = 1413, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
