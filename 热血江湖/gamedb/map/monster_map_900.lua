----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[180000] = {pos = { x = -115.0869, y = 5.074378, z = -151.6949 }, mapid = 60100},
	[180000] = {pos = { x = -121.145, y = 5.172903, z = -90.63261 }, mapid = 60100},
	[180100] = {pos = { x = -71.96122, y = 3.786756, z = -116.2083 }, mapid = 60100},

};
function get_db_table()
	return map;
end
