----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[20003] = {
		[1] = {cool = 8000, events = {},},
	},

};
function get_db_table()
	return level;
end
