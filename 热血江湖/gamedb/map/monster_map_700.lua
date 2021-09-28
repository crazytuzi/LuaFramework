----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[140001] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 12001},
	[140002] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 12002},
	[140003] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 12003},
	[140004] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 12004},
	[140005] = {pos = { x = 4.198858, y = 10.94589, z = 1.9217 }, mapid = 12005},

};
function get_db_table()
	return map;
end
