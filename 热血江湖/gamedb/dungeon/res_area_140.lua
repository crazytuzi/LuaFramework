----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[140001] = {	id = 140001, pos = { x = -69.93625, y = 7.0, z = -0.9478149 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35000},
	[140004] = {	id = 140004, pos = { x = 34.07934, y = 9.436188, z = 17.36899 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35001},
	[140005] = {	id = 140005, pos = { x = 85.48131, y = 2.205698, z = 49.0223 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35002},
	[140006] = {	id = 140006, pos = { x = 76.72833, y = 2.005698, z = 3.980117 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35003},
	[140007] = {	id = 140007, pos = { x = 68.30713, y = 2.005698, z = 7.621419 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35004},
	[140008] = {	id = 140008, pos = { x = -53.36231, y = 5.051756, z = -49.51913 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 35005},
	[140009] = {	id = 140009, pos = { x = 66.75056, y = 6.464359, z = 75.42912 }, dir = { x = 0.0, y = 90.0, z = 0.0 }, ResourcepointID = 38504},

};
function get_db_table()
	return res_area;
end
