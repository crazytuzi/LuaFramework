----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[5001] = {resPosId = 50001, pos = { x = 11.2029, y = 3.386841, z = -10.03488 }, mapid = 1},
	[5002] = {resPosId = 50002, pos = { x = 104.4189, y = 3.075851, z = -65.33102 }, mapid = 3},
	[5003] = {resPosId = 50003, pos = { x = 33.44353, y = 9.275856, z = 94.45356 }, mapid = 3},
	[5004] = {resPosId = 50004, pos = { x = 102.0627, y = 7.434466, z = 125.3691 }, mapid = 8},
	[5005] = {resPosId = 50005, pos = { x = -54.30712, y = 17.03447, z = -90.21226 }, mapid = 8},
	[5006] = {resPosId = 50006, pos = { x = 67.26618, y = 3.039565, z = -83.04103 }, mapid = 3},
	[5007] = {resPosId = 50007, pos = { x = -28.79845, y = 1.786804, z = -132.4717 }, mapid = 1},
	[5008] = {resPosId = 50008, pos = { x = -30.60137, y = 3.036194, z = -38.08411 }, mapid = 3},

};
function get_db_table()
	return map;
end
