----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95037] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 3.5, }, status = {{buffID = 120321, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 4.2, }, status = {{buffID = 120321, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 4.2, }, status = {{buffID = 120322, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 4.2, }, status = {{buffID = 120323, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
