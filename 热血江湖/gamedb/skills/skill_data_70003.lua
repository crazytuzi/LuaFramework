----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[70003] = {
		[1] = {cool = 9000, events = {},},
	},

};
function get_db_table()
	return level;
end
