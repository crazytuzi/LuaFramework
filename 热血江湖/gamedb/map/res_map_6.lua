----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[6001] = {resPosId = 60001, pos = { x = -104.1267, y = 7.0, z = 7.617018 }, mapid = 2},
	[6004] = {resPosId = 60005, pos = { x = -54.11092, y = 3.609921, z = 49.54676 }, mapid = 1},
	[6007] = {resPosId = 60008, pos = { x = -110.6218, y = 17.16384, z = 113.5528 }, mapid = 6},
	[6008] = {resPosId = 60009, pos = { x = 34.68972, y = 24.19971, z = 138.5055 }, mapid = 7},
	[6009] = {resPosId = 60010, pos = { x = -48.23788, y = 7.726531, z = -79.36111 }, mapid = 9},
	[6010] = {resPosId = 60011, pos = { x = 77.53997, y = 17.3917, z = 44.29248 }, mapid = 8},
	[6011] = {resPosId = 60012, pos = { x = -158.0198, y = 4.163841, z = -107.5851 }, mapid = 6},
	[6012] = {resPosId = 60013, pos = { x = 7.46048, y = 13.35855, z = 11.14395 }, mapid = 7},
	[6002] = {resPosId = 60002, pos = { x = -48.00001, y = 13.83619, z = 69.30001 }, mapid = 3},
	[6003] = {resPosId = 60003, pos = { x = -16.28785, y = 3.436298, z = -4.380074 }, mapid = 1},
	[6013] = {resPosId = 60004, pos = { x = -15.94727, y = 3.036188, z = -108.7438 }, mapid = 3},
	[6005] = {resPosId = 60006, pos = { x = -101.6283, y = 0.2000002, z = -39.44691 }, mapid = 2},
	[6006] = {resPosId = 60007, pos = { x = -52.32294, y = 10.23619, z = -17.62316 }, mapid = 3},

};
function get_db_table()
	return map;
end
