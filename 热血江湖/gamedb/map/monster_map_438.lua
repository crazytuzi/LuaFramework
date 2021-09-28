----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[87601] = {pos = { x = -66.47887, y = 0.2000002, z = -99.37006 }, mapid = 11005},
	[87601] = {pos = { x = -38.7005, y = 0.2000001, z = -128.7174 }, mapid = 11005},
	[87602] = {pos = { x = -73.10187, y = 7.0, z = 30.41436 }, mapid = 11005},
	[87603] = {pos = { x = -54.34615, y = 0.2000002, z = -116.6829 }, mapid = 11005},
	[87604] = {pos = { x = 10.98357, y = 13.93217, z = 39.58616 }, mapid = 11005},
	[87605] = {pos = { x = -67.34935, y = 0.2000002, z = -124.3958 }, mapid = 11005},
	[87606] = {pos = { x = -81.8354, y = 7.014168, z = 31.83595 }, mapid = 11005},
	[87607] = {pos = { x = -47.54869, y = 0.2000002, z = -98.15753 }, mapid = 11005},
	[87608] = {pos = { x = 59.21457, y = 13.09666, z = 18.27781 }, mapid = 11005},
	[87609] = {pos = { x = -26.07948, y = 0.2000002, z = -124.1166 }, mapid = 11005},
	[87610] = {pos = { x = -32.23615, y = 5.0, z = -55.60547 }, mapid = 11005},
	[87701] = {pos = { x = -121.2083, y = 2.239738, z = -33.08291 }, mapid = 11006},
	[87702] = {pos = { x = -24.51875, y = 3.082024, z = -100.4613 }, mapid = 11006},
	[87703] = {pos = { x = 147.5727, y = 30.08202, z = 96.2318 }, mapid = 11006},
	[87704] = {pos = { x = -16.62751, y = 10.08202, z = -7.574053 }, mapid = 11006},
	[87705] = {pos = { x = 7.260494, y = 3.082024, z = -119.1174 }, mapid = 11006},
	[87706] = {pos = { x = 11.27256, y = 5.082024, z = -85.8174 }, mapid = 11006},
	[87707] = {pos = { x = 81.98758, y = 10.22691, z = -83.1832 }, mapid = 11006},
	[87708] = {pos = { x = 5.275693, y = 3.082024, z = -119.8143 }, mapid = 11006},
	[87709] = {pos = { x = -8.59626, y = 0.0820236, z = -151.684 }, mapid = 11006},
	[87710] = {pos = { x = 60.72278, y = 17.17327, z = 124.046 }, mapid = 11006},

};
function get_db_table()
	return map;
end
