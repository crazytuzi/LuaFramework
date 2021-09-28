----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[33001] = {	id = 33001, pos = { x = -42.93199, y = 19.52096, z = 22.22643 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3023},
	[33002] = {	id = 33002, pos = { x = 34.39725, y = 19.52096, z = -27.48969 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3024},
	[33101] = {	id = 33101, pos = { x = -20.68894, y = 6.102335, z = 22.62956 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3025},
	[33102] = {	id = 33102, pos = { x = -39.08828, y = 11.34099, z = -60.79149 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3026},
	[33103] = {	id = 33103, pos = { x = 32.80457, y = 13.84099, z = -4.15987 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3027},
	[33104] = {	id = 33104, pos = { x = -42.04268, y = 8.34218, z = -19.94367 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3028},
	[33105] = {	id = 33105, pos = { x = 28.875, y = 2.436445, z = -11.875 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3029},
	[33106] = {	id = 33106, pos = { x = -10.61324, y = 6.965301, z = -22.5162 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3030},
	[33107] = {	id = 33107, pos = { x = 22.14737, y = 6.965301, z = -0.8447208 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 3031},
	[33108] = {	id = 33108, pos = { x = 50.09883, y = 18.99218, z = 44.04372 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, ResourcepointID = 3032},
	[33109] = {	id = 33109, pos = { x = 106.0603, y = 16.37305, z = -63.74219 }, dir = { x = 0.0, y = 75.0, z = 0.0 }, ResourcepointID = 3033},
	[33110] = {	id = 33110, pos = { x = 38.17214, y = 7.237802, z = 1.497047 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, ResourcepointID = 3034},
	[33111] = {	id = 33111, pos = { x = -11.34085, y = 6.237802, z = 0.934124 }, dir = { x = 0.0, y = 75.0, z = 0.0 }, ResourcepointID = 3035},
	[33112] = {	id = 33112, pos = { x = -36.87234, y = 28.0, z = 35.84713 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, ResourcepointID = 3036},
	[33113] = {	id = 33113, pos = { x = -17.02644, y = 22.0, z = -10.16523 }, dir = { x = 0.0, y = 45.0, z = 0.0 }, ResourcepointID = 3037},
	[33114] = {	id = 33114, pos = { x = -8.177547, y = 32.10902, z = -80.202 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, ResourcepointID = 3038},
	[33115] = {	id = 33115, pos = { x = 9.067348, y = 37.70901, z = -28.7289 }, dir = { x = 0.0, y = 45.0, z = 0.0 }, ResourcepointID = 3039},

};
function get_db_table()
	return res_area;
end
