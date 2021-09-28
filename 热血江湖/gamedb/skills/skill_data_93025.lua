----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93025] = {
		[1] = {cool = 25000, events = {{triTime = 100, }, },},
	},

};
function get_db_table()
	return level;
end
