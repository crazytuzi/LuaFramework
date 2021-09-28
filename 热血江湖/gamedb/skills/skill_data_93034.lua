----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93034] = {
		[1] = {cool = 8000, events = {{triTime = 700, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{buffID = 1431, }, }, }, {triTime = 1125, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
