----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[8050] = {resPosId = 70400, pos = { x = 15.09183, y = 16.08383, z = 13.49876 }, mapid = 4002},
	[8051] = {resPosId = 70401, pos = { x = 14.92505, y = 17.23064, z = 97.25977 }, mapid = 4002},
	[8052] = {resPosId = 70402, pos = { x = -34.95977, y = 16.08383, z = 74.15284 }, mapid = 4002},
	[8053] = {resPosId = 70403, pos = { x = -32.60651, y = 16.08383, z = 36.11781 }, mapid = 4002},
	[8054] = {resPosId = 70404, pos = { x = 36.94038, y = 16.08383, z = 53.08035 }, mapid = 4002},

};
function get_db_table()
	return map;
end
