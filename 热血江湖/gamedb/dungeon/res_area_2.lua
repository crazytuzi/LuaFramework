----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[2011] = {	id = 2011, pos = { x = -72.45422, y = 0.2000002, z = -116.6095 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 201},
	[2012] = {	id = 2012, pos = { x = -75.32455, y = 0.2000002, z = -112.1745 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 201},
	[2021] = {	id = 2021, pos = { x = 40.6364, y = 0.2000002, z = -98.5202 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 202},
	[2022] = {	id = 2022, pos = { x = 38.08197, y = 0.2000002, z = -99.60332 }, dir = { x = 0.0, y = 135.0, z = 0.0 }, ResourcepointID = 202},
	[2031] = {	id = 2031, pos = { x = -61.57566, y = 7.069425, z = -11.48895 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 203},
	[2032] = {	id = 2032, pos = { x = -60.10108, y = 7.0, z = -13.30799 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 203},
	[2071] = {	id = 2071, pos = { x = -96.97684, y = 0.2000002, z = -92.25456 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 207},
	[2072] = {	id = 2072, pos = { x = -96.76985, y = 0.2000002, z = -87.98041 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 207},

};
function get_db_table()
	return res_area;
end
