----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[62203] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 15000, buffID = 591, }, }, }, },skillpower = 24, skillrealpower = {0,153,312,481,661,}, },
	},

};
function get_db_table()
	return level;
end
