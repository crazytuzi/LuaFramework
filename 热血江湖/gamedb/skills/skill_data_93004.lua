----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93004] = {
		[1] = {cool = 25000, events = {{damage = {odds = 10000, atrType = 1, arg1 = 1.2, }, status = {{buffID = 1400, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
