----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[99999] = {pos = { x = -32.95021, y = 5.031435, z = -0.8691371 }, mapid = -1},
	[99999] = {pos = { x = 33.13616, y = 5.112771, z = -0.3814461 }, mapid = -1},

};
function get_db_table()
	return map;
end
