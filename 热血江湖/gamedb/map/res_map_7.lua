----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[7002] = {resPosId = 20001, pos = { x = -32.95464, y = 2.954441, z = -25.48528 }, mapid = 4000},
	[7002] = {resPosId = 20002, pos = { x = 6.237186, y = 2.954441, z = 73.60657 }, mapid = 4000},
	[7003] = {resPosId = 20005, pos = { x = -31.10979, y = 2.954441, z = 48.76988 }, mapid = 4000},

};
function get_db_table()
	return map;
end
