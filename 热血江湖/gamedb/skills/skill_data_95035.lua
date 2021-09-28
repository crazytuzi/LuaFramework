----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95035] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 120317, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 120318, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 120319, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
