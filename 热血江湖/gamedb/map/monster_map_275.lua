----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[55003] = {pos = { x = -7.6, y = 6.2, z = -6.0 }, mapid = 82000},
	[55001] = {pos = { x = -41.0, y = -3.8, z = -67.0 }, mapid = 82003},
	[55002] = {pos = { x = -20.23409, y = 13.16542, z = -73.17223 }, mapid = 82001},
	[55004] = {pos = { x = -130.0, y = 5.0, z = 8.0 }, mapid = 82002},

};
function get_db_table()
	return map;
end
