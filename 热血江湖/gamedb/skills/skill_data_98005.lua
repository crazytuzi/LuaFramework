----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98005] = {
		[1] = {cool = 8000, events = {{triTime = 100, hitEffID = 30491, status = {{odds = 10000, buffID = 532, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
