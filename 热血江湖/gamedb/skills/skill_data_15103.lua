----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[15103] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 677, }, {odds = 10000, buffID = 678, }, }, }, },skillpower = 24, skillrealpower = {0,153,312,481,661,}, },
	},

};
function get_db_table()
	return level;
end
