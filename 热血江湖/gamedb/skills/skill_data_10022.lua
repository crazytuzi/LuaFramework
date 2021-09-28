----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[10022] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 418, }, }, }, },spArgs1 = '0', spArgs2 = '0', },
	},

};
function get_db_table()
	return level;
end
