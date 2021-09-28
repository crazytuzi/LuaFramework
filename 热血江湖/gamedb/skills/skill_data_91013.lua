----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91013] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 530, }, {odds = 10000, buffID = 531, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
