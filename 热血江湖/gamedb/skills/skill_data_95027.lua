----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95027] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 5.0, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 6.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
