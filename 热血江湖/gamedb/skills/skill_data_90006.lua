----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90006] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 256, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 257, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 258, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
