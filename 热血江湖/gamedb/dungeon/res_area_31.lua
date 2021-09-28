----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[31001] = {	id = 31001, pos = { x = 9.030087, y = 3.415608, z = 49.7864 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2101},
	[31002] = {	id = 31002, pos = { x = -17.07727, y = 3.386841, z = -66.11466 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2102},
	[31003] = {	id = 31003, pos = { x = -102.195, y = 1.364172, z = -134.1737 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2103},
	[31004] = {	id = 31004, pos = { x = -163.2179, y = 2.744248, z = -135.5157 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2104},
	[31005] = {	id = 31005, pos = { x = -140.1103, y = 2.775995, z = -122.0262 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2105},
	[31006] = {	id = 31006, pos = { x = 10.12856, y = 0.2000002, z = -97.09679 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2106},
	[31007] = {	id = 31007, pos = { x = -58.52469, y = 5.0, z = -45.46445 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2107},
	[31008] = {	id = 31008, pos = { x = -71.95606, y = 7.0, z = 3.240433 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2108},
	[31009] = {	id = 31009, pos = { x = -83.40942, y = 0.2000002, z = -78.21411 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2109},
	[31010] = {	id = 31010, pos = { x = -58.2099, y = 6.923518, z = -15.5545 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2110},
	[31011] = {	id = 31011, pos = { x = 10.82287, y = 13.74401, z = 47.30146 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2111},
	[31012] = {	id = 31012, pos = { x = 9.548177, y = 0.2000002, z = -111.7346 }, dir = { x = 0.0, y = -150.0, z = 0.0 }, ResourcepointID = 2112},
	[31013] = {	id = 31013, pos = { x = -23.2654, y = 9.776732, z = -2.6261 }, dir = { x = 0.0, y = -90.0, z = 0.0 }, ResourcepointID = 2113},
	[31014] = {	id = 31014, pos = { x = -93.27081, y = 15.67585, z = 43.41652 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2114},
	[31015] = {	id = 31015, pos = { x = -56.17363, y = 13.93759, z = 48.72992 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2115},
	[31016] = {	id = 31016, pos = { x = 43.7247, y = 3.036194, z = -40.36343 }, dir = { x = 0.0, y = 300.0, z = 0.0 }, ResourcepointID = 2116},
	[31017] = {	id = 31017, pos = { x = 65.22057, y = 3.075853, z = -38.89055 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2117},
	[31018] = {	id = 31018, pos = { x = 20.21159, y = 3.192636, z = -107.6093 }, dir = { x = 0.0, y = 105.0, z = 0.0 }, ResourcepointID = 2118},
	[31019] = {	id = 31019, pos = { x = -36.0, y = 3.075854, z = -93.67984 }, dir = { x = 0.0, y = 30.0, z = 0.0 }, ResourcepointID = 2119},

};
function get_db_table()
	return res_area;
end
