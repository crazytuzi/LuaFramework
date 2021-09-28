----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[35002] = {resPosId = 140005, pos = { x = 85.48131, y = 2.205698, z = 49.0223 }, mapid = 60001},
	[35005] = {resPosId = 140008, pos = { x = -53.36231, y = 5.051756, z = -49.51913 }, mapid = 60000},
	[35000] = {resPosId = 140001, pos = { x = -69.93625, y = 7.0, z = -0.9478149 }, mapid = 60005},
	[35001] = {resPosId = 140004, pos = { x = 34.07934, y = 9.436188, z = 17.36899 }, mapid = 60002},
	[35003] = {resPosId = 140006, pos = { x = 76.72833, y = 2.005698, z = 3.980117 }, mapid = 60001},
	[35004] = {resPosId = 140007, pos = { x = 68.30713, y = 2.005698, z = 7.621419 }, mapid = 60001},

};
function get_db_table()
	return map;
end
