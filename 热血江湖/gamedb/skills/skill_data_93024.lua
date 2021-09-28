----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93024] = {
		[1] = {cool = 30000, events = {{damage = {atrType = 1, }, }, },},
	},

};
function get_db_table()
	return level;
end
