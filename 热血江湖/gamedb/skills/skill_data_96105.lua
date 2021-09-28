----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[96105] = {
		[1] = {cool = 1000, events = {{triTime = 100, }, },additionalProp = {{propID = 1002, propsCount = {1000,1000,1000,1000,1000,}}, }, },
	},

};
function get_db_table()
	return level;
end
