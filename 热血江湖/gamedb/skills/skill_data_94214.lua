----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94214] = {
		[1] = {cool = 8000, events = {{hitEffID = 30794, damage = {odds = 10000, arg1 = 0.43, }, status = {{odds = 18000, buffID = 573, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
