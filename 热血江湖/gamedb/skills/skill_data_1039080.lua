----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1039101] = {
		[1] = {cool = 5000, events = {},},
	},
	[1039102] = {
		[1] = {cool = 5000, events = {},},
	},

};
function get_db_table()
	return level;
end
