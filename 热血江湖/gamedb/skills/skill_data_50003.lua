----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[50003] = {
		[1] = {cool = 11000, events = {},},
	},

};
function get_db_table()
	return level;
end
