----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[30007] = {
		[1] = {events = {{triTime = 100, }, },},
	},

};
function get_db_table()
	return level;
end
