----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[84001] = {pos = { x = -1.200034, y = 6.931233, z = -108.0427 }, mapid = 5},
	[84002] = {pos = { x = 27.53326, y = 3.114183, z = 67.08454 }, mapid = 6},
	[84003] = {pos = { x = 46.5052, y = 21.42902, z = 111.1903 }, mapid = 7},
	[84004] = {pos = { x = 147.8737, y = 7.834466, z = 23.07198 }, mapid = 8},
	[84005] = {pos = { x = -74.10647, y = 13.38342, z = 31.82576 }, mapid = 9},

};
function get_db_table()
	return map;
end
