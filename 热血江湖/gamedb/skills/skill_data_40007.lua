----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[40007] = {
		[1] = {cool = 3000, events = {},},
	},

};
function get_db_table()
	return level;
end
