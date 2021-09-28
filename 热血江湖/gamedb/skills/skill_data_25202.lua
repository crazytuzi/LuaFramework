----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[25202] = {
		[1] = {events = {{triTime = 100, status = {{odds = 8000, buffID = 688, }, }, }, },skillpower = 24, skillrealpower = {0,153,312,481,661,}, },
	},

};
function get_db_table()
	return level;
end
