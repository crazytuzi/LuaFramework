----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[36002] = {resPosId = 71625, pos = { x = 55.04813, y = 0.1962509, z = -77.00364 }, mapid = 4011},
	[36001] = {resPosId = 71642, pos = { x = -55.1842, y = 0.1962509, z = 76.76316 }, mapid = 4016},
	[36002] = {resPosId = 71620, pos = { x = -55.1842, y = 0.1962509, z = 76.76316 }, mapid = 4010},

};
function get_db_table()
	return map;
end
