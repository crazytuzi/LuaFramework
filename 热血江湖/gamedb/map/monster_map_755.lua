----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[151000] = {pos = { x = 24.77378, y = 25.0, z = -23.92265 }, mapid = 36400},
	[151001] = {pos = { x = 24.77378, y = 25.0, z = -23.92266 }, mapid = 36401},
	[151002] = {pos = { x = 24.77378, y = 25.0, z = -23.92267 }, mapid = 36402},
	[151003] = {pos = { x = 24.77378, y = 25.0, z = -23.92268 }, mapid = 36403},
	[151004] = {pos = { x = 24.77378, y = 25.0, z = -23.92269 }, mapid = 36404},
	[151005] = {pos = { x = 24.77378, y = 25.0, z = -23.9227 }, mapid = 36405},
	[151006] = {pos = { x = 24.77378, y = 25.0, z = -23.92271 }, mapid = 36406},

};
function get_db_table()
	return map;
end
