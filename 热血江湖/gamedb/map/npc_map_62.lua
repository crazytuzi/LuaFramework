----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[31002] = {	pos = { x = 48.89212, y = 13.35855, z = -26.46763 }, mapid = 7},
	[31007] = {	pos = { x = -62.93265, y = 17.77544, z = 93.80379 }, mapid = 8888},
	[31001] = {	pos = { x = 28.60888, y = 13.42542, z = -3.742979 }, mapid = 7},

};
function get_db_table()
	return map;
end
