----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93033] = {
		[1] = {events = {{triTime = 500, damage = {odds = 10000, atrType = 1, arg1 = 0.85, }, status = {{odds = 1000, buffID = 1427, }, }, }, {triTime = 950, damage = {odds = 10000, atrType = 1, arg1 = 0.85, }, status = {{odds = 1000, buffID = 1427, }, }, }, {triTime = 1800, damage = {odds = 10000, atrType = 1, arg1 = 0.85, }, status = {{odds = 1000, buffID = 1427, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
