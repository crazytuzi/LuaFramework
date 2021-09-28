----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92038] = {
		[1] = {events = {{triTime = 100, status = {{odds = 5000, buffID = 1525, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
