----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[450001] = {pos = { x = 61.19071, y = 6.437775, z = 69.23703 }, mapid = -1},
	[450002] = {pos = { x = -106.3891, y = 50.47525, z = 62.35673 }, mapid = 241},
	[450003] = {pos = { x = -104.0, y = 50.0, z = 22.0 }, mapid = 241},
	[450005] = {pos = { x = 102.0, y = 30.0, z = 120.0 }, mapid = 82004},
	[450004] = {pos = { x = -82.01904, y = 44.97719, z = 9.227322 }, mapid = 241},

};
function get_db_table()
	return map;
end
