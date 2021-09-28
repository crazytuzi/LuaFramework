----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[30003] = {
		[1] = {cool = 10000, events = {},},
	},

};
function get_db_table()
	return level;
end
