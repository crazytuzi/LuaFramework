----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95029] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 6.0, }, status = {{buffID = 882, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
