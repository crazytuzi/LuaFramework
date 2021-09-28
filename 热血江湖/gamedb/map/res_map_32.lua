----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[32001] = {resPosId = 70501, pos = { x = -25.86628, y = 4.647353, z = -49.18977 }, mapid = 70001},
	[32001] = {resPosId = 70502, pos = { x = -13.47724, y = 5.128945, z = -46.96471 }, mapid = 70001},
	[32002] = {resPosId = 70506, pos = { x = 29.68357, y = 4.696696, z = 53.61976 }, mapid = 70001},

};
function get_db_table()
	return map;
end
